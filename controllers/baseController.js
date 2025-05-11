const baseController = {}

baseController.buildHome = async function(req, res){
  res.render("index", {
    title: "Home", 
    errors: null,
  })
}

module.exports = baseController
