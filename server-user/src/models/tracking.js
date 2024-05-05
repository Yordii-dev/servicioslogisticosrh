const Vehicle = require('../classes/Vehicle')
const User = require('../classes/User')
const { getStatusRoute, getManageds } = require('../helpers/tracking')

const getTrackin = async (userId, date) => {
  let data = []
  let vehicles = await User.getVehicles(userId)

  for (const vehicle of vehicles) {
    const patent = vehicle.patent

    const total = await Vehicle.getTotalDeliveries(vehicle.id, date)

    // El vehiculo no esta incluido en la importacion
    if (total == 0) continue

    const operatorId = await Vehicle.getOperator(vehicle.id)
    let statusRoute = await getStatusRoute(operatorId)

    if (operatorId) {
      let manageds = await getManageds(operatorId, date)

      data.push({
        vehicle: patent,
        info: {
          assigned: total,
          managed: manageds.total,
        },
        managed: manageds.status,
        statusRoute,
      })
    } else {
      data.push({
        vehicle: patent,
        info: {
          assigned: total,
          managed: 0,
        },
        managed: {
          delivered: 0,
          partial: 0,
          notDelivered: 0,
        },
        statusRoute: 'Sin operador asignado',
      })
    }
  }

  return data
}

module.exports = { getTrackin }
