const express = require('express')
const auth = require('../middlewares/auth')

const { getManaged, getTotal } = require('../controllers/managed.controller')
const router = express.Router()

router.get('/managed/:date', auth, getManaged)
router.get('/managed-total/:date', auth, getTotal)

module.exports = router
