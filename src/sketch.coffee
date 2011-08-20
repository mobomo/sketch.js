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

    addEvent: (e)->
      switch e.type
        when 'mousedown'
          @startPainting()
        when 'mouseup', 'mouseout'
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
    sketch = this.data('sketch')

    this.bind 'sketch.changecolor', (e, color)->
      sketch.color = color
    this.bind 'mousedown mouseup mousemove mouseleave', sketch.onEvent

    that = this
    if sketch.options.toolLinks
      console.log that
      $('body').delegate "a[href=\"##{that.attr('id')}\"]", 'click', (e)->
        $this = $(this)
        if $this.attr('data-color')
          that.trigger 'sketch.changecolor', $(this).attr('data-color')
        false

    this

)(jQuery)
