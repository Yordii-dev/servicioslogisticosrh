const Load = require('../models/load')
const jwt = require('../helpers/jwt')
const { JsonWebTokenError } = require('jsonwebtoken')
const {
  errorResponse,
  successResponse,
  failResponse,
} = require('../helpers/httpResponse')
const removeFile = require('../helpers/removeFile')

const getLoads = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let loads = await Load.getLoads(auth.data.id)

    res.json(successResponse({ loads }))
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener cargas de usuario'))
      return
    }
    res
      .status(400)
      .json(errorResponse(`Al obtener las cargas de usuario, ${error}`))
  }
}
const getLoad = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let load = await Load.getLoad(auth.data.id, req.params.date)

    if (load) {
      res.json(successResponse({ load }))
    } else {
      res.json(failResponse('No se obtuvo la carga'))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al obtener carga de usuario'))
      return
    }
    res.status(400).json(errorResponse(`Al obtener carga de usuario, ${error}`))
  }
}
const insertLoad = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let response = await Load.insertLoad(auth.data.id, req.dataFile, req.body)

    res.json(response)
  } catch (error) {
    removeFile(`src/uploads/${req.dataFile.name}`)
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al insertar carga de usuario'))
      return
    }
    res
      .status(400)
      .json(errorResponse(`Al insertar la carga de usuario, ${error}`))
  }
}
const deleteLoad = async (req, res) => {
  try {
    const auth = jwt.verify(req.token)
    let response = await Load.deleteLoad(req.params.id)

    if (response.affectedRows > 0) {
      res.json(successResponse())
    } else {
      res.json(failResponse(`No se pudo eliminar la carga`))
    }
  } catch (error) {
    if (error instanceof JsonWebTokenError) {
      res.json(failResponse('Token invalido al eliminar carga'))
      return
    }
    res.status(400).json(errorResponse(`Al eliminar la carga, ${error}`))
  }
}

const bang = async (req, res) => {
  try {
    let response = await Load.bang()
    if (response.length > 0) {
      res.json(successResponse())
    } else {
      res.json(failResponse(`No se pudo realizar BANG, sin cargas`))
    }
  } catch (error) {
    res.status(400).json(errorResponse(`Al realizar BANG , ${error}`))
  }
}

module.exports = { getLoads, getLoad, insertLoad, deleteLoad, bang }
