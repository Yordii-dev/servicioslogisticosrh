const Operator = require('../classes/Operator')

async function getManageds(operatorId, date) {
  let manageds = await Operator.getManaged(operatorId, date)

  let delivered = manageds.filter((el) => el.status == 'Entregado')
  let partial = manageds.filter((el) => el.status == 'Entrega Parcial')
  let notDelivered = manageds.filter((el) => el.status == 'No Entregado')
  return {
    total: manageds.length,
    status: {
      delivered: delivered.length,
      partial: partial.length,
      notDelivered: notDelivered.length,
    },
  }
}

async function getStatusRoute(operatorId) {
  const route = await Operator.getRoute(operatorId, 'latest')

  let status = route ? route.status : 'Ruta no iniciada'
  return status
}

module.exports = {
  getManageds,
  getStatusRoute,
}
