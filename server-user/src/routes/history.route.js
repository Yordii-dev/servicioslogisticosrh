const express = require('express')
const auth = require('../middlewares/auth')

const { getHistory } = require('../controllers/history.controller')
const router = express.Router()

router.get('/history', auth, getHistory)

module.exports = router
