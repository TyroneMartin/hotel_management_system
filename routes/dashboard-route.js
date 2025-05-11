const express = require("express")
const router = express.Router()
const dashboardController = require("../controllers/dashboardController")

router.get("/welcome", dashboardController.showWelcome)

module.exports = router
