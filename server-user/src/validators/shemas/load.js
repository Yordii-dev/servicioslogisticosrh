let loadShema = {
  numero_guia: {
    type: Number,
    required: true,
  },
  vehiculo: {
    type: String,
    required: true,
    length: {
      min: 6,
    },
  },
  nombre_item: {
    type: String,
    required: true,
    length: {
      min: 5,
    },
  },
  cantidad: {
    type: Number,
    required: true,
  },
  codigo_item: {
    type: Number,
    required: true,
  },
  identificador_contacto: {
    type: Number,
    required: true,
  },
  nombre_contacto: {
    type: String,
    required: true,
    length: {
      min: 5,
    },
  },
  /*   telefono: {
    type: String,
    required: true,
    length: {
      min: 9,
    },
  }, */
  email_contacto: {
    type: String,
    required: true,
  },
  /* direccion: {
    type: String,
    required: true,
    length: {
      min: 5,
    },
  },
  latitud: {
    type: String,
    required: true,
    length: {
      min: 5,
    },
  },
  longitud: {
    type: String,
    required: true,
    length: {
      min: 5,
    },
  }, */
  fecha_min_entrega: {
    type: String,
    required: true,
  },
  fecha_max_entrega: {
    type: String,
    required: true,
  },
  /*   ct_destino: {
    type: String,
    required: true,
  }, */
  tiempo_servicio: {
    type: Number,
    required: true,
  },
}

module.exports = loadShema
