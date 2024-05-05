const express = require('express')

const { getDetail, updateDetail } = require('../controllers/detail.controller')
const router = express.Router()

router.get('/detail/:deliveryId', getDetail)
router.put('/detail/:deliveryId', updateDetail)

module.exports = router
