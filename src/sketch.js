(function() {
  (function($) {
    return $.fn.sketch = function(options) {
      var $el, addClick, clicks, context, el, painting, redraw, startPainting, stopPainting;
      if (this.length > 1) {
        $.error('Sketch can only be called on one element at a time.');
      }
      el = this.get(0);
      $el = $(el);
      context = el.getContext('2d');
      $el.data('sketch.clicks', []);
      $el.data('sketch.painting', false);
      painting = function() {
        return !!$el.data('sketch.painting');
      };
      startPainting = function() {
        return $el.data('sketch.painting', true);
      };
      stopPainting = function() {
        return $el.data('sketch.painting', false);
      };
      clicks = function() {
        return $el.data('sketch.clicks');
      };
      addClick = function(x, y, dragging) {
        return clicks().push({
          x: x,
          y: y,
          dragging: dragging
        });
      };
      redraw = function() {
        var previous;
        el.width = el.width;
        context.strokeStyle = '#000';
        context.lineJoin = 'round';
        context.lineWidth = 5;
        previous = null;
        return $.each(clicks(), function() {
          context.beginPath();
          if (this.dragging && previous) {
            context.moveTo(previous.x, previous.y);
          } else {
            context.moveTo(this.x - 1, this.y);
          }
          context.lineTo(this.x, this.y);
          context.closePath();
          context.stroke();
          return previous = this;
        });
      };
      $el.mousedown(function(e) {
        var mouseX, mouseY;
        mouseX = e.pageX - this.offsetLeft;
        mouseY = e.pageY - this.offsetTop;
        startPainting();
        addClick(mouseX, mouseY);
        return redraw();
      });
      $el.mousemove(function(e) {
        var mouseX, mouseY;
        if (painting()) {
          mouseX = e.pageX - this.offsetLeft;
          mouseY = e.pageY - this.offsetTop;
          addClick(mouseX, mouseY, true);
          return redraw();
        }
      });
      $el.mouseup(stopPainting);
      $el.mouseleave(stopPainting);
      return this;
    };
  })(jQuery);
}).call(this);
