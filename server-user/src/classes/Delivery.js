const { pool } = require('../databases/apal')

class Delivery {
  static async getTotalOrders(deliveryId) {
    const results = await pool.query(`call TOTAL_ORDERS(${deliveryId})`)

    let total = results[0].length == 0 ? null : results[0][0].total
    return total
  }
  static async getDetail(deliveryId) {
    const results = await pool.query(`call DELIVERY_DETAIL(${deliveryId})`)
    return results[0].length == 0 ? null : results[0][0]
  }
  static async getOrders(deliveryId) {
    const results = await pool.query(`call DELIVERY_ORDERS(${deliveryId})`)
    return results[0].length == 0 ? null : results[0]
  }
  static async getClient(deliveryId) {
    const results = await pool.query(`call DELIVERY_CLIENT(${deliveryId})`)
    return results[0].length == 0 ? null : results[0][0]
  }
  static async exists(deliveryId) {
    const results = await pool.query(`call EXISTS_DELIVERY(${deliveryId})`)

    return results[0].length > 0 //true : exist, false: no exists
  }
}

module.exports = Delivery
