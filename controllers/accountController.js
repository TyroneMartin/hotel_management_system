const jwt = require("jsonwebtoken")
const bcrypt = require("bcryptjs")

const showLogin = (req, res) => {
  res.render("account/login", { title: "Login" })
}

const loginUser = async (req, res) => {
  const { username, password } = req.body

  const user = await findUserByUsername(username) // To be implemented
  if (user && bcrypt.compareSync(password, user.password)) {
    const token = jwt.sign({ id: user.id, role: user.role, first_name: user.first_name }, process.env.JWT_SECRET)
    res.cookie("jwt", token, { httpOnly: true })
    res.redirect("/dashboard")
  } else {
    req.flash("notice", "Invalid credentials.")
    res.redirect("/account/login")
  }
}

const showForgotPassword = (req, res) => {
  res.render("account/forgot-password", { title: "Reset Password" })
}

module.exports = { showLogin, loginUser, showForgotPassword }
