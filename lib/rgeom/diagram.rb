
require 'cairo' unless RUBY_PLATFORM == "i386-cygwin"

#
# RGeom diagrams.
#
# Basically, run through the registry in order and draw the object onto the canvas.
#
# The canvas has different coordinates to the objects in the registry; a function needs
# to be created that gives the appropriate canvas coordinates.  It depends on the
# total bounding box of the objects.
#
# Lines (infinite in each direction) have a bounding box as if they were segments, but
# are drawn to the edge of the canvas.
#
# === Classes in this scope ===
#
# class Canvas
#  * Accepts commands to draw lines and circles etc. and renders them onto a Cairo
#    canvas.
#  * Accepts RGeom coordinates and maps them into Cairo coordinates.
#
# class XTransform
#  * Performs mapping of x values.
#
# class YTransform
#  * Performs mapping of y values.
#
# class Diagram
#  * Analyses the size of the diagram and the aspect ratio and creates a suitable
#    canvas.
#  * Runs through the register and draws each object.
#  * Saves the diagram to a file (typically PNG for now).
#
# === Usage ===
#
#   require 'rgeom/toplevel'
#   
#   triangle(:ABC, :equilateral) do |t|
#     t.incircle
#     t.circumcircle
#     t.label_vertices
#   end
#
#   render('output.png')
#
# That +render+ translates into <tt>Diagram.new('output.png').render</tt>.
#

module RGeom
  #
  # -1 Diagram
  #
  class Diagram

    def initialize(filename)
      @register = RGeom::Register.instance
      case ext = File.extname(filename)
      when '.png'
        # That's what we assume for now, so no specific action necessary.
      else
        raise "File type #{ext} not implemented"
      end
      @filename = filename
    end

    def render(args={})
      width = args[:width] || 1000
      canvas = create_canvas(width)
      @register.each_row do |row|
        case row.category
        when :segment
          s = row.shape
          canvas.line(s.p, s.q)
        when :triangle
          t = row.shape
          canvas.polyline(t.points, :closed)
        when :circle
          c = row.shape
          canvas.circle(c.centre, c.radius)
        when :arc
          a = row.shape
          canvas.arc(a.centre, a.radius, a.absolute_angles)
        when :square
          s = row.shape
          canvas.polyline(s.points, :closed)
        else
          raise "Unknown drawing object type: #{label.inspect}"
        end
      end
      canvas.render(@filename)
    end

    def create_canvas(width)
      a, b = bounding_box
      Canvas.new(:x => (a.x..b.x), :y => (a.y..b.y), :width => width)
    end

      # Examines the objects in the register to determine the bounding box of the entire
      # diagram.  Returns two points: bottom-left and top-right.
    def bounding_box
      points = @register.map { |row|
        row.shape.bounding_box
      }
      points = points.compact.flatten
      PointList.new(points).bounding_box
    end

  end  # class Diagram
end  # module RGeom


