const User = require('../classes/User')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const getManaged = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let managed = await User.getManaged(auth.data.id, req.params.date)

    res.json(successResponse({ managed }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener gestiones de usuario'))
      return
    }
    res.status(500).json(errorResponse('Al obtener gestiones de usuario'))
  }
}

const getTotal = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let total = await User.getTotalManaged(auth.data.id, req.params.date)
    if (total) {
      res.json(successResponse({ total }))
    } else {
      res.json(failResponse('No se obtuvo total de gestiones'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener total de gestiones de usuario'))
      return
    }
    res.status(500).json(errorResponse('Al obtener total de gestiones de usuario'))
  }
}
module.exports = { getManaged, getTotal }
