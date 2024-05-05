const Evidence = require('../models/evidence')
const removeFile = require('../helpers/removeFile')
const {
  errorResponse,
  successResponse,
  failResponse,
} = require('../helpers/httpResponse')

const createEvidence = async (req, res) => {
  try {
    let response = await Evidence.createEvidence(req.dataImage, req.body)

    if (response.affectedRows != 0) {
      res.json(successResponse())
    } else {
      removeFile(`src/images/${req.dataFile.name}`)
      res.json(failResponse('No se pudo crear evidencia de entrega'))
    }
  } catch (error) {
    removeFile(`src/images/${req.dataFile.name}`)
    res.status(500).json(errorResponse('Al crear evidencia de entrega' + error))
  }
}

module.exports = { createEvidence }
