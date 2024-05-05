const Validator = require('schema-validator')
const Vehicle = require('../classes/Vehicle')
const Delivery = require('../classes/Delivery')
const jwt = require('../helpers/jwt')
const { formatShemaError } = require('../helpers/load')
const { failResponse, errorResponse } = require('../helpers/httpResponse')
const loadShema = require('./shemas/load')
const removeFile = require('../helpers/removeFile')

const mustNotBeEmpty = (req, res, next) => {
  try {
    let content = req.dataFile.content

    if (content.length == 0) {
      removeFile(`src/uploads/${req.dataFile.name}`)
      res.send(failResponse('El documento no debe estar vacio'))
    } else next()
  } catch (error) {
    removeFile(`src/uploads/${req.dataFile.name}`)
    res.send(errorResponse('Al validar que el documento no este vacio'))
  }
}

const matchShema = (req, res, next) => {
  try {
    let error = false
    let validator = new Validator(loadShema)
    let content = req.dataFile.content

    for (let i = 0; i < content.length; i++) {
      let check = validator.check(content[i])

      if (check._error) {
        removeFile(`src/uploads/${req.dataFile.name}`)
        error = true

        res.send(
          failResponse(
            'Error al validar cuerpo del documento (Formato invalido)',
            formatShemaError(check)
          )
        )
        break
      }
    }

    if (!error) next()
  } catch (error) {
    removeFile(`src/uploads/${req.dataFile.name}`)
    res.send(
      errorResponse(
        'Al validar que el documento cumpla con la estructura establecida' +
          error
      )
    )
  }
}

const uniqueVehicles = async (req, res, next) => {
  try {
    let error = false

    let content = req.dataFile.content
    let onlyVehicles = content.map((el) => el.vehiculo)
    onlyVehicles = new Set(onlyVehicles)

    const auth = jwt.verify(req.token)

    for (const patent of onlyVehicles) {
      let userId = await Vehicle.getOwnerUserByPatent(patent)

      //Aun no tiene propietario, continuo a validar otro vehiculo
      if (!userId) continue

      if (userId != auth.data.id) {
        removeFile(`src/uploads/${req.dataFile.name}`)
        error = true
        res.send(
          failResponse(
            `El vehiculo '${patent}' pertenece a un usuario distinto. Por favor no considerarlo`
          )
        )
        break
      }
    }
    if (!error) next()
  } catch (error) {
    removeFile(`src/uploads/${req.dataFile.name}`)
    res.send(errorResponse('Al validar propiedad vehicular'))
  }
}

const uniqueDeliveries = async (req, res, next) => {
  try {
    let error = false

    let content = req.dataFile.content
    let onlyDeliveriesId = content.map((el) => el.numero_guia)
    onlyDeliveriesId = new Set(onlyDeliveriesId)

    for (const deliveryId of onlyDeliveriesId) {
      let exists = await Delivery.exists(deliveryId)

      //Aun no ha sido usado, continuo a validar otra entrega
      if (!exists) continue

      if (exists) {
        removeFile(`src/uploads/${req.dataFile.name}`)
        error = true
        res.send(
          failResponse(
            `La entrega con codigo '${deliveryId}' ya ha sido incluida por un usuario distinto o por ti mismo en archivos anteriores. Por favor no considerarla`
          )
        )
        break
      }
    }
    if (!error) next()
  } catch (error) {
    removeFile(`src/uploads/${req.dataFile.name}`)
    res.send(errorResponse(`Al validar propiedad de entregas ${error}`))
  }
}

const parseFields = async (req, res, next) => {
  try {
    let content = req.dataFile.content

    for (const el of content) {
      for (const property in el) {
        let value = el[property]
        if (typeof value === 'string') {
          el[property] = value.replace(/'/g, '`')
        }
      }
    }
    next()
  } catch (error) {
    removeFile(`src/uploads/${req.dataFile.name}`)
    res.send(
      errorResponse(
        `Al eliminar caracteres no validos de cada campo del archivo ${error}`
      )
    )
  }
}

module.exports = [
  mustNotBeEmpty,
  matchShema,
  uniqueVehicles,
  uniqueDeliveries,
  parseFields,
]
