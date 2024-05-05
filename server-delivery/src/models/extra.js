const pool = require('../databases/two.js')

const getPrice = async (deliveryId) => {
  const sql = `select                 
  sum(tbl_factura.impuesto_pos + tbl_factura.impuesto_fact_pos) 
  'price'
  from tbl_factura where doc_venta = '${deliveryId}'
  group by doc_venta`

  const results = await pool.query(sql)
  let price = results.length == 0 ? null : results[0].price
  return price
}
const getManager = async (deliveryId) => {
  const sql = `select 
  tbl_tlv_ped.num_pedido,  
  tbl_dat_gest.cod_rut 'cod', 
  tbl_dat_gest.nombre 'name',
  tbl_dat_gest.celular 'phone'

  from tbl_tlv_ped 
  join tbl_dat_gest on tbl_tlv_ped.usuario_final = tbl_dat_gest.raz
  where num_pedido = '${deliveryId}'`

  const results = await pool.query(sql)
  let manager = results.length == 0 ? null : results[0]
  return manager
}

const getSupervisor = async (deliveryId) => {
  const sql = `select 
  tbl_tlv_ped.num_pedido,  
  tbl_dat_gest.supervisor 'name',
  tbl_dat_gest.celular_personal 'phone'

  from tbl_tlv_ped 
  join tbl_dat_gest on tbl_tlv_ped.usuario_final = tbl_dat_gest.raz
  where num_pedido = '${deliveryId}'`

  const results = await pool.query(sql)
  let supervisor = results.length == 0 ? null : results[0]
  return supervisor
}
module.exports = { getPrice, getManager, getSupervisor }
