var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index',
  	{
  		title: 'Analysis Methods of Performance by Paper',
  		script: "./javascripts/analysisMethods.js"
  	});
});

module.exports = router;
