const Route = require('../models/route')
const Operator = require('../classes/Operator')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  errorResponse,
  failResponse,
} = require('../helpers/httpResponse')

const getRoute = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)

    let route = await Operator.getRoute(auth.data.id, req.params.date)

    if (route) {
      res.json(successResponse({ route }))
    } else {
      res.json(failResponse('Ruta no obtenida'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener ruta de operador'))
      return
    }
    res.status(500).json(errorResponse('Al obtener ruta de operador' + error))
  }
}
const createRoute = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let response = await Route.createRoute(auth.data, req.body)

    if (response.affectedRows > 0) {
      res.json(successResponse())
    } else {
      res.json(failResponse('No se pudo crear la ruta', [response]))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al crear ruta de operador'))
      return
    }
    res.status(500).json(errorResponse('Al crear ruta de operador' + error))
  }
}
module.exports = { getRoute, createRoute }
