const express = require('express')

const { getOrders, getTotal } = require('../controllers/order.controller')
const router = express.Router()

router.get('/orders/:deliveryId', getOrders)
router.get('/orders-total/:deliveryId', getTotal)

module.exports = router
