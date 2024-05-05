const mysql = require("mysql");

if (process.env.NODE_ENV == "development")
  require("dotenv").config({ path: `.env.development` });

const util = require("util");
 
const config = {
  host: process.env.DB_APAL_HOST,
  user: process.env.DB_APAL_USER,
  password: process.env.DB_APAL_PASSWORD,
  database: process.env.DB_APAL_DATABASE, 
  insecureAuth: true,
  multipleStatements: true,
}

const pool = mysql.createPool(config);

pool.getConnection((err, connection) => {
  if (err) {
    switch (err.code) {
      case "PROTOCOL_CONNECTION_LOST":
        console.log("DATABASE CONNECTION WAS CLOSED")
        break;
      case "ER_CON_COUNT_ERROR":
        console.log("DATABASE HAS TOO MANY CONNECTIONS")
        break;
      case "ECONNREFUSED":
        console.log("DATABASE CONNECTION WAS REFUSED")
        break;
      default:
        console.error("DATABASE CONNECTION ERROR:", err.code);
    }
  } else {
    connection.release();
    console.log("DB APAL is connected");
  }
});

pool.query = util.promisify(pool.query);
const getConnection = () => {
  return util.promisify(pool.getConnection).call(pool); //aquí usé call en vez de bind para hacer el return de una vez, si usaba el bind
  //tenía que primero hacer el bind, guardar eso en una variable y luego hacer el return de esa variable, ya que la diferencia entre bind y call
  // es que call llama inmediatamente a la función y bind crea una copia de la función pero no la llama, hay que llamar en una siguiente línea.
};

const beginTransaction = (connection) => {
  return util.promisify(connection.beginTransaction).call(connection);
};

const rollback = (connection) => {
  console.log("\n\nEjecutando Rollback...\n\n");
  return util.promisify(connection.rollback).call(connection);
};

const commit = (connection) => {
  return util.promisify(connection.commit).call(connection);
};

// const release= (connection)=> {
//  return util.promisify(connection.release).call(connection)
// }

module.exports = {
  pool,
  getConnection: getConnection,
  // query: query
  beginTransaction: beginTransaction,
  rollback: rollback,
  commit: commit,
};

/* module.exports = pool */
