const express = require('express')
const auth = require('../middlewares/auth')

const {
  getDeliveries,
  getTotal,
} = require('../controllers/delivery.controller')

const router = express.Router()
router.get('/deliveries/:date', auth, getDeliveries)
router.get('/deliveries-total/:date', auth, getTotal)
module.exports = router
