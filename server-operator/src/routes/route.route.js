const express = require('express')
const auth = require('../middlewares/auth')

const { getRoute, createRoute } = require('../controllers/route.controller')
const router = express.Router()

router.get('/route/:date', auth, getRoute)
router.post('/route', auth, createRoute)

module.exports = router
