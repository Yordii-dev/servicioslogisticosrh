const { pool } = require('../databases/apal')

class Operator {
  static async getOperatorByVehicleIdAndPin(vehicleId, pin) {
    const results = await pool.query(
      `call OPERATOR_BY_VEHICLEID_AND_PIN(${vehicleId}, '${pin}')`
    )
    let operator = results[0].length == 0 ? null : results[0][0]
    return operator
  }
  static async getVehicle(operatorId) {
    const results = await pool.query(
      `SET @vehicleId = ''; 
         call VEHICLE(${operatorId}, @vehicleId); 
         SELECT @vehicleId 'vehicleId'`
    )

    let vehicleId = results[2].length == 0 ? null : results[2][0].vehicleId
    return vehicleId
  }

  static async getRoute(operatorId, date) {
    let sql =
      date === 'latest'
        ? `call ROUTE(${operatorId}, null)`
        : `call ROUTE(${operatorId}, '${date}')`

    const results = await pool.query(sql)

    let route = results[0].length == 0 ? null : results[0][0]
    return route
  }

  static async getTotalManaged(operatorId, date) {
    let sql =
      date === 'latest'
        ? `call OPERATOR_TOTAL_MANAGED(${operatorId}, null)`
        : `call OPERATOR_TOTAL_MANAGED(${operatorId}, '${date}')`

    const results = await pool.query(sql)

    let total = results[0].length == 0 ? null : results[0][0].total
    return total
  }

  static async getManaged(operatorId, date) {
    let sql =
      date === 'latest'
        ? `call OPERATOR_MANAGED(${operatorId}, null)`
        : `call OPERATOR_MANAGED(${operatorId}, '${date}')`

    const results = await pool.query(sql)

    return results[0]
  }
}

module.exports = Operator
