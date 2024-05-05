const { pool } = require('../databases/apal')

class User {
  static async getUser(userId) {
    const results = await pool.query(`call USER(${userId})`)
    let user = results[0].length == 0 ? null : results[0][0]

    return user
  }

  static async getUserByName(nameUser) {
    const results = await pool.query(`call USER_BY_NAME('${nameUser}')`)
    let user = results[0].length == 0 ? null : results[0][0]

    return user
  }

  static async getLastLoadDate(userId) {
    const results = await pool.query(
      `SET @lastDate = ''; 
         call LAST_LOAD_DATE(${userId}, @lastDate); 
         SELECT @lastDate 'lastDate'
        `
    )
    let lastDate = results[2].length == 0 ? null : results[2][0].lastDate
    return lastDate
  }
  static async getFirstLoadDate(userId) {
    const results = await pool.query(
      `SET @firstDate = ''; 
         call FIRST_LOAD_DATE(${userId}, @firstDate); 
         SELECT @firstDate 'firstDate'
        `
    )
    let firstDate = results[2].length == 0 ? null : results[2][0].firstDate
    return firstDate
  }

  static async getLoads(userId) {
    const results = await pool.query(`call LOADS(${userId})`)

    return results[0]
  }

  static async getLoad(userId, date) {
    let spName = '`LOAD`'
    let sql =
      date === 'latest'
        ? `call ${spName}(${userId}, null)`
        : `call ${spName}(${userId}, '${date}')`

    const results = await pool.query(sql)

    return results[0].length == 0 ? null : results[0][0]
  }

  static async getGroups(userId) {
    let spName = '`GROUPS`'
    const results = await pool.query(`call ${spName}(${userId})`)

    return results[0]
  }

  static async getOperators(userId) {
    const results = await pool.query(`call OPERATORS(${userId})`)

    return results[0]
  }

  static async getOperatorByStatus(userId, status) {
    if (!status) return null
    const results = await pool.query(
      `call OPERATORS_BY_STATUS(${userId}, '${status}')`
    )
    return results[0]
  }

  static async getVehicles(userId) {
    const results = await pool.query(`call VEHICLES(${userId})`)

    return results[0]
  }

  static async getVehiclesByStatus(userId, status) {
    if (!status) return null
    const results = await pool.query(
      `call VEHICLES_BY_STATUS(${userId}, '${status}')`
    )
    return results[0]
  }

  static async changeVehiclesStatus(userId, status) {
    const results = await pool.query(
      `call CHANGE_VEHICLES_STATUS(${userId}, '${status}')`
    )

    return results[0]
  }

  static async changeRoutesStatus(userId, status) {
    const results = await pool.query(
      `call CHANGE_ROUTES_STATUS(${userId}, '${status}')`
    )

    return results[0]
  }

  static async getManaged(userId, date) {
    let sql =
      date === 'latest'
        ? `call USER_MANAGED(${userId}, null)`
        : `call USER_MANAGED(${userId}, '${date}')`

    const results = await pool.query(sql)

    return results[0]
  }

  static async getRoutes(userId, date) {
    let sql =
      date === 'latest'
        ? `call ROUTES(${userId}, null)`
        : `call ROUTES(${userId}, '${date}')`

    const results = await pool.query(sql)

    return results[0]
  }
}

module.exports = User
