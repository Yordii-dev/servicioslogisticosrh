const { pool } = require('../databases/apal.js')
const createEvidence = async (
  { name: imageName },
  { comment, date, deliveryId }
) => {
  let sql = `insert into EVIDENCED_DELIVERY(comment, imageName, date, deliveryId) 
  values(
    '${comment}',
    '${imageName}',
    '${date}',
    ${deliveryId}
  )`

  const response = await pool.query(sql)
  return response
}
module.exports = { createEvidence }
