const Group = require('../models/group')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  successResponse,
  failResponse,
  errorResponse,
} = require('../helpers/httpResponse')

const getGroups = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)

    let groups = await Group.getGroups(auth.data.id)
    res.json(successResponse({ groups }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener grupos de usuario'))
      return
    }
    res.json(errorResponse('Al obtener grupos de usuario'))
  }
}
const createGroup = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)

    let response = await Group.createGroup(auth.data.id, req.body)
    if (response.affectedRows != 0) {
      res.json(successResponse())
    } else {
      res.json(failResponse('No se pudo crear grupo'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al crear grupo del usuario'))
      return
    }
    res.json(errorResponse('Al crear grupo del usuario'))
  }
}

module.exports = { createGroup, getGroups }
