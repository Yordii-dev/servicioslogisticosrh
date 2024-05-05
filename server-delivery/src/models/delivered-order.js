const { pool } = require('../databases/apal')

const createDelivered = async ({ amount, orderId }) => {
  const response = await pool.query(
    `insert into DELIVERED_ORDER(amount, orderId) 
    values(${amount}, ${orderId})
    ON DUPLICATE KEY UPDATE amount=${amount}`
  )
  return response
}

module.exports = { createDelivered }
