const Operator = require('../models/operator')
const User = require('../classes/User')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const getOperators = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)

    let operators = await User.getOperators(auth.data.id)
    res.json(successResponse({ operators }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener operadores de usuario'))
      return
    }
    res
      .status(400)
      .json(errorResponse(`Al obtener operadores de usuario, ${error}`))
  }
}

const createOperator = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let response = await Operator.createOperator(req.body, auth.data.id)

    if (response.affectedRows != 0) {
      res.status(200).json(successResponse())
    } else {
      res.status(200).json(failResponse('No se pudo crear operador'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al crear operador de usuario'))
      return
    }
    res
      .status(500)
      .json(errorResponse(`Al crear operador de usuario, ${error}`))
  }
}

const getByStatus = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let operators = await User.getOperatorByStatus(
      auth.data.id,
      req.params.status
    )

    if (operators) {
      res.json(successResponse({ operators }))
    } else {
      res.json(
        failResponse('No se pudieron obtener operadores de usuario con status')
      )
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(
        failResponse(
          'Token invalido al obtener operadores de usuario con status'
        )
      )
      return
    }
    res
      .status(400)
      .json(
        errorResponse(`Al obtener operadores de usuario con status, ${error}`)
      )
  }
}

//Los 'public_' se puede acceder sin token
const public_getByStatus = async (req, res) => {
  try {
    let operators = await User.getOperatorByStatus(
      req.params.userId,
      req.params.status
    )

    if (operators) {
      res.json(successResponse({ operators }))
    } else {
      res.json(
        failResponse('No se pudieron obtener operadores de usuario con status')
      )
    }
  } catch (error) {
    res
      .status(400)
      .json(
        errorResponse(`Al obtener operadores de usuario con status, ${error}`)
      )
  }
}

module.exports = {
  getOperators,
  createOperator,
  getByStatus,
  public_getByStatus,
}
