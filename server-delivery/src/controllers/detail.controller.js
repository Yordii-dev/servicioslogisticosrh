const DeliveryDetails = require('../models/detail')
const Delivery = require('../classes/Delivery')
const {
  successResponse,
  errorResponse,
  failResponse,
} = require('../helpers/httpResponse')

const getDetail = async (req, res) => {
  try {
    let detail = await Delivery.getDetail(req.params.deliveryId)

    if (detail) {
      res.json(successResponse({ detail }))
    } else {
      res.json(failResponse('Esta entrega no existe'))
    }
  } catch (error) {
    res.status(500).json(errorResponse('Al obtener detalle de entrega' + error))
  }
}

const updateDetail = async (req, res) => {
  try {
    let response = await DeliveryDetails.updateDetail(
      req.params.deliveryId,
      req.body
    )

    if (response.affectedRows != 0) {
      res.json(successResponse())
    } else {
      res.json(failResponse('No se pudo actualizar el detalle'))
    }
  } catch (error) {
    res
      .status(500)
      .json(errorResponse('Al actualizar detalle de entrega' + error))
  }
}
module.exports = { getDetail, updateDetail }
