const Extra = require('../models/extra')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const getPrice = async (req, res) => {
  try {
    let price = await Extra.getPrice(req.params.deliveryId)
    if (price) {
      res.json(successResponse({ price }))
    } else {
      res.json(failResponse('No se pudo obtener el precio de la entrega'))
    }
  } catch (error) {
    res.status(500).json(errorResponse('Al obtener precio de entrega' + error))
  }
}
const getManager = async (req, res) => {
  try {
    let manager = await Extra.getManager(req.params.deliveryId)
    if (manager) {
      res.json(successResponse({ manager }))
    } else {
      res.json(failResponse('No se pudo obtener el manager de la'))
    }
  } catch (error) {
    res.status(500).json(errorResponse('Al obtener manager de entrega'))
  }
}

const getSupervisor = async (req, res) => {
  try {
    let supervisor = await Extra.getSupervisor(req.params.deliveryId)
    if (supervisor) {
      res.json(successResponse({ supervisor }))
    } else {
      res.json(failResponse('No se pudo obtener el manager de la'))
    }
  } catch (error) {
    res.status(500).json(errorResponse('Al obtener supervisor de entrega'))
  }
}

module.exports = { getPrice, getManager, getSupervisor }
