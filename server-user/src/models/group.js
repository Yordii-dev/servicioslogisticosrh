const { pool } = require('../databases/apal.js')
const User = require('../classes/User')

const getGroups = async (userId) => {
  let groups = User.getGroups(userId)
  return groups
}
const createGroup = async (userId, { name, date }) => {
  let tableGroup = '`GROUP`'
  const sql = `insert into ${tableGroup}(name, date, userId) 
    values('${name}', '${date}', ${userId})`

  const response = await pool.query(sql)
  return response
}
module.exports = { getGroups, createGroup }
