const express = require('express')
const auth = require('../middlewares/auth')

const {
  getOperators,
  createOperator,
  getByStatus,
  public_getByStatus,
} = require('../controllers/operator.controller')
const router = express.Router()

router.get('/operators', auth, getOperators)
router.post('/operators', auth, createOperator)
/*(status operators)
  A == actives
*/
router.get('/operators/:status', auth, getByStatus)

//Publics (Without token)
router.get('/operators/:status/:userId', public_getByStatus)

module.exports = router
