var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index',
  	{
  		title: 'NMF for Speech',
  		script: "./javascripts/nmfSpeech.js"
  	});
});

module.exports = router;
