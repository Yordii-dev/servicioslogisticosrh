const express = require('express')
const {
  getPrice,
  getManager,
  getSupervisor,
} = require('../controllers/extra.controller')

const router = express.Router()

router.get('/extra-price/:deliveryId', getPrice)
router.get('/extra-manager/:deliveryId', getManager)
router.get('/extra-supervisor/:deliveryId', getSupervisor)

module.exports = router
