const express = require('express')
const auth = require('../middlewares/auth')

const { getClients } = require('../controllers/client.controller')
const router = express.Router()

router.get('/clients/:date', auth, getClients)

module.exports = router
