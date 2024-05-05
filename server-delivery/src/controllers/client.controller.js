const Delivery = require('../classes/Delivery')

const {
  errorResponse,
  successResponse,
  failResponse,
} = require('../helpers/httpResponse')

const getClient = async (req, res) => {
  try {
    let client = await Delivery.getClient(req.params.deliveryId)

    if (client) {
      res.json(successResponse({ client }))
    } else {
      res.json(failResponse('La entrega no existe'))
    }
  } catch (error) {
    res.json(errorResponse('Al obtener cliente de entrega' + error))
  }
}
module.exports = { getClient }
