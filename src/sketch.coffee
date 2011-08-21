###

Sketch.js v0.0.1
Copyright 2011 Michael Bleigh and Intridea, Inc.
Released under the MIT License

###

(($)->
  $.sketch = { tools: {} }

  class Sketch
    constructor: (el, opts)->
      @el = el
      @canvas = $(el)
      @context = el.getContext '2d'
      @options = $.extend {
        toolLinks: true
        defaultTool: 'marker'
        defaultColor: '#000000'
        defaultSize: 5
      }, opts
      @painting = false
      @color = @options.defaultColor
      @size = @options.defaultSize
      @tool = @options.defaultTool
      @actions = []
      @action = []

      @canvas.bind 'sketch.changecolor', (e, color)->
        $(this).data('sketch').color = color
      @canvas.bind 'sketch.changesize', (e, size)->
        $(this).data('sketch').size = size
      @canvas.bind 'sketch.download', (e, format)->
        $(this).data('sketch').download(format)

      @canvas.bind 'mousedown mouseup mousemove mouseleave mouseout touchstart touchmove touchend touchcancel', @onEvent

      if @options.toolLinks
        $('body').delegate "a[href=\"##{@canvas.attr('id')}\"]", 'click', (e)->
          $this = $(this)
          $canvas = $($this.attr('href'))
          if $this.attr('data-color')
            $canvas.trigger 'sketch.changecolor', $(this).attr('data-color')
          if $this.attr('data-size')
            $canvas.trigger 'sketch.changesize', parseFloat($(this).attr('data-size'))
          if $(this).attr('data-download')
            $canvas.trigger 'sketch.download', $(this).attr('data-download')
          false


    startPainting: ->
      @painting = true
      @action = {
        tool: @tool
        color: @color
        size: @size
        events: []
      }

    stopPainting: ->
      @actions.push @action if @action
      @painting = false
      @action = null
      @redraw()
    
    onEvent: (e)->
      $(this).data('sketch').addEvent e
      e.preventDefault()
      false

    addEvent: (e)->
      switch e.type
        when 'mousedown', 'touchstart'
          @startPainting()
        when 'mouseup', 'mouseout', 'mouseleave', 'touchend', 'touchcancel'
          @stopPainting()

      if @painting
        if e.originalEvent.targetTouches && e.originalEvent.targetTouches.length > 1
          @stopPainting()
          return
        mouseX = if e.originalEvent.targetTouches then e.originalEvent.targetTouches[0].pageX else e.pageX
        mouseY = if e.originalEvent.targetTouches then e.originalEvent.targetTouches[0].pageY else e.pageY

        @action.events.push
          x: mouseX - @canvas.offset().left
          y: mouseY - @canvas.offset().top
          event: e.type

        @redraw()

    redraw: ->
      @el.width = @canvas.width()
      @context = @el.getContext '2d'
      sketch = this
      $.each @actions, ->
        $.sketch.tools[this.tool].draw.call sketch, this
      $.sketch.tools[@action.tool].draw.call sketch, @action if @painting && @action

    download: (filename, format)->
      format or= "png"
      format = "jpeg" if format == "jpg"
      mime = "image/#{format}"

      imgData = @el.toDataURL(mime)
      imgData = imgData.replace(mime, "image/octet-stream")

      document.location.href = imgData

  $.sketch.tools.marker =
    draw: (action)->
      @context.lineJoin = "round"
      @context.lineCap = "round"
      @context.beginPath()
      
      @context.moveTo action.events[0].x, action.events[0].y
      for event in action.events
        @context.lineTo event.x, event.y

        previous = event
      #@context.closePath()
      @context.strokeStyle = action.color
      @context.lineWidth = action.size
      @context.stroke()

  $.fn.sketch = (opts)->
    $.error('Sketch can only be called on one element at a time.') if this.length > 1
    this.data('sketch', new Sketch(this.get(0), opts))
    this

)(jQuery)
