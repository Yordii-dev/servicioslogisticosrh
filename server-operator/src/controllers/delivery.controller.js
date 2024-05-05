const Vehicle = require('../classes/Vehicle')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const getDeliveries = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let deliveries = await Vehicle.getDeliveries(
      auth.data.vehicleId,
      req.params.date
    )
    res.json(successResponse({ deliveries }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener entragas de operdor'))
      return
    }
    res.status(500).json(errorResponse('Al obtener entregas de operador'))
  }
}

const getTotal = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let total = await Vehicle.getTotalDeliveries(
      auth.data.vehicleId,
      req.params.date
    )

    if (total) {
      res.json(successResponse({ total }))
    } else {
      res.json(failResponse('La entrega no existe'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(
        failResponse('Token invalido al obtener total de entregas de operador')
      )
      return
    }
    res
      .status(500)
      .json(errorResponse('Al obtener total de entregas de operador'))
  }
}

module.exports = { getDeliveries, getTotal }
