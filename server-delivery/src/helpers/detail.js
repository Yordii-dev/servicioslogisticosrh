const { pool } = require('../databases/apal.js')

const createManagedDelivery = async (
  deliveryId,
  { status, subStatus, date }
) => {
  let sql = `insert into MANAGED_DELIVERY(status, subStatus, date, deliveryId) 
  values(
    '${status}', 
    '${subStatus}', 
    '${date}', 
    ${deliveryId}
    )`
  const response = await pool.query(sql)

  return response
}

const createManagedOrders = async (deliveryId, { date }) => {
  let sql = `insert into MANAGED_ORDERS(date, deliveryId) 
    values(
      '${date}', 
      ${deliveryId}
    )`

  const response = await pool.query(sql)
  return response
}

module.exports = { createManagedDelivery, createManagedOrders }
