(function() {
  $(function() {
    module("Initialization");
    test("should raise error if initialized against multiple elements", function() {
      $('#qunit-fixture').html('<canvas></canvas>\n<canvas></canvas>');
      return raises(function() {
        return $('canvas').sketch();
      });
    });
    return test("vanilla initialization", function() {
      $('#qunit-fixture').html('<canvas id="test_canvas"></canvas>');
      $('#test_canvas').sketch();
      return equal(false, $('#test_canvas').data('sketch.painting'));
    });
  });
}).call(this);
