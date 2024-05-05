const User = require('../classes/User')
const jwt = require('../helpers/jwt')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const signIn = async (req, res) => {
  try {
    let user = await User.getUserByName(req.body.name)
    if (user) {
      const token = jwt.sign(user)
      res.json(successResponse({ token }))
    } else {
      res.json(failResponse('El usuario no existe. Token no obtenido'))
    }
  } catch (error) {
    res
      .status(500)
      .json(errorResponse(`Al iniciar sesion de usuario, ${error}`))
  }
}

module.exports = { signIn }
