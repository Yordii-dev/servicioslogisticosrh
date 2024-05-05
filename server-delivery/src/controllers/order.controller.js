const Delivery = require('../classes/Delivery')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')
const Order = require('../models/order')

const getOrders = async (req, res) => {
  try {
    let orders = await Delivery.getOrders(req.params.deliveryId)

    if (orders) {
      res.json(successResponse({ orders }))
    } else {
      res.json(failResponse('Esta entrega no existe'))
    }
  } catch (error) {
    res.status(500).json(errorResponse('Al obtener los pedidos' + error))
  }
}
const getTotal = async (req, res) => {
  try {
    let total = await Delivery.getTotalOrders(req.params.deliveryId)
    if (total) {
      res.json(successResponse({ total }))
    } else {
      res.json(failResponse('Esta entrega no existe'))
    }
  } catch (error) {
    res.status(500).json(errorResponse('Al obtener total de pedidos'))
  }
}

module.exports = { getOrders, getTotal }
