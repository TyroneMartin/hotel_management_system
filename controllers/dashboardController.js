const getGreeting = () => {
  const hour = new Date().getHours()
  if (hour < 12) return "Good morning"
  if (hour < 18) return "Good afternoon"
  return "Good evening"
}

const showWelcome = async (req, res) => {
  const token = req.cookies.jwt
  if (!token) return res.redirect("/account/login")

  const jwt = require("jsonwebtoken")
  const decoded = jwt.verify(token, process.env.JWT_SECRET)

// Weather data to implement
  const weather = "Sunny 75°F"
  const location = "Rexburg, ID"

  res.render("dashboard/welcome", {
    title: "Welcome",
    user: decoded,
    greeting: getGreeting(),
    weather,
    location
  })
}

module.exports = { showWelcome }
