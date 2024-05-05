const express = require('express')

const { send } = require('../controllers/sms.controller')

const router = express.Router()

router.post('/sms', send)

module.exports = router
