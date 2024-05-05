const Initial = require('../models/initial')
const { errorResponse } = require('../helpers/httpResponse')

const initialUsers = async (req, res) => {
  try {
    let response = await Initial.initialUsers()
    res.json(response)
  } catch (error) {
    res.status(500).json(errorResponse('Al iniciar usuarios de Two en Apal'))
  }
}
module.exports = { initialUsers }
