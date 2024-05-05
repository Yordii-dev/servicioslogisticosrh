const { getUsersFromTwo } = require('../helpers/initial')
const { pool } = require('../databases/apal')
const { successResponse, failResponse } = require('../helpers/httpResponse')

const initialUsers = async () => {
  const users = await getUsersFromTwo()

  for (const user of users) {
    let response = await pool.query(`insert IGNORE into USER(name) 
      values('${user.correo}')`)

   /* if (response.affectedRows != 0) continue

   return failResponse(
      'No se pudo inicializar algunos o la totalidad de usuarios Two en Apal ' +  pool._freeConnections.length
   )*/
  }

  return successResponse({users})
}

module.exports = { initialUsers }
