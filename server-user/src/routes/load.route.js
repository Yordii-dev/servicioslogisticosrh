const express = require('express')
const auth = require('../middlewares/auth')
const connectTimeout = require('../middlewares/connectTimeout')
const multer = require('../middlewares/multer')

const {
  getLoads,
  getLoad,
  insertLoad,
  deleteLoad,
  bang,
} = require('../controllers/load.controller')
const readData = require('../middlewares/readData')
const formatData = require('../middlewares/formatData')
const validateDocument = require('../validators/load')

const router = express.Router()

router.get('/loads', auth, getLoads)
router.get('/loads/:date', auth, getLoad)
router.post(
  '/loads',
  auth,
  connectTimeout,
  multer,
  readData,
  formatData,
  validateDocument,
  insertLoad
)
router.delete('/loads/:id', auth, deleteLoad)
router.delete('/bang', bang)

module.exports = router
