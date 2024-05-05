const express = require('express')

const { initialUsers } = require('../controllers/initial.controller')
const router = express.Router()

router.post('/initial', initialUsers)

module.exports = router
