import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

// Résoudre le chemin actuel du fichier
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Fonction pour vérifier si un fichier ou dossier est caché
const isHidden = (filePath) => {
  const baseName = path.basename(filePath);
  return baseName.startsWith("."); // Vérifie si le fichier ou dossier est caché
};

// Fonction pour vérifier si l'extension du fichier est autorisée
const isAllowedFileType = (filePath, allowedExtensions) => {
  const ext = path.extname(filePath).toLowerCase();
  return allowedExtensions.includes(ext);
};
// Fonction pour parcourir un répertoire et récupérer les fichiers autorisés
const readDirectory = (dirPath, result, allowedExtensions) => {
  const files = fs.readdirSync(dirPath);

  files.forEach((file) => {
    const filePath = path.join(dirPath, file);
    const stat = fs.statSync(filePath);

    // Si c'est un dossier non caché, on appelle récursivement readDirectory
    if (stat.isDirectory() && !isHidden(file)) {
      readDirectory(filePath, result, allowedExtensions);
    }
    // Si c'est un fichier non caché et que son type est autorisé, on récupère son contenu
    else if (
      stat.isFile() &&
      !isHidden(file) &&
      isAllowedFileType(file, allowedExtensions)
    ) {
      const content = fs.readFileSync(filePath, "utf8");
      result.push(`/// ${filePath}\n\n${content}\n`);
    }
  });
};

// Fonction principale pour créer le fichier 'projet_data.txt'
const generateProjectData = (projectDir, allowedExtensions) => {
  const result = [];
  readDirectory(projectDir, result, allowedExtensions);

  const output = result.join("\n---------\n");
  fs.writeFileSync("projet_data.txt", output, "utf8");

  console.log("Fichier projet_data.txt généré avec succès.");
};

// Extensions autorisées : tu peux les ajuster ici
const allowedExtensions = [
  ".vim",
  ".lua",
  //"get-type-info.js",
  //"generate-types.js",
  //"stringify-type-tree.js",
]; // Par exemple, ici on autorise uniquement .js, .lua, .vim

// Appeler la fonction avec le chemin du projet et les extensions autorisées
const projectPath = path.resolve(__dirname); // ou spécifiez le chemin de votre projet ici
generateProjectData(projectPath, allowedExtensions);
