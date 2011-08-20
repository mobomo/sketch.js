(function() {
  (function($) {
    var Sketch;
    $.sketch = {
      tools: {}
    };
    Sketch = (function() {
      function Sketch(el, opts) {
        this.el = el;
        this.canvas = $(el);
        this.context = el.getContext('2d');
        this.options = $.extend({
          toolLinks: true,
          defaultTool: 'marker',
          defaultColor: '#000000',
          defaultSize: 5
        }, opts);
        this.painting = false;
        this.color = this.options.defaultColor;
        this.size = this.options.defaultSize;
        this.tool = this.options.defaultTool;
        this.actions = [];
        this.action = [];
        this.canvas.bind('sketch.changecolor', function(e, color) {
          return $(this).data('sketch').color = color;
        });
        this.canvas.bind('sketch.changesize', function(e, size) {
          return $(this).data('sketch').size = size;
        });
        this.canvas.bind('mousedown mouseup mousemove mouseleave mouseout touchstart touchmove touchend touchcancel', this.onEvent);
        if (this.options.toolLinks) {
          $('body').delegate("a[href=\"#" + (this.canvas.attr('id')) + "\"]", 'click', function(e) {
            var $canvas, $this;
            $this = $(this);
            $canvas = $($this.attr('href'));
            if ($this.attr('data-color')) {
              $canvas.trigger('sketch.changecolor', $(this).attr('data-color'));
            }
            if ($this.attr('data-size')) {
              $canvas.trigger('sketch.changesize', parseFloat($(this).attr('data-size')));
            }
            return false;
          });
        }
      }
      Sketch.prototype.startPainting = function() {
        this.painting = true;
        return this.action = {
          tool: this.tool,
          color: this.color,
          size: this.size,
          events: []
        };
      };
      Sketch.prototype.stopPainting = function() {
        this.actions.push(this.action);
        this.painting = false;
        this.action = null;
        return this.redraw();
      };
      Sketch.prototype.onEvent = function(e) {
        $(this).data('sketch').addEvent(e);
        e.preventDefault();
        return false;
      };
      Sketch.prototype.addEvent = function(e) {
        var mouseX, mouseY;
        switch (e.type) {
          case 'mousedown':
          case 'touchstart':
            this.startPainting();
            break;
          case 'mouseup':
          case 'mouseout':
          case 'mouseleave':
          case 'touchend':
          case 'touchcancel':
            this.stopPainting();
        }
        if (this.painting) {
          mouseX = e.touches ? e.touches[0].pageX : e.pageX;
          mouseY = e.touches ? e.touches[0].pageY : e.pageY;
          this.action.events.push({
            x: mouseX - this.canvas.offset().left,
            y: mouseY - this.canvas.offset().top,
            event: e.type
          });
          return this.redraw();
        }
      };
      Sketch.prototype.redraw = function() {
        var sketch;
        this.el.width = this.canvas.width();
        this.context = this.el.getContext('2d');
        sketch = this;
        $.each(this.actions, function() {
          return $.sketch.tools[this.tool].draw.call(sketch, this);
        });
        if (this.painting) {
          return $.sketch.tools[this.action.tool].draw.call(sketch, this.action);
        }
      };
      return Sketch;
    })();
    $.sketch.tools.marker = {
      draw: function(action) {
        var event, previous, _i, _len, _ref, _results;
        this.context.lineJoin = "round";
        previous = null;
        _ref = action.events;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          event = _ref[_i];
          this.context.beginPath();
          if (previous) {
            this.context.moveTo(previous.x, previous.y);
          } else {
            this.context.moveTo(event.x - 1, event.y);
          }
          this.context.lineTo(event.x, event.y);
          this.context.closePath();
          this.context.strokeStyle = action.color;
          this.context.lineWidth = action.size;
          this.context.stroke();
          _results.push(previous = event);
        }
        return _results;
      }
    };
    return $.fn.sketch = function(opts) {
      if (this.length > 1) {
        $.error('Sketch can only be called on one element at a time.');
      }
      this.data('sketch', new Sketch(this.get(0), opts));
      return this;
    };
  })(jQuery);
}).call(this);
