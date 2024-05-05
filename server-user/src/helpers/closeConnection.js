const pool = require("../databases/apal")
beforeAll((done) => {
  done()
})

afterAll((done) => {
  // Closing the DB connection allows Jest to exit successfully.
  pool.end()
  done()
})
