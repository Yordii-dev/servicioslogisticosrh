const express = require('express')

const { getClient } = require('../controllers/client.controller')
const router = express.Router()

router.get('/client/:deliveryId', getClient)

module.exports = router
