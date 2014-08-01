var width = 800,
    height = 700,
    padding = {left: 190, right: 450, top: 0, bottom: 0};

var tree = d3.layout.tree()
    .size([360, width - padding.right])
    .separation(function(a, b) {
  		return 1 / a.depth;
	});

var diagonal = d3.svg.diagonal.radial()
    .projection(function(d) { return [d.y/1.7, (d.x - 180) / 180 * Math.PI]; });

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + 
    	width/2 + "," + height/2 + ")");

d3.json("/data/BabbleSep.json", function(error, root) {
  var nodes = tree.nodes(root),
      links = tree.links(nodes);

  var node = svg.selectAll(".node")
      .data(nodes)
    .enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) { console.log(d.x); return "rotate(" + (d.x - 126) + ")translate(" + d.y/1.7 + ")rotate("+ (-d.x + 126) + ")"; })
/*
  var link = svg.selectAll(".link")
      .data(links)
    .enter().append("path")
      .attr("class", "link")
      .attr("d", diagonal);
*/
  node.append("circle")
      .attr("r", 95)
      .style("fill", function(d) { return d.children ? "Tan" : "white"; });

  // Number
  node.append("text")
      .attr("dx", 0)
      .attr("dy", "0.35em")
      .style("text-anchor", "middle")
      .style("font", "150px 'Lucida Grande', Helvetica, Arial, sans-serif")
      .style("fill","Tan")
      .text(function(d) { return d.value; });

  // Name
  var name = node.selectAll(".name")
      .data(function(d) { return d.name; })
    .enter().append("text")
      .attr("class", "name")
      .attr("dy", function(d, i) { return (0.5-i)+"em"; })
      .style("text-anchor", "middle")
      .style("font", "16px 'Lucida Grande', Helvetica, Arial, sans-serif")
      .style("fill", "Black")
      .text(function(d) { return d; });
  /*
  node.append("text")
      .attr("dx", 0)
      .attr("dy", function(d) { return d.children ? 3 : 3; })
      .style("text-anchor", "middle")
      .style("fill", function(d) { return d.children ? "White" : "Black"; })
      .text(function(d) { return d.name; });
*/
  // Desc
  node.append("text")
      .attr("dx", 0)
      .attr("dy", "3.5em")
      .attr("class", "desc")
      .style("text-anchor", "middle")
      .text(function(d) { return d.desc; });
});

d3.select(self.frameElement).style("height", height + "px");