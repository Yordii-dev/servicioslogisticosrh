const UserClass = require('../classes/User')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')

const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const getSelf = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    res.json(
      successResponse({
        user: { id: auth.data.id, name: auth.data.name },
      })
    )
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener usuario actual'))
      return
    }
    res.status(400).json(errorResponse(`Al obtener usuario actual, ${error}`))
  }
}

const getUser = async (req, res) => {
  try {
    let user = await UserClass.getUser(req.params.id)
    if (user) {
      res.json(successResponse({ user }))
    } else {
      res.json(failResponse('El usuario no existe'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener usuario'))
      return
    }
    res.status(500).json(errorResponse('Al obtener usuario' + error))
  }
}

module.exports = { getSelf, getUser }
