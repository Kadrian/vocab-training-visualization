# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


tooltipContentBase = (label, xval, yval, item) ->
    info = item["series"]["data"][item["dataIndex"]][2]
    tooltip = $('<div></div>')
    tooltip.append('<h4>' + info["back"] + " - " + info["front"] + '</h4>')
    [tooltip, info]

tooltipAddInfo = (tooltip, info) ->
    tooltip.append('<p>Trials: <b>' + info["trials"] + '</b></p>')
    tooltip.append('<p>Times trained: <b>' + info["timesTrained"] + ' times</b></p>')
    tooltip

tooltipContent1 = (label, xval, yval, item) ->
    [tooltip, info] = tooltipContentBase(label, xval, yval, item)
    tooltip.append('<p>Time: <b>' + yval.toFixed(3) + ' seconds</b></p>')
    tooltip = tooltipAddInfo(tooltip, info)
    tooltip.html()

tooltipContent2 = (label, xval, yval, item) ->
    [tooltip, info] = tooltipContentBase(label, xval, yval, item)
    tooltip.append('<p>Time: <b>' + yval.toFixed(3) + ' seconds / character</b></p>')
    tooltip = tooltipAddInfo(tooltip, info)
    tooltip.html()

tooltipContent3 = (label, xval, yval, item) ->
    [tooltip, info] = tooltipContentBase(label, xval, yval, item)
    tooltip.append('<p>Times trained: <b>' + yval + ' times</b></p>')
    tooltip.append('<p>Avg time per training: <b>' + info["avgTime"].toFixed(3) + ' seconds</b></p>')
    tooltip.append('<p>Avg trials per training: <b>' + info["avgTrials"].toFixed(1) + ' trials</b></p>')
    tooltip.html()

basicOptions =
    hoverable: true
    grid:
        borderColor: 'none'
        hoverable: true 
    tooltip: true
    tooltipOpts:    
        content: tooltipContent1
    series:
        label: "Solving time in seconds"
        bars:
            show: true
            barWidth: 0.95
            align: "center"
    xaxis:
        tickLength: 0
        ticks: false
        tickColor: "transparent"

updateGraphData = (graph, newdata) ->
    for d, i in newdata
        d[0] = i
    data = graph.getData()[0]
    data["data"] = newdata
    graph.setData([data])
    graph.setupGrid()
    graph.draw()

changeWordList = (wordlist) ->
    payload =
        wordlist: wordlist

    $.ajax '/statistics/wordListStats',
        type: 'GET'
        dataType: 'json'
        data: payload
        error: (jqXHR, textStatus, errorThrown) ->
            console.log "AJAX Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
            updateWordStatsGraph(data)

updateWordStatsGraph = (data) ->
    console.log data
    # TODO DATA
    graphData = []
    for word, i in data
        graphData.push([i, word["timesTrained"],
            "back": word["back"]
            "front": word["front"]
            "avgTime": word["avgTime"] / 1000.0
            "avgTrials": word["avgTrials"]
        ])

    options = $.extend(true, {}, basicOptions)  
    options["series"]["label"] = "Word proficiency"
    options["series"]["bars"]["lineWidth"] = 0.5
    options["tooltipOpts"]["content"] = tooltipContent3

    if not window.graph3?
        window.graph3 = $.plot($("#graph3-chart"), [graphData], options)
    else
        updateGraphData(window.graph3, graphData)


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

    # Graph 1
    data = []
    for word, i in window.data
        data.push([i, word["time"] / 1000.0,
            "trials": word["trials"]
            "back": word["back"]
            "front": word["front"]
            "timesTrained": word["timesTrained"]
        ])


    window.graph1 = $.plot($("#graph1-chart"), [data], basicOptions)

    $('#last-training-toggle label').click ->
        # Determine which button has been toggled - SUPER UGLY
        option = $(@).find('input').attr('id')
        data = $.extend(true, [], graph1.getData()[0]["data"])
        if option == 'opt1'
            data.sort( (a,b) ->
                if b[2]["trials"] == a[2]["trials"]
                    return b[1] - a[1]
                b[2]["trials"] - a[2]["trials"]
            )
        else if option == 'opt2'
            data.sort( (a,b) ->
                b[1] - a[1] # sort by time
            )
        else
            console.log "Error: Option not available"

        updateGraphData(window.graph1, data)

    # Graph 2
    data2 = $.extend(true, [], data)
    options2 = $.extend(true, {}, basicOptions)  
    options2["tooltipOpts"]["content"] = tooltipContent2
    options2["series"]["label"] = "Solving time in seconds per character"

    for w in data2
        back = w[2]["back"].split('|')
        maxlen = back[0].length
        for j in back
            if j.lengh > maxlen
                maxlen = j.length
        w[1] = w[1] / maxlen
    data2.sort( (a,b) ->
        b[1] - a[1] 
    )
    for w, i in data2
        w[0] = i

    window.graph2 = $.plot($("#graph2-chart"), [data2], options2)

    # INIT WORD LISTS
    $('.wordlistpicker'). selectpicker(
        style: 'btn-default'
    )
    $('.wordlistpicker').change( ->
        val = $(@).val().split(' - ')
        if window.currentList != val
            window.currentList = val
            changeWordList(val)
    )
    window.currentList = $('.wordlistpicker').val().split(' - ')

    # LOAD INITIAL GRAPH
    changeWordList()


# TURBOLINKS FIX
$(document).ready(ready)
$(document).on('page:load', ready)
