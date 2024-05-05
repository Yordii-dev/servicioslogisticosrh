const Tracking = require('../models/tracking')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const getTrackin = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let tracking = await Tracking.getTrackin(auth.data.id, req.params.date)

    res.status(200).json(successResponse({ tracking }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener tracking de usuario'))
      return
    }
    res
      .status(400)
      .json(errorResponse(`Al obtener tracking de usuario: ${error}`))
  }
}

module.exports = { getTrackin }
