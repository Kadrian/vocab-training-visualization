# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


tooltipContent = (label, xval, yval, item) ->
	info = item["series"]["data"][item["dataIndex"]][2]
	tooltip = $('<div></div>')
	tooltip.append('<h4>' + info["jap"] + " - " + info["eng"] + '</h4>')
	tooltip.append('<p>Time: <b>' + yval + ' seconds</b></p>')
	tooltip.append('<p>Trials: <b>' + info["trials"] + '</b></p>')
	tooltip.html()

updateGraphData = (graph, newdata) ->
	for d, i in newdata
		d[0] = i
	data = graph.getData()[0]
	data["data"] = newdata
	graph.setData([data]);
	graph.setupGrid();
	graph.draw();

ready = ->
	console.log(window.data)
	if window.data.length == 0
		return

	# --------------------
	# LAST TRAINING
	# --------------------
	date = window.data[0]["created_at"]
	"2014-07-31T17:47:10.990Z"
	dateStr = date.split('T')[0] + " " + date.split('T')[1].split('.')[0]

	totalTime = 0
	for w in window.data
		totalTime += w["time"]
	totalMin = Math.floor(totalTime / 1000.0 / 60.0)
	totalSec = Math.round(totalTime / 1000.0 % 60.0)

	$('#graph1 .date').html("Training started " + dateStr)
	$('#graph1 .totalWords').html(window.data.length + " words")
	$('#graph1 .totalTime').html("Duration " + totalMin + " min " + totalSec + " sec")


	options =
		hoverable: true
		grid:
			borderColor: 'none'
			hoverable: true 
		tooltip: true
		tooltipOpts:	
			content: tooltipContent
		series:
			label: "Solving times in seconds"
			bars:
				show: true
				barWidth: 0.95
				align: "center"
		xaxis:
			tickLength: 0
			ticks: false
			tickColor: "transparent"

	# Graph 1
	data = []
	for word, i in window.data
		data.push([i, word["time"] / 1000.0,
			"trials": word["trials"]
			"jap": word["jap"]
			"eng": word["eng"]
		])


	window.graph1 = $.plot($("#graph1-chart"), [data], options);

	$('#last-training-toggle label').click ->
		# Determine which button has been toggled - SUPER UGLY
		option = $(@).find('input').attr('id')
		data = $.extend(true, [], graph1.getData()[0]["data"])
		if option == 'opt1'
			data.sort( (a,b) ->
				b[1] - a[1] # sort by time
			)
		else if option == 'opt2'
			data.sort( (a,b) ->
				if b[2]["trials"] == a[2]["trials"]
					return b[1] - a[1]
				b[2]["trials"] - a[2]["trials"]
			)
		else
			console.log "Error: Option not available"

		updateGraphData(window.graph1, data)


$(document).ready(ready)
$(document).on('page:load', ready)