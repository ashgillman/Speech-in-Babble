var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index',
  	{
  		title: 'Speech Enhancement Methods',
  		script: "./javascripts/speechEnhance.js"
  	});
});

module.exports = router;
