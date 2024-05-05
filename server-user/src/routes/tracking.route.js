const express = require("express")
const auth = require("../middlewares/auth")

const { getTrackin } = require("../controllers/tracking.controller")
const router = express.Router()

router.get("/tracking/:date", auth, getTrackin)

module.exports = router
