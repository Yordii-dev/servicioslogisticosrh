const DeliveredOrder = require('../models/delivered-order')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')
const createDelivered = async (req, res) => {
  try {
    let response = await DeliveredOrder.createDelivered(req.body)

    if (response.affectedRows != 0) {
      res.json(successResponse())
    } else {
      res.json(failResponse('No se pudo entregar el pedido'))
    }
  } catch (error) {
    res.status(500).json(errorResponse('Al entregar pedido' + error))
  }
}

module.exports = { createDelivered }
