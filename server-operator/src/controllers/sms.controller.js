const Sms = require('../models/sms')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  errorResponse,
  failResponse,
  successResponse,
} = require('../helpers/httpResponse')

const send = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let response = await Sms.send(req.body)
    if (response.sid) {
      res.json(successResponse())
    } else {
      res.json(failResponse('No se pudo mandar mensaje'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al enviar sms'))
      return
    }
    res.status(500).json(errorResponse('Al mandar mensaje'))
  }
}

module.exports = { send }
