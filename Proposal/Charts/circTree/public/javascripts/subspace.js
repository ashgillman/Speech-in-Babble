var width = 450,
    height = 200,
    padding = {left: 150, right: 400, top: 0, bottom: 0};

var cluster = d3.layout.tree()
    .size([height - padding.bottom, width - padding.right])
    .separation(function(a, b) {
  		return 1;
	});

var diagonal = d3.svg.diagonal()
    .projection(function(d) { return [d.y, d.x]; });

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + 
    	padding.left + "," + padding.top + ")");

d3.json("/data/subspace.json", function(error, root) {
  var nodes = cluster.nodes(root),
      links = cluster.links(nodes);

  var link = svg.selectAll(".link")
      .data(links)
    .enter().append("path")
      .attr("class", "link")
      .attr("d", diagonal);

  var node = svg.selectAll(".node")
      .data(nodes)
    .enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })

  node.append("circle")
      .attr("r", 4.5);

  // Name
  node.append("text")
      .attr("dx", function(d) { return d.children ? -8 : 8; })
      .attr("dy", function(d) { return d.children ? 3 : 3; })
      .style("text-anchor", function(d) { return d.children ? "end" : "start"; })
      .text(function(d) { return d.name; });

  // Desc
  var desc = node.selectAll(".desc")
      .data(function(d) { return d.desc; })
    .enter().append("text")
      .attr("dx", function(d) { return d.children ? -8 : 8; })
      .attr("dy", function(d, i) { return (1.5+i)+"em"; })
      .attr("class", "desc")
      .style("text-anchor", "start")
      .text(function(d) { return d; });
});

d3.select(self.frameElement).style("height", height + "px");