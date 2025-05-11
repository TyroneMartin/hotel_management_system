const express = require("express")
const expressLayouts = require("express-ejs-layouts")
const session = require("express-session")
const cookieParser = require("cookie-parser")
const bodyParser = require("body-parser")
const env = require("dotenv").config()
const pool = require("./database/")
const utilities = require("./utilities")
const baseController = require("./controllers/baseController")
const path = require('path');


// const baseController = require("./controllers/baseController")
// const accountRoute = require("./routes/account-route")
// const inventoryRoute = require("./routes/inventory-route")
// const dashboardRoute = require("./routes/dashboard-route")

const app = express()

// Session
app.use(session({
  store: new (require('connect-pg-simple')(session))({ pool, createTableIfMissing: true }),
  secret: process.env.SESSION_SECRET,
  resave: true,
  saveUninitialized: true,
  name: "sessionId"
}))

// Flash & middleware
app.use(require("connect-flash")())
app.use((req, res, next) => {
  res.locals.messages = require("express-messages")(req, res)
  next()
})
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))
app.use(cookieParser())
app.use(utilities.checkJWTToken)

// View engine
app.set("view engine", "ejs")
app.use(expressLayouts)
app.set('views', path.join(__dirname, 'views'));
app.set("layout", "./layouts/layout")

// Static files
app.use(express.static("public"))

// Routes
app.get("/", utilities.handleErrors(baseController.buildHome))
// app.use("/account", accountRoute)
// app.use("/inv", inventoryRoute)
// app.use("/dashboard", dashboardRoute)

// Logout
// app.get("/account/logout", (req, res) => {
//   res.clearCookie("jwt")
//   req.flash("notice", "You have been successfully logged out.")
//   res.redirect("/")
// })

// 404
app.use((req, res, next) => {
  next({ status: 404, message: "Sorry, we appear to have lost that page." })
})

// Error handler
// app.use(async (err, req, res, next) => {
//   const nav = await utilities.getNav()
//   const message = err.status === 404 ? err.message : "Oh no! There was a crash."
//   res.render("errors/error", {
//     title: err.status || "Server Error",
//     message,
//     nav,
//     status: err.status || 500,
//     errors: null,
//   })
// })

// Server start
const port = process.env.PORT
const host = process.env.HOST
app.listen(port, () => console.log(`app listening on ${host}:${port}`))
