# **Sketch.js** is a simple jQuery plugin for creating drawable canvases
# using HTML5 Canvas. It supports multiple browsers including mobile 
# devices (albeit slowly).
(($)->
  $.sketch = { tools: {} }

  # ### jQuery('#mycanvas').sketch(options)
  #
  # Given an ID selector for a `<canvas>` element, initialize the specified
  # canvas as a drawing canvas. See below for the options that may be passed in.
  $.fn.sketch = (key, args...)->
    $.error('Sketch.js can only be called on one element at a time.') if this.length > 1
    sketch = this.data('sketch')

    # If a canvas has already been initialized as a sketchpad, calling
    # `.sketch()` will return the Sketch instance (see documentation below)
    # for the canvas. If you pass a single string argument (such as `'color'`)
    # it will return the value of any set instance variables. If you pass
    # a string argument followed by a value, it will set an instance variable
    # (e.g. `.sketch('color','#f00')`.
    if typeof(key) == 'string' && sketch
      if sketch[key]
        if typeof(sketch[key]) == 'function'
          sketch[key].apply sketch, args
        else if args.length == 0
          sketch[key]
        else if args.length == 1
          sketch[key] = args[0]
      else
        $.error('Sketch.js did not recognize the given command.')
    else if sketch
      sketch
    else
      this.data('sketch', new Sketch(this.get(0), key))
      this

  # ## Sketch
  #
  # The Sketch class represents an activated drawing canvas. It holds the
  # state, all relevant data, and all methods related to the plugin.
  class Sketch
    # ### new Sketch(el, opts)
    #
    # Initialize the Sketch class with a canvas DOM element and any specified
    # options. The available options are:
    #
    # * `toolLinks`: If `true`, automatically turn links with href of `#mycanvas`
    #   into tool action links. See below for a description of the available
    #   tool links.
    # * `defaultTool`: Defaults to `marker`, the tool is any of the extensible 
    #   tools that the canvas should default to.
    # * `defaultColor`: The default drawing color. Defaults to black.
    # * `defaultSize`: The default stroke size. Defaults to 5.
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

      # ### Sketch Events
      #
      # The `sketch.changecolor` event, when triggered on the canvas element, 
      # will change the color to the passed argument.
      @canvas.bind 'sketch.changecolor', (e, color)->
        $(this).data('sketch').color = color
      # The `sketch.changesize` event, when triggered on the canvas element,
      # will change the stroke size to the passed argument.
      @canvas.bind 'sketch.changesize', (e, size)->
        $(this).data('sketch').size = size
      # The `sketch.download` event, when triggered on the canvas element,
      # will cause the canvas to be downloaded according to the passed format.
      @canvas.bind 'sketch.download', (e, format)->
        $(this).data('sketch').download(format)

      @canvas.bind 'mousedown mouseup mousemove mouseleave mouseout touchstart touchmove touchend touchcancel', @onEvent

      # ### Tool Links
      #
      # Tool links automatically bind `a` tags that have an `href` attribute
      # of `#mycanvas` (mycanvas being the ID of your `<canvas>` element to
      # perform actions on the canvas.
      if @options.toolLinks
        $('body').delegate "a[href=\"##{@canvas.attr('id')}\"]", 'click', (e)->
          $this = $(this)
          $canvas = $($this.attr('href'))
          # If the link has a `data-color` attribute, the canvas's current draw
          # color will be changed to the value of the attribute.
          if $this.attr('data-color')
            $canvas.trigger 'sketch.changecolor', $(this).attr('data-color')
          # If the link has a `data-size` attribute, the canvas's current draw
          # size will be changed to the value of the attribute.
          if $this.attr('data-size')
            $canvas.trigger 'sketch.changesize', parseFloat($(this).attr('data-size'))
          # If the link has a `data-download` attribute, the canvas's current
          # contents will be downloaded in the specified format (acceptable formats
          # are `jpeg` and `png`).
          if $(this).attr('data-download')
            $canvas.trigger 'sketch.download', $(this).attr('data-download')
          false

    # ### sketch.download(format)
    #
    # Cause the browser to open up a new window with the Data URL of the current
    # canvas. The `format` parameter can be either `png` or `jpeg`.
    download: (format)->
      format or= "png"
      format = "jpeg" if format == "jpg"
      mime = "image/#{format}"

      window.open @el.toDataURL(mime)

    # ### sketch.set(key, value)
    #
    # *Internal method.* Sets an arbitrary instance variable on the Sketch instance.
    set: (key, value)->
      this[key] = value

    # ### sketch.startPainting()
    #
    # *Internal method.* Called when a mouse or touch event is triggered 
    # that begins a paint stroke. 
    startPainting: ->
      @painting = true
      @action = {
        tool: @tool
        color: @color
        size: @size
        events: []
      }

    # ### sketch.stopPainting()
    #
    # *Internal method.* Called when the mouse is released or leaves the canvas.
    stopPainting: ->
      @actions.push @action if @action
      @painting = false
      @action = null
      @redraw()
    
    # ### sketch.onEvent(e)
    #
    # *Internal method.* Universal event handler for the canvas. Any mouse or 
    # touch related events are passed through this handler before being passed
    # on to the individual tools.
    onEvent: (e)->
      if e.originalEvent && e.originalEvent.targetTouches
        e.pageX = e.originalEvent.targetTouches[0].pageX
        e.pageY = e.originalEvent.targetTouches[0].pageY
      $.sketch.tools[$(this).data('sketch').tool].onEvent.call($(this).data('sketch'), e)
      e.preventDefault()
      false

    # ### sketch.redraw()
    #
    # *Internal method.* Redraw the sketchpad from scratch using the aggregated
    # actions that have been stored as well as the action in progress if it has
    # something renderable.
    redraw: ->
      @el.width = @canvas.width()
      @context = @el.getContext '2d'
      sketch = this
      $.each @actions, ->
        if this.tool
          $.sketch.tools[this.tool].draw.call sketch, this
      $.sketch.tools[@action.tool].draw.call sketch, @action if @painting && @action

  $.sketch.tools.marker =
    onEvent: (e)->
      switch e.type
        when 'mousedown', 'touchstart'
          @startPainting()
        when 'mouseup', 'mouseout', 'mouseleave', 'touchend', 'touchcancel'
          @stopPainting()

      if @painting
        @action.events.push
          x: e.pageX - @canvas.offset().left
          y: e.pageY - @canvas.offset().top
          event: e.type

        @redraw()

    draw: (action)->
      @context.lineJoin = "round"
      @context.lineCap = "round"
      @context.beginPath()
      
      @context.moveTo action.events[0].x, action.events[0].y
      for event in action.events
        @context.lineTo event.x, event.y

        previous = event
      @context.strokeStyle = action.color
      @context.lineWidth = action.size
      @context.stroke()
)(jQuery)
