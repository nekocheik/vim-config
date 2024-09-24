import JsonToTS from "json-to-ts";

function generateInterfaceFromObject(content, interfaceName) {
  try {
    const parsedContent = JSON.parse(content); // Essaye de parser comme JSON
    return JsonToTS(parsedContent, {
      rootName: interfaceName || "RootObject",
    }).reduce((a, b) => `${a}\n\n${b}`, "");
  } catch (e) {
    // Si ce n'est pas du JSON valide, essaie de l'exécuter en tant que JS
    try {
      const jsObject = eval(`(${content})`); // Utilise eval pour interpréter du JS
      return JsonToTS(jsObject, {
        rootName: interfaceName || "RootObject",
      }).reduce((a, b) => `${a}\n\n${b}`, "");
    } catch (error) {
      return "Error: Invalid JSON or JavaScript input.";
    }
  }
}

// Récupère l'entrée via les arguments de commande
const inputContent = process.argv[2];
const interfaceName = process.argv[3]; // Laisse "RootObject" être décidé si rien n'est donné

// Génère les interfaces TypeScript
const output = generateInterfaceFromObject(inputContent, interfaceName);

// Affiche le résultat pour le récupérer dans Vim
console.log(output);
