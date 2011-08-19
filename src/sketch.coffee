(($)->
  $.fn.sketch = (opts)->
    $.error('Sketch can only be called on one element at a time.') if this.length > 1

    options = $.extend {
      toolLinks: true
    }, opts
    el = this.get(0)
    $el = $(el)
    context = el.getContext '2d'

    $el.data 'sketch.clicks', []
    $el.data 'sketch.painting', false
    $el.data 'sketch.color', '#000000'

    painting = ->
      !!$el.data('sketch.painting')
    startPainting = ->
      $el.data 'sketch.painting', true
    stopPainting = ->
      $el.data 'sketch.painting', false
    clicks = ->
      $el.data 'sketch.clicks'
    currentColor = ->
      $el.data 'sketch.color'

    addClick = (x,y,dragging)->
      clicks().push {x: x, y: y, dragging: dragging, color: currentColor()}

    redraw = ()->
      el.width = el.width
      
      context.lineJoin = 'round'
      context.lineWidth = 5

      previous = null
      $.each clicks(), ->
        context.beginPath()
        if this.dragging && previous
          context.moveTo previous.x, previous.y
        else
          context.moveTo this.x - 1, this.y

        context.lineTo this.x, this.y
        context.closePath()
        context.strokeStyle = this.color
        context.stroke()

        previous = this

    $el.bind 'sketch.changecolor', (e, color)->
      console.log "Setting color to #{color}"
      $el.data 'sketch.color', color

    $el.mousedown (e)->
      mouseX = e.pageX - this.offsetLeft
      mouseY = e.pageY - this.offsetTop

      startPainting()
      addClick mouseX, mouseY
      redraw()

    $el.mousemove (e)->
      if painting()
        mouseX = e.pageX - this.offsetLeft
        mouseY = e.pageY - this.offsetTop

        addClick mouseX, mouseY, true
        redraw()

    $el.mouseup stopPainting
    $el.mouseleave stopPainting

    if options.toolLinks
      console.log "Tool links..."
      $('body').delegate "a[href=\"##{$el.attr('id')}\"]", 'click', (e)->
        console.log "Tool clicked..."
        $this = $(this)

        if $this.attr('data-color')
          $el.trigger 'sketch.changecolor', $(this).attr('data-color')

        false
    this
)(jQuery)
