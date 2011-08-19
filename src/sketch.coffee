(($)->
  $.fn.sketch = (options)->
    $.error('Sketch can only be called on one element at a time.') if this.length > 1

    el = this.get(0)
    $el = $(el)
    context = el.getContext '2d'

    $el.data 'sketch.clicks', []
    $el.data 'sketch.painting', false

    painting = ->
      !!$el.data('sketch.painting')
    startPainting = ->
      $el.data 'sketch.painting', true
    stopPainting = ->
      $el.data 'sketch.painting', false
    clicks = ->
      $el.data 'sketch.clicks'

    addClick = (x,y,dragging)->
      clicks().push {x: x, y: y, dragging: dragging}

    redraw = ()->
      el.width = el.width
      
      context.strokeStyle = '#000'
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
        context.stroke()

        previous = this


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

    this
)(jQuery)
