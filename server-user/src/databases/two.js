const mysql = require("mysql");

if (process.env.NODE_ENV == "development")
  require("dotenv").config({ path: `.env.development` });

const { promisify } = require("util");

const config = {
  host: process.env.DB_TWO_HOST,
  user: process.env.DB_TWO_USER,
  password: process.env.DB_TWO_PASSWORD,
  database: process.env.DB_TWO_DATABASE,
  insecureAuth: true,
};

const poolTwo = mysql.createPool(config);

poolTwo.getConnection((err, connection) => {
  if (err) {
    switch (err.code) {
      case "PROTOCOL_CONNECTION_LOST":
        console.log("DATABASE CONNECTION WAS CLOSED");
        break;
      case "ER_CON_COUNT_ERROR":
        console.log("DATABASE HAS TOO MANY CONNECTIONS");
        break;
      case "ECONNREFUSED":
        console.log("DATABASE CONNECTION WAS REFUSED");
        break;
      default:
        console.error("DATABASE CONNECTION ERROR:", err.code);
    }
  } else {
    connection.release();
    console.log("DB APAL is connected");
  }
});

poolTwo.query = promisify(poolTwo.query);

module.exports = poolTwo;
