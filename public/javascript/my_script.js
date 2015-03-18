/*
   This script taken from example in https://github.com/jasondavies/d3-cloud 
*/

var fill = d3.scale.category20();
var words_in_text = [];


function getData(collection){

	$("#content").empty().html('<img src="./images/ajax-loader.gif" />');
	var word_scale;
	$.getJSON("/daily-data", function(data) {
		$.each(data, function(key, value){
			if(key == 'word_scale'){
			 word_scale = value;
			} else {
			collection.push({'frequency': value,
			                'word': key});
			}
 });
   
d3.layout.cloud().size([600, 600])
	.words(collection.map(function(d) {
		return { text: d['word'], 
		         size: Math.ceil(word_scale * d['frequency']) };
	}))
	.padding(2)
	.rotate(function() { return ~~(Math.random() * 2) * 90; })
	.font("Impact")
	.fontSize(function(d) { return d.size; })
	.on("end", draw)
	.start();

});

}

function draw(words) {
	d3.select("#content").append("svg")
		 .attr("width", 600)
		 .attr("height", 600)
		 .append("g")
		 .attr("transform", "translate(300,300)")
		 .selectAll("text")
		 .data(words)
		 .enter().append("text")
		 .style("font-size", function(d) { return d.size + "px"; })
		 .style("font-family", "Impact")
		 .style("fill", function(d, i) { return fill(i); })
		 .attr("text-anchor", "middle")
		 .attr("transform", function(d) {
			 return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
		 })
		 .text(function(d) { return d.text; });
	$("img").toggle();
}
