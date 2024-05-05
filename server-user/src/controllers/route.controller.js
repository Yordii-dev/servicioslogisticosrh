const User = require('../classes/User')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  errorResponse,
  failResponse,
} = require('../helpers/httpResponse')

const getRoutes = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let routes = await User.getRoutes(auth.data.id, req.params.date)

    if (routes) {
      res.json(successResponse({ routes }))
    } else {
      res.json(failResponse('Rutas no obtenidas'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al rutas de usuario'))
      return
    }
    res.status(500).json(errorResponse('Al obtener rutas de usuario' + error))
  }
}

module.exports = { getRoutes }
