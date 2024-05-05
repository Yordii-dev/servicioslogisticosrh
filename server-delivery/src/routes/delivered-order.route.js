const express = require('express')

const { createDelivered } = require('../controllers/delivered-order.controller')
const router = express.Router()

router.post('/delivered-order', createDelivered)

module.exports = router
