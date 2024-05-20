const express = require("express");
const fs = require("fs");
const https = require("https");
const cors = require("cors");

const app = express();

const servidorHTTPS = https.createServer(
  {
    cert: fs.readFileSync("./crt/servicioslogisticosrh.crt"),
    key: fs.readFileSync("./crt/llave.key"),
    passphrase: "12345",
  },
  app
);

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use("/server-delivery", require("./routes/"));

module.exports = servidorHTTPS;
