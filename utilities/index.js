const jwt = require("jsonwebtoken");
require("dotenv").config();

const Util = {};


/* ****************************************
 * Middleware For Handling Errors * General Error Handling
 **************************************** */
Util.handleErrors = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

/* ****************************************
 * Middleware to check token validity
 **************************************** */
Util.checkJWTToken = (req, res, next) => {
  if (req.cookies.jwt) {
    // console.log("Res.cookies : ", jwt)
    jwt.verify(
      req.cookies.jwt,
      process.env.ACCESS_TOKEN_SECRET,
      function (err, accountData) {
        if (err) {
          req.flash("Please log in");
          res.clearCookie("jwt");
          return res.redirect("/account/login");
        }
        res.locals.accountData = accountData; // Store account data in locals & only exists for the current request-response cycle
        req.session.accountData = accountData; // Persists across multiple requests from the same client
        // console.log("res.locals.accountData ", accountData)
        res.locals.loggedin = 1;
        next();
      }
    );
  } else {
    next();
  }
};

/* ****************************************
 *  Check Login
 * ************************************ */
Util.checkLogin = (req, res, next) => {
  if (res.locals.loggedin) {
    next();
  } else {
    req.flash("notice", "Please log in to acess your account.");
    return res.redirect("/account/login");
  }
};

// Middleware function to check account type  accountData
Util.checkAccountType = async function (req, res, next) {
  // Check if token exists
  // console.log("checkAccountType() was called");
  if (res.locals.loggedin) {
    const account = res.locals.accountData;
    if (
      account.account_type === "employee" ||
      account.account_type === "supervisor" ||
      account.account_type === "manager"
    ) {
      // Allow access to administrative views
      next();
    } else {
      req.flash(
        "notice",
        "You do not have permission to access this resource."
      );
      res.redirect("/account/login");
    }
  } else {
    req.flash(
      "notice",
      "You do not have permission to access this resource. You may try logging in."
    );
    res.redirect("/account/login");
  }
};

Util.checkAccountTypeManagerOnly = async function (req, res, next) {
  // Check if token exists
  // console.log("checkAccountType() was called");
  if (res.locals.loggedin) {
    const account = res.locals.accountData;
    if (
      account.account_type === "Admin"
    ) {
      // Allow access to administrative views
      next();
    } else {
      req.flash(
        "notice",
        "You do not have permission to access this resource."
      );
      res.redirect("/account/login");
    }
  } else {
    req.flash(
      "notice",
      "You do not have permission to access this resource. You may try logging in."
    );
    res.redirect("/account/login");
  }
};

module.exports = Util;