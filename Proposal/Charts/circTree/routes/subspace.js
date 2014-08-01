var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index',
  	{
  		title: 'Subspace Decomposition',
  		script: "./javascripts/subspace.js"
  	});
});

module.exports = router;
