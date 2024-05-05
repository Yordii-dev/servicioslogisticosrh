const Operator = require('../classes/Operator')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  errorResponse,
  failResponse,
  successResponse,
} = require('../helpers/httpResponse')

const getClients = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let clients = await Operator.getClients(auth.data.id, req.params.date)

    res.json(successResponse({ clients }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener clientes de operador'))
      return
    }
    res.json(errorResponse('Al obtener clientes de operador'))
  }
}

module.exports = { getClients }
