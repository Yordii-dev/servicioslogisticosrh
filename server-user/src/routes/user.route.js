const express = require('express')
const auth = require('../middlewares/auth')

const { getSelf, getUser } = require('../controllers/user.controller')
const router = express.Router()

router.get('/users-self', auth, getSelf)

//Publics (Without token)
router.get('/users/:id', getUser)

module.exports = router
