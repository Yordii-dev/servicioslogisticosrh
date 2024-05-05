const express = require('express')
const auth = require('../middlewares/auth')

const { getGroups, createGroup } = require('../controllers/group.controller')
const router = express.Router()

router.get('/groups', auth, getGroups)
router.post('/groups', auth, createGroup)

module.exports = router
