const db = require('../databases/apal.js')
const util = require('util')
const User = require('../classes/User')

const { successResponse, failResponse } = require('../helpers/httpResponse')

const removeFile = require('../helpers/removeFile')

const getLoads = async (userId) => {
  let loads = User.getLoads(userId)
  return loads
}

const getLoad = async (userId, date) => {
  if (date == 'latest') {
    let lastDate = await User.getLastLoadDate(userId)
    if (!lastDate) return null

    let load = await User.getLoad(userId, lastDate)
    return load
  }
  if (date == 'first') {
    let firstDate = await User.getFirstLoadDate(userId)
    if (!firstDate) return null

    let load = await User.getLoad(userId, firstDate)
    return load
  }

  let load = await User.getLoad(userId, date)
  return load
}

const insertLoad = async (userId, { name, content }, { date }) => {
  let connection = await db.getConnection()
  try {
    await db.beginTransaction(connection)
    const query = util.promisify(connection.query)

    let tableLoad = '`LOAD`',
      tableOrder = '`ORDER`'

    let loadId, vehicleId

    //Load
    let response = await query.call(
      connection,
      `insert into ${tableLoad}(fileName, date, userId) values(
        '${name}', 
        '${date}',
        ${userId}
        )`
    )

    if (response.affectedRows == 0)
      throw 'No se inserto carga en Load (No se obtuvo loadId)'
    loadId = response.insertId

    // Finish routes
    await query.call(
      connection,
      `call CHANGE_ROUTES_STATUS(${userId}, 'Finalizada')`
    )

    // Finish vehicles
    await query.call(
      connection,
      `call CHANGE_VEHICLES_STATUS(${userId}, 'No activo')`
    )

    for (const el of content) {
      //Vehicles

      let response = await query.call(
        connection,
        `insert into VEHICLE(patent, status, groupId, userId) values
        ('${el.vehiculo}', 'Activo', null, ${userId}) 
        
        ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id), status = 'Activo'`
      )

      if (response.affectedRows == 0)
        throw 'No se inserto carga en Load (No se obtuvo vehicleId)'

      vehicleId = response.insertId //Obtengo vehicleId insertado o actualizado

      //Clients
      await query.call(
        connection,
        `insert IGNORE into CLIENT values(
            ${el.identificador_contacto},
            '${el.nombre_contacto}',
            '${el.telefono}',
            '${el.email_contacto}',
            '${el.direccion}',
            '${el.latitud}',
            '${el.longitud}'
          )`
      )

      //Items
      await query.call(
        connection,
        `insert IGNORE into ITEM values(
            ${el.codigo_item},
            '${el.nombre_item}'  
          )`
      )

      //Deliveries
      await query.call(
        connection,
        `insert IGNORE into DELIVERY 
        values(
        ${el.numero_guia},
        '${el.fecha_min_entrega}',
        '${el.fecha_max_entrega}',
        '${el.ct_destino}',
        '${el.tiempo_servicio}',
        ${vehicleId},
        ${loadId},
        ${el.identificador_contacto}
      )`
      )

      //Orders
      await query.call(
        connection,
        `insert into ${tableOrder}(amount, itemId, deliveryId) 
        values(
        ${el.cantidad},
        ${el.codigo_item},        
        ${el.numero_guia}
      )`
      )
    }

    await db.commit(connection)
    return successResponse({ loadId }) //Mandamos loadId por si queremos eliminar la carga
  } catch (error) {
    await db.rollback(connection)
    removeFile(`src/uploads/${name}`)
    return failResponse(
      `La data del archivo no se ha podido almacenar, ${error}`
    )
  } finally {
    await connection.release()
  }
}

const deleteLoad = async (id) => {
  let loadTable = '`LOAD`'
  const sql = `delete from ${loadTable} where id = ${id}`
  const response = await db.pool.query(sql)
  return response
}

const bang = async () => {
  let loadTable = '`LOAD`'
  const sql = `delete from ${loadTable} where id = `

  const loads = await User.getLoads(1) //Get First user loads
  const LoadsForDelete = loads.map(async ({ id }) => {
    const el = await db.pool.query(sql + id)
    return el
  })

  const response = await Promise.all(LoadsForDelete)
  return response
}
module.exports = { getLoads, getLoad, insertLoad, deleteLoad, bang }
