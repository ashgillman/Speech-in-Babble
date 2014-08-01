var margin = {top: 20, right: 10, bottom: 300, left: 150},
    width = 600 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var x = d3.scale.ordinal()
    .rangeRoundBands([0, width - 200], 1);

var y = d3.scale.ordinal()
    .rangeRoundBands([height, 0], 1);

var color = d3.scale.category10();

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.json("/data/analysisMethods.json", function(error, root) {
  vals = root.children;
  var data = [];
  vals.forEach(function(d1) {
    d1.methods.forEach(function(d2) {
      data.push({
        author: d1.author,
        method: d2,
        classif: d1.classif
      });
    });
  });

  console.log(data);
  data.forEach(function(d) {
    console.log(d);
  });
  x.domain(data.map(function(d) { return d.author; }));
  y.domain(data.map(function(d) { return d.method; }).sort(function(a, b) { return -a.localeCompare(b); }));

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
    .selectAll("text")  
      .style("text-anchor", "end")
      .attr("dx", "-.8em")
      .attr("dy", ".15em")
      .attr("transform", function(d) {
          return "rotate(-45)" 
          });

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .selectAll("text")  

  svg.selectAll(".dot")
      .data(data)
    .enter().append("circle")
      .attr("class", "dot")
      .attr("r", 5)
      .attr("cx", function(d) { return x(d.author); })
      .attr("cy", function(d) { return y(d.method); })
      .style("fill", function(d) { return color(d.classif); });

  var legend = svg.selectAll(".legend")
      .data(color.domain())
    .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

  legend.append("rect")
      .attr("x", width - 18)
      .attr("y", 10)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", color);

  legend.append("text")
      .attr("x", width - 24)
      .attr("y", 19)
      .attr("dy", ".35em")
      .style("text-anchor", "end")
      .text(function(d) { return d; });

});
