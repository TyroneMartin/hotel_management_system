const express = require("express")
const router = express.Router()
const accountController = require("../controllers/accountController")

router.get("/login", accountController.showLogin)
router.post("/login", accountController.loginUser)
router.get("/forgot-password", accountController.showForgotPassword)

module.exports = router
