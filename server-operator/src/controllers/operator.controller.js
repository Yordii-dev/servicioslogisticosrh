const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  errorResponse,
  failResponse,
} = require('../helpers/httpResponse')
const getSelf = (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    res.json(
      successResponse({
        operator: { id: auth.data.id, patent: auth.data.patent },
      })
    )
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener operador actual'))
      return
    }
    res
      .status(500)
      .json(errorResponse('Al obtener datos de este operador' + error))
  }
}
module.exports = { getSelf }
