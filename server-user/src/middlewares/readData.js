const readXlsxFile = require('read-excel-file/node')
const { errorResponse } = require('../helpers/httpResponse')
const removeFile = require('../helpers/removeFile')

const readData = async (req, res, next) => {
  try {
    let data = await readXlsxFile(`src/uploads/${req.dataFile.name}`)
    req.dataFile.content = data
    next()
  } catch (error) {
    removeFile(`src/uploads/${req.dataFile.name}`)
    res.send(errorResponse('Al leer data del archivo importado' + error))
  }
}
module.exports = readData
