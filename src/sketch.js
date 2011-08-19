(function() {
  (function($) {
    return $.fn.sketch = function(opts) {
      var $el, addClick, clicks, context, currentColor, el, options, painting, redraw, startPainting, stopPainting;
      if (this.length > 1) {
        $.error('Sketch can only be called on one element at a time.');
      }
      options = $.extend({
        toolLinks: true
      }, opts);
      el = this.get(0);
      $el = $(el);
      context = el.getContext('2d');
      $el.data('sketch.clicks', []);
      $el.data('sketch.painting', false);
      $el.data('sketch.color', '#000000');
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
      currentColor = function() {
        return $el.data('sketch.color');
      };
      addClick = function(x, y, dragging) {
        return clicks().push({
          x: x,
          y: y,
          dragging: dragging,
          color: currentColor()
        });
      };
      redraw = function() {
        var previous;
        el.width = el.width;
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
          context.strokeStyle = this.color;
          context.stroke();
          return previous = this;
        });
      };
      $el.bind('sketch.changecolor', function(e, color) {
        console.log("Setting color to " + color);
        return $el.data('sketch.color', color);
      });
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
      if (options.toolLinks) {
        console.log("Tool links...");
        $('body').delegate("a[href=\"#" + ($el.attr('id')) + "\"]", 'click', function(e) {
          var $this;
          console.log("Tool clicked...");
          $this = $(this);
          if ($this.attr('data-color')) {
            $el.trigger('sketch.changecolor', $(this).attr('data-color'));
          }
          return false;
        });
      }
      return this;
    };
  })(jQuery);
}).call(this);
