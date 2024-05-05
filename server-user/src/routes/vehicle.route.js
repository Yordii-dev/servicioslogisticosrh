const express = require('express')
const auth = require('../middlewares/auth')

const {
  getVehicles,
  getByStatus,
  updateVehicle,
} = require('../controllers/vehicle.controller')
const router = express.Router()

router.get('/vehicles', auth, getVehicles)
router.put('/vehicles/:id', auth, updateVehicle)

/*
  A == actives
  G == withGroup
  NO-G == withoutGroup
  G-NO-O == withGroupAndWithoutOperator
*/
router.get('/vehicles/:status', auth, getByStatus)

module.exports = router