#
# -2 Canvas
#
module RGeom; class Diagram;

  class Canvas

      # Arguments:
      #  * +:x+ is the range of source _x_ values
      #  * +:y+ is the range of source _y_ values
      #
      # Example:
      #   Canvas.new :x => (-7.3..10.9), :y => (2.5..7.1)
      #
      # These ranges will be mapped onto the picture output size, which is determined
      # by the aspect ratio calculated from +:x+ and +:y+.
      #
      # Currently, the picture will be 1000 pixels wide.  This could be changed in
      # future by saying "50 pixels per unit" or something like that.  In that case, if
      # the diagram was 2.5 units wide, the image would be 125 pixels wide.
      #
    def initialize(args={})
      debug "Canvas.new :x => #{args[:x]}, :y => #{args[:y]}, :width => #{args[:width]}"
      xmin = Float(args[:x].begin)
      xmax = Float(args[:x].end)
      ymin = Float(args[:y].begin)
      ymax = Float(args[:y].end)
      xlength = xmax - xmin
      $rgeom_diagram_width = xlength       # Hacky way of communicating with html-demo.
      ylength = ymax - ymin
      xmargin = xlength * 0.1
      ymargin = ylength * 0.1
      margin = (xmargin + ymargin) / 2     # Average out the two margins for even look.
      xmin = xmin - 0.5 * margin
      xmax = xmax + 0.5 * margin
      ymin = ymin - 0.5 * margin
      ymax = ymax + 0.5 * margin
      xlength = xmax - xmin
      ylength = ymax - ymin
      debug " * with added margin, we have xlength = #{xlength}, ylength = #{ylength}"
      aspect_ratio = ylength / xlength
      canvas_x = args[:width] || 1000
      canvas_y = canvas_x * aspect_ratio
      @xmap = LinearMap.new(xmin..xmax, 0..canvas_x)
      @ymap = LinearMap.new(ymax..ymin, 0..canvas_y)   # y direction is reversed
      @surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, canvas_x, canvas_y)
      @context = Cairo::Context.new(@surface)
      @context.set_source_rgb(1,1,1)                # white background
      @context.set_operator(Cairo::OPERATOR_SOURCE) # don't grok this line
      @context.paint                                # paint the background
      @context.set_source_rgb(0,0,0)                # now set black pen ...
      @context.set_line_width(1.0)                  # ...and line width for future lines
    end

      # _from_ and _to_ are taken to be RGeom::Point objects, with x and y coordinates.
      # We map them onto the canvas coordinate system.
    def line(from, to)
      a, b = map_points(from, to)
      debug "(canvas) line #{a} #{b} "
      @context.move_to(a.x, a.y)
      @context.line_to(b.x, b.y)
      @context.stroke
    end

    class ::Array
      unless instance_methods.include? "each_cons"
        def each_cons(n)
          index = 0
          loop do
            slice = self.slice(index, n)
            break unless slice.size == n
            yield slice
            index += 1
          end
          nil
        end
      end
    end

    def polyline(points, open_or_closed=:open)
      case open_or_closed
      when :open
        # No action required.
      when :closed
        points = points + [points.first]
      end
      points.each_cons(2) do |a, b|
        line(a, b)
      end
    end

    def circle(centre, radius)
      c = map_point(centre)
      r = scale(radius)
      debug "(canvas) circle (%3.1f, %3.1f) %3.1f" % [c.x, c.y, r]
      @context.circle(c.x, c.y, r)
      @context.stroke
    end

    def arc(centre, radius, angles)
      c = map_point(centre)
      r = scale(radius)
      a = angles.map { |x| x.in_radians }
      debug "(canvas) arc_negative (%3.1f, %3.1f) %3.1f (%3.3f %3.3f)" %
        [c.x, c.y, r, -a[0], -a[1]]
      @context.arc_negative(c.x, c.y, r, -a[0], -a[1])
        # Cairo treats angles as increasing clockwise; we use mathematical
        # convention of anticlockwise.  Therefore we negate our angles when
        # passing them to Cairo.
      @context.stroke
    end

    def map_point(p)
      x = @xmap[p.x]
      y = @ymap[p.y]
      CanvasPoint[x,y]
    end

    def map_points(*args)
      args.map { |arg| map_point(arg) }
    end

    def scale(distance)
      @xmap.scale(distance)
        # @xmap and @ymap should have the same scale as we preserve the aspect ratio.
        # We're in trouble if that ever changes, though.
    end

      # Support more file types in future.
    def render(filename)
      debug "render(#{filename})"
      @surface.write_to_png(filename)
    end

    class CanvasPoint < Struct.new(:x, :y)
      def to_s
        sprintf "(%03d, %03d)", self.x, self.y
      end
    end

  end  # class Canvas

end; end   # class RGeom::Diagram


#
# -3 Linear map
#
module RGeom; class Diagram; class Canvas
  class LinearMap
      # _from_ and _to_ are ranges.  For example:
      #   LinearMap.new (-3.8..10.1), (0..999)
    def initialize(from, to)
      a = Float(from.begin)
      b = Float(from.end)
      m = Float(to.begin)
      n = Float(to.end)
      # We map from [a,b] to [m,n]
      @scale = (n-m) / (b-a)
      @constant = m - (a * @scale)
    end

    def map(x)
      self[x]
    end

    def [](x)
      Float(x) * @scale + @constant
    end

    def scale(distance)
      distance * @scale
    end

  end  # class LinearMap
end; end; end  # class RGeom::Diagram::Canvas

