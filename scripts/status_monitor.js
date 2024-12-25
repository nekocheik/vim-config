const fs = require('fs');
const path = require('path');

const STATUS_FILE = '/tmp/nvim_custom_mode_status';
const LOG_FILE = '/tmp/nvim_custom_mode.log';

// Fonction pour logger les messages
function logMessage(message) {
    const timestamp = new Date().toISOString();
    fs.appendFileSync(LOG_FILE, `${timestamp}: ${message}\n`);
}

// Fonction pour créer/mettre à jour le fichier de statut
function updateStatusFile(status) {
    try {
        fs.writeFileSync(STATUS_FILE, status.toString());
        logMessage(`Status updated to: ${status}`);
    } catch (error) {
        logMessage(`Error updating status: ${error.message}`);
    }
}

// Initialisation
updateStatusFile(false);

// Surveiller les changements de statut
process.stdin.on('data', (data) => {
    const status = data.toString().trim() === 'true';
    updateStatusFile(status);
});

// Gérer les erreurs
process.on('error', (error) => {
    logMessage(`Process error: ${error.message}`);
});

logMessage('Status monitor started'); 