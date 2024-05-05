const Operator = require('../classes/Operator')
const jwt = require('../helpers/jwt')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const signIn = async (req, res) => {
  try {
    let operator = await Operator.getOperatorByVehicleIdAndPin(
      req.body.vehicleId,
      req.body.pin
    )

    if (operator) {
      const token = jwt.sign(operator)
      res.json(successResponse({ token }))
    } else {
      res.json(failResponse('El operador no existe. Token no obtenido'))
    }
  } catch (error) {
    res
      .status(500)
      .json(errorResponse(`Al iniciar sesion de operador, ${error}`))
  }
}

module.exports = { signIn }
