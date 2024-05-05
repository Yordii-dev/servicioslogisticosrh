const Operator = require('../classes/Operator')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  errorResponse,
  failResponse,
} = require('../helpers/httpResponse')

const getManaged = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let managed = await Operator.getManaged(auth.data.id, req.params.date)

    res.json(successResponse({ managed }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener gestiones de operador'))
      return
    }
    res.status(500).json(errorResponse('Al obtener gestiones de operador'))
  }
}

const getTotal = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)

    let total = await Operator.getTotalManaged(auth.data.id, req.params.date)
    if (total != null) {
      res.json(successResponse({ total }))
    } else {
      res.json(failResponse('No se obtuvo total de gestiones'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener operador actual'))
      return
    }
    res
      .status(500)
      .json(errorResponse('Al obtener total de gestiones de operador'))
  }
}
module.exports = { getManaged, getTotal }
