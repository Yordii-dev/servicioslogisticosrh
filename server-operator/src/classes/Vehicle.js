const { pool } = require('../databases/apal')

class Vehicle {
  static async getOwnerUser(vehicleId) {
    const results = await pool.query(
      `SET @userId = 0; 
       call OWNER_USER(${vehicleId}, @userId); 
       SELECT @userId 'userId'`
    )

    let userId = results[2].length == 0 ? null : results[2][0].userId
    return userId
  }

  static async getOperator(vehicleId) {
    const results = await pool.query(`
    set @operatorId = 0;
    call OPERATOR(${vehicleId}, @operatorId);
    select @operatorId 'operatorId'
    `)
    return results[2].length == 0 ? null : results[2][0].operatorId
  }

  static async getOwnerUserByPatent(patent) {
    const results = await pool.query(
      `SET @userId = 0; 
       call OWNER_USER_BY_PATENT('${patent}', @userId); 
       SELECT @userId 'userId'`
    )

    let userId = results[2].length == 0 ? null : results[2][0].userId
    return userId
  }

  static async getDeliveries(vehicleId, date) {
    let sql =
      date === 'latest'
        ? `call DELIVERIES(${vehicleId}, null)`
        : `call DELIVERIES(${vehicleId}, '${date}')`

    const results = await pool.query(sql)
    return results[0]
  }

  static async getTotalDeliveries(vehicleId, date) {
    let sql =
      date === 'latest'
        ? `call TOTAL_DELIVERIES(${vehicleId}, null)`
        : `call TOTAL_DELIVERIES(${vehicleId}, '${date}')`

    const results = await pool.query(sql)

    let total = results[0].length == 0 ? null : results[0][0].total
    return total
  }
}

module.exports = Vehicle
