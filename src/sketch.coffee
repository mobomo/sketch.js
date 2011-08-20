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
      @canvas.bind 'mousedown mouseup mousemove mouseleave touchstart touchmove touchend touchcancel', @onEvent

      if @options.toolLinks
        $('body').delegate "a[href=\"##{@canvas.attr('id')}\"]", 'click', (e)->
          $this = $(this)
          $canvas = $($this.attr('href'))
          if $this.attr('data-color')
            $canvas.trigger 'sketch.changecolor', $(this).attr('data-color')
          if $this.attr('data-size')
            $canvas.trigger 'sketch.changesize', parseFloat($(this).attr('data-size'))
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
      @actions.push @action
      @painting = false
      @action = null
      @redraw()
    
    onEvent: (e)->
      $(this).data('sketch').addEvent e
      false

    addEvent: (e)->
      switch e.type
        when 'mousedown', 'touchstart'
          @startPainting()
        when 'mouseup', 'mouseout', 'touchend', 'touchcancel'
          @stopPainting()
      
      if @painting
        @action.events.push
          x: e.pageX - @canvas.offset().left
          y: e.pageY - @canvas.offset().top
          event: e.type
        @redraw()

    redraw: ->
      @el.width = @canvas.width()
      @context = @el.getContext '2d'
      sketch = this
      $.each @actions, ->
        $.sketch.tools[this.tool].draw.call sketch, this
      $.sketch.tools[@action.tool].draw.call sketch, @action if @painting

  $.sketch.tools.marker =
    draw: (action)->
      @context.lineJoin = "round"
      
      previous = null
      for event in action.events
        @context.beginPath()
        if previous
          @context.moveTo previous.x, previous.y
        else
          @context.moveTo event.x - 1, event.y

        @context.lineTo event.x, event.y
        @context.closePath()
        @context.strokeStyle = action.color
        @context.lineWidth = action.size
        @context.stroke()

        previous = event

  $.fn.sketch = (opts)->
    $.error('Sketch can only be called on one element at a time.') if this.length > 1
    this.data('sketch', new Sketch(this.get(0), opts))
    this

)(jQuery)
