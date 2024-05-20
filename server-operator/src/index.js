const servidorHTTPS = require("./app");
const PORT = process.env.PORT || 4002;

const HOST =
  process.env.NODE_ENV == "development" ? "localhost" : process.env.HOSTNAME;

servidorHTTPS.listen(PORT, () => {
  console.log(`https://${HOST}:${PORT}/server-operator`);
});
