const { pool } = require('../databases/apal.js')
const Vehicle = require('../classes/Vehicle')
const User = require('../classes/User.js')

const createRoute = async ({ vehicleId, id: operatorId }, { date }) => {
  let total = await Vehicle.getTotalDeliveries(vehicleId, 'latest')
  if (total == 0) return 'No se encontraron entregas para este operador'

  let userId = await Vehicle.getOwnerUser(vehicleId)
  if (!userId) return 'No se encontro el usuario de este operador'

  let lastLoad = await User.getLoad(userId, 'latest')

  if (!lastLoad) return 'No se encontro ultima fecha de importacion'

  const sql = `insert into 
  ROUTE(status, totalDeliveries, date, operatorId, loadId)   
  values('En Ruta', ${total}, '${date}', ${operatorId}, ${lastLoad.id})`

  const response = await pool.query(sql)

  return response
}
module.exports = { createRoute }
