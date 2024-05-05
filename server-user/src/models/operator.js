const { pool } = require('../databases/apal')

const createOperator = async (
  { fullName, userName, pin, date, vehicleId },
  userId
) => {
  const sql = `insert into OPERATOR(fullName, userName, pin, date, vehicleId, userId) 
    values(
      '${fullName}', 
      '${userName}', 
      '${pin}', 
      '${date}',
      ${vehicleId},
      ${userId}
    )`
  const response = await pool.query(sql)

  return response
}

module.exports = { createOperator }
