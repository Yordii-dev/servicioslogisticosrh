const express = require('express')
const { signIn } = require('../controllers/signin.controller')

const router = express.Router()

router.post('/signin', signIn)

module.exports = router
