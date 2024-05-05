// importa el módulo de node `file-system`
const fs = require('fs')

const removeFile = (path) => {
  try {
    fs.unlinkSync(path)
    console.log('Archivo removido')
  } catch (error) {
    console.error('No se pudo remover el archivo', error)
  }
}

module.exports = removeFile
