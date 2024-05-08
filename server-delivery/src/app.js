const express = require("express");
const fs = require("fs");
const https = require("https");
const cors = require("cors");

let app = express();

app = https.createServer(
  {
    cert: fs.readFileSync("./servicioslogisticosrh.crt"),
    key: fs.readFileSync("./llave.key"),
    passphrase: "12345",
  },
  app
);

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use("/server-delivery", require("./routes/"));

module.exports = app;
