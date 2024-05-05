const express = require('express')
const multer = require('../helpers/multer')

const { createEvidence } = require('../controllers/evidence.controller')
const router = express.Router()

router.post('/evidence', multer, createEvidence)

module.exports = router
