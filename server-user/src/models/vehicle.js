const { pool } = require('../databases/apal')

const updateVehicle = async (vehicleId, data) => {
  for (const field in data) {
    let newValue = data[field]
    const response = await pool.query(
      `UPDATE VEHICLE
      SET ${field} = ${newValue}
      WHERE VEHICLE.id = ${vehicleId}`
    )
  }
}

module.exports = {
  updateVehicle,
}
