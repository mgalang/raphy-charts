# @import scaling.coffee
# @import tooltip.coffee
# @import dot.coffee
# @import bezier.coffee

class Line
  constructor: (@r, @raw_points, @scaled_points, @height, @width, @options = {}) ->

  draw: ->
    path = Bezier.create_path(@scaled_points, @options.smoothing)
    @draw_area(path) if @options.fill_area
    @draw_curve(path)
    @draw_dots_and_tooltips(@scaled_points, @raw_points) if @options.dot_size > 0
    return

  draw_curve: (path) ->
    curve = @r.path path
    curve.attr({
      "stroke"       : @options.line_color
      "stroke-width" : @options.line_width
    }).toFront()

  draw_area: (path) ->
    points = @scaled_points
    padded_height = @height - @options.y_padding

    final_point = points[points.length-1]
    first_point = points[0]

    path += "L #{final_point.x}, #{padded_height} "
    path += "L #{first_point.x}, #{padded_height} "
    path += "Z"

    area = @r.path(path)
    area.attr({
      "fill" : @options.area_color 
      "fill-opacity" : @options.area_opacity 
      "stroke-width" : 0
    })
    area.toBack()


  draw_dots_and_tooltips: () ->
    scaled_points = @scaled_points
    raw_points    = @raw_points
    tooltips     = []
    dots         = []
    max_point     = 0
    min_point     = 0

    # draw individual points
    for point, i in scaled_points
      dots.push     new Dot(@r, point, @options)
      tooltips.push new Tooltip(@r, dots[i].element, raw_points[i].y)
      max_point = i if raw_points[i].y >= raw_points[max_point].y
      min_point = i if raw_points[i].y < raw_points[min_point].y

    if @options.label_max
      tooltips[max_point].show()
      dots[max_point].activate()

    if @options.label_min
      tooltips[min_point].show()
      dots[min_point].activate()
