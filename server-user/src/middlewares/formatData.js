const formatData = (req, res, next) => {
  let data = req.dataFile.content
  data.shift()

  const dataFormated = []
  data.forEach((el) => {
    dataFormated.push({
      numero_guia: el[0],
      vehiculo: el[1],
      nombre_item: el[2],
      cantidad: el[3],
      codigo_item: el[4],
      identificador_contacto: el[5],
      nombre_contacto: el[6],
      telefono: el[7],
      email_contacto: el[8] ? el[8] : "",
      direccion: el[9],
      latitud: el[10],
      longitud: el[11],
      fecha_min_entrega: el[12] ? el[12] : "",
      fecha_max_entrega: el[13] ? el[13] : "",
      ct_destino: el[14],
      tiempo_servicio: el[15],
    })
  })
  req.dataFile.content = dataFormated

  next()
}

module.exports = formatData
