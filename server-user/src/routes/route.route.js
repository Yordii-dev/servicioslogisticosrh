const express = require('express')
const auth = require('../middlewares/auth')

const { getRoutes } = require('../controllers/route.controller')
const router = express.Router()

router.get('/routes/:date', auth, getRoutes)

module.exports = router
