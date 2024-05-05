const express = require('express')
const auth = require('../middlewares/auth')

const { getSelf } = require('../controllers/operator.controller')
const router = express.Router()

router.get('/operators-self', auth, getSelf)

module.exports = router
