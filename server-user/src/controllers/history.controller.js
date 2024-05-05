const History = require('../models/history')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const getHistory = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let history = await History.getHistory(auth.data.id)
    res.json(successResponse({ history }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener historial de usuario'))
      return
    }
    res.json(errorResponse('Al obtener historial de usuario' + error))
  }
}

module.exports = { getHistory }
