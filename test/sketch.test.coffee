$ ->
  module "Initialization"

  test "should raise error if initialized against multiple elements", ->
    $('#qunit-fixture').html '''
      <canvas></canvas>
      <canvas></canvas>
    '''

    raises ->
      $('canvas').sketch()

  test "vanilla initialization", ->
    $('#qunit-fixture').html '<canvas id="test_canvas"></canvas>'

    $('#test_canvas').sketch()
    equal false, $('#test_canvas').data('sketch.painting')
