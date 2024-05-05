const Vehicle = require('../models/vehicle')
const User = require('../classes/User')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')

const {
  errorResponse,
  successResponse,
  failResponse,
} = require('../helpers/httpResponse')

const getVehicles = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let vehicles = await User.getVehicles(auth.data.id)

    res.json(successResponse({ vehicles }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener vehiculos de usuario'))
      return
    }
    res.json(errorResponse(`Al obtener vehiculos de usuario: ${error}`))
  }
}
const updateVehicle = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    await Vehicle.updateVehicle(req.params.id, req.body)

    res.json(successResponse())
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al actualizar vehiculo de usuario'))
      return
    }
    res.json(errorResponse(`Al actualizar vehiculo de usuario: ${error}`))
  }
}
const getByStatus = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let vehicles = await User.getVehiclesByStatus(
      auth.data.id,
      req.params.status
    )

    if (vehicles) {
      res.json(successResponse({ vehicles }))
    } else {
      res.json(
        failResponse('No se pudieron obtener vehiculos de usuario con status')
      )
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(
        failResponse(
          'Token invalido al obtener vehiculos de usuario por status'
        )
      )
      return
    }
    res.json(errorResponse(`Al obtener vehiculos ${error}`))
  }
}

module.exports = {
  getVehicles,
  updateVehicle,
  getByStatus,
}
