const app = require('./app')
const PORT = process.env.PORT || 4001

const HOST = process.env.NODE_ENV == "development" ? 'localhost' : process.env.HOSTNAME 

app.listen(PORT, () => {
  console.log(`http://${HOST}:${PORT}/server-user`, process.env.NODE_ENV)
})
