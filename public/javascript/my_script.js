/*
   This script taken from example in https://github.com/jasondavies/d3-cloud 
*/

var blabberApp = (function () {
	var fill = d3.scale.category20(),
	    word_scale,
	    collection = [],
	    houry_data = [],
	    draw = function (words) {
				d3.select(".graph-area").append("svg")
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


    return{
    	collection: collection,
    	houry_data: houry_data,
    	setScale: function( new_scale ){
    		word_scale = new_scale;
    	},
        getData: function getData( wordSet ) {		
        	    console.log(word_scale);
		  		d3.layout.cloud().size( [ 600, 600 ] )
					.words(wordSet.map( function( d ) {
						return { text: d[ 'word' ], 
						         size: Math.ceil(word_scale * d[ 'frequency' ]) };
					}))
					.padding( 2 )
					.rotate( function() { return ~~( Math.random() * 2 ) * 90; })
					.font( "Impact" )
					.fontSize(function( d ) { return d.size; })
					.on( "end", draw )
					.start();
			},

		drawCircles: function drawCircles() {
		        var width = 960,
			    height = 500;
		 
				var el_data = {"nodes": [] },
				    current = 22,
				    offset = 40;

			    for( var key in houry_data[current] ){
			    	el_data["nodes"].push({"x": offset, 
			    		                   "r": parseInt(houry_data[current][key])*3,
			    		                   "label": key });
			    	offset += parseInt(houry_data[current][key])*6+35;
			    }
		        
				var svg = d3.select(".graph-area").append("svg")
				    .attr("width", width)
				    .attr("height", height)
				    
				d3.json("data.json", function(json) {
				    /* Define the data for the circles */
				    var elem = svg.selectAll("g myCircleText")
				        .data(el_data.nodes)
				  
				    /*Create and place the "blocks" containing the circle and the text */  
				    var elemEnter = elem.enter()
					    .append("g")
					    .attr("transform", function(d){return "translate("+d.x+",80)"})
				 
				    /*Create the circle for each block */
				    var circle = elemEnter.append("circle")
					    .attr("r", function(d){return d.r} )
					    .attr("stroke","blue")
					    .attr("fill", "white")
				 
				    /* Create the text for each block */
				    elemEnter.append("text")
					    .attr("dx", function(d){return -20})
					    .text(function(d){return d.label})
				})
		    }
    }
}) ();  


$(document).ready(function() {

	    $.getJSON("/daily-data", function(data) {
		$.each(data, function(key, value){
			if(key == 'daily'){
				for( var key1 in value ){
					if(key1 == 'word_scale'){
					    blabberApp.setScale( value[key1] );
					} else {
						blabberApp.collection.push({'frequency': value[key1],
				                'word': key1});
					}
				}
			} else {
				for(var i = 0; i < value.length; ++i)
				    blabberApp.houry_data.push(value[i]);
			}
		});
	});

  $('.navbar-collapse li').on('click', function() {
  	var el = $(this),
  	    child = el.children('span:first'),
  	    container = el.parent(),
  	    graphicClass = $('.graph-area').attr('class').split(' ');  // need this to manipulate it when changing between options

  	if(!el.is(".active")){
  		var highlighted = container.find('.active');
  		highlighted.removeClass('active');
   		el.addClass('active');
        if(child.is('.icono-clock')){                     // find clock
        	if(!$('.graph-area').is('.circles')){
        		$('.graph-area').empty();
        		$('.graph-area').removeClass(graphicClass[1]);
            	$('.graph-area').addClass('circles')      // add class to display area so you know what is currently displayed
            	                                          // not sure if I'll need it once other links start working
      			blabberApp.drawCircles();                           // check if circles are already displayed so you don't have to call it!
      		}
  		}
  		if(child.is('.icono-sun')){                       // find sun
  			if(!$('.graph-area').is('.word_cloud')){
        		$('.graph-area').empty();
        		$('.graph-area').removeClass(graphicClass[1]);
            	$('.graph-area').addClass('word_cloud')   // add class to display area so you know what is currently displayed
            	                                          // not sure if I'll need it once other links start working
      			blabberApp.getData( blabberApp.collection );                   // check if cloud is already displayed so you don't have to call it!
      		}
  			

  	    }
  	}


  });
})
      	