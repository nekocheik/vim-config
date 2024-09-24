import ts from "typescript";
import { stringifyTypeTree } from "./stringify-type-tree.js";

/**
 * Récupère le type à une position spécifique dans le fichier.
 */
function getTypeAtPosition(filePath, position, word) {
  const program = ts.createProgram([filePath], {
    allowJs: true,
    moduleResolution: ts.ModuleResolutionKind.NodeJs,
    target: ts.ScriptTarget.ES5,
    jsx: ts.JsxEmit.React,
    esModuleInterop: true,
  });

  const checker = program.getTypeChecker();
  const sourceFile = program.getSourceFile(filePath);

  if (!sourceFile) {
    console.error("Error: Could not load the source file.");
    return;
  }

  const node = findNodeAtPosition(sourceFile, position, word);
  if (node) {
    if (node.parent && node.parent.kind) {
      try {
        const type = checker.getTypeAtLocation(node);
        if (type) {
          const typeTree = buildTypeTree(type, checker, 1); // Explore one level deep
          const typeString = stringifyTypeTree(typeTree, false);
          return typeString;
        }
      } catch (error) {
        console.error("Error while fetching type:", error);
        return "Error: Could not determine the type";
      }
    } else {
      return "Error: Node or parent is undefined";
    }
  }

  return "Type not found";
}

/**
 * Construction de l'arbre de types.
 */
function buildTypeTree(type, checker, depth = 3) {
  const typeFlags = type.getFlags();

  // Types basiques
  if (typeFlags & ts.TypeFlags.String) {
    return { kind: "basic", typeName: "string" };
  }

  if (typeFlags & ts.TypeFlags.Number) {
    return { kind: "basic", typeName: "number" };
  }

  if (typeFlags & ts.TypeFlags.Boolean) {
    return { kind: "basic", typeName: "boolean" };
  }

  if (typeFlags & ts.TypeFlags.Null) {
    return { kind: "basic", typeName: "null" };
  }

  if (typeFlags & ts.TypeFlags.Undefined) {
    return { kind: "basic", typeName: "undefined" };
  }

  if (typeFlags & ts.TypeFlags.Any) {
    return { kind: "basic", typeName: "any" };
  }

  if (typeFlags & ts.TypeFlags.Unknown) {
    return { kind: "basic", typeName: "unknown" };
  }

  // Tableaux
  if (
    typeFlags & ts.TypeFlags.Object &&
    type.objectFlags & ts.ObjectFlags.Reference
  ) {
    const typeArguments = checker.getTypeArguments(type);
    if (typeArguments.length === 1) {
      return {
        kind: "array",
        readonly: false,
        elementType: buildTypeTree(typeArguments[0], checker, depth - 1),
      };
    }
  }

  // Objets ou interfaces
  if (
    typeFlags & ts.TypeFlags.Object &&
    (type.objectFlags & ts.ObjectFlags.Interface ||
      type.objectFlags & ts.ObjectFlags.Class)
  ) {
    const properties = type.getProperties().map((prop) => {
      const propType = checker.getTypeOfSymbolAtLocation(
        prop,
        prop.valueDeclaration || prop.declarations[0]
      );

      const exploredType =
        depth > 0 && propType.getFlags() & ts.TypeFlags.Object
          ? buildTypeTree(propType, checker, depth - 1)
          : buildTypeTree(propType, checker, 0);

      return {
        name: prop.getName(),
        readonly: !!(prop.getFlags() & ts.SymbolFlags.Readonly),
        type: exploredType,
      };
    });

    return {
      kind: "object",
      properties,
    };
  }

  // Type basique par défaut
  const typeName = checker.typeToString(type);
  return {
    kind: "basic",
    typeName,
  };
}

/**
 * Recherche le nœud à une position spécifique ou correspondance exacte avec le mot.
 */
function findNodeAtPosition(sourceFile, position, word) {
  function find(node) {
    const nodeText = node.getText();

    if (nodeText.includes(word) && nodeText === word) {
      return node;
    }

    if (position >= node.getStart() && position <= node.getEnd()) {
      return ts.forEachChild(node, find) || node;
    }

    return ts.forEachChild(node, find);
  }

  return find(sourceFile);
}

// Commande pour récupérer le fichier, la position et le mot survolé
const filePath = process.argv[2];
const position = parseInt(process.argv[3], 10);
const cword = process.argv[4]; // Le mot sous survol

const typeResult = getTypeAtPosition(filePath, position, cword);

// Affiche le résultat dans la console
console.log("Type Info:", typeResult);
