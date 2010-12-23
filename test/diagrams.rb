include Math
require 'fileutils'

D "Diagrams" do

  D.< do
    RGeom::Register.instance.clear!
  end

  D "circles" do
    FileUtils.rm_f('out/circles.png')
    F { File.exist? 'out/circles.png' }
    (0..30).each do |d|
      centre = Point[sqrt(d), sqrt(d)]
      radius = sqrt(2.2*d)
      circle(:centre => centre, :radius => radius)
    end
    render("out/circles.png")
    T { File.exist? 'out/circles.png' }
  end

  NTRIANGLES = 50

  D "triangle spiral (#{NTRIANGLES})" do
    filename = "out/spiral-#{NTRIANGLES}.png"
    FileUtils.rm_f(filename)
    F { File.exist? filename }
    # construction code taken from test/construct/spiral.rb
    first = triangle(:right_angle => :first, :base => 3, :height => 1)
    Shape.generate(NTRIANGLES, first) do |tn|
      triangle(:base => tn.hypotenuse.reverse, :right_angle => :first, :height => 1)
    end
    render(filename)
    T { File.exist? filename }
  end

  D "variety" do
    TESTS = []
    TESTS << { :desc => "Triangle",   :code => "triangle" }
    TESTS << { :desc => "Circle",     :code => "circle" }
    TESTS << { :desc => "Arc",        :code => "arc(:angles => [3.d,189.d])" }
    TESTS << { :desc => "Semicircle", :code => "semicircle" }

    TESTS.each do |test|
      description = test[:desc].downcase
      D "#{description}" do
        filename = "out/variety-#{description}.png"
        FileUtils.rm_f(filename)
        F { File.file?(filename) }
        RGeom::Register.instance.clear!
        eval test[:code]
        render filename
        T { File.file?(filename) }
      end
    end
  end  # variety

  D "polygons 1" do
    # A bunch of polygons on the same base (0-1)
    filename = "out/polygons-1.png"
    FileUtils.rm_f(filename)
    F { File.file? filename }
    b = seg(p(0,0), p(1,0))
    (3..17).each do |n|
      polygon(n: n, base: b)
    end
    render filename
    T { File.file? filename }
  end

  D "polygons 2" do
    # A bunch of circles containing polygons of increasing sidality
    filename = "out/polygons-2.png"
    FileUtils.rm_f(filename)
    F { File.file? filename }
    15.times do |i|
      x = 3*(i%5)
      y = 3*(i/5)
      c = pt(x,y)
      n = i+3          # triangle, square, pentagon, ...
      circle(centre: c, radius: 1)
      polygon(n: n, centre: c, radius: 1)
    end
    render filename
    T { File.file? filename }
  end

  D "polygons 3" do
    # A miscellaneous triangle with a different polygon on each side
    filename = "out/polygons-3.png"
    FileUtils.rm_f(filename)
    F { File.file? filename }
    points A: p(5.7,1.9), B: p(-4.5,-4.189)
    triangle(:ABC, :equilateral)
    polygon n: 7, base: :BA
    polygon n: 5, base: :CB
    polygon n:10, base: :AC
    render filename
    T { File.file? filename }
  end

end if defined? Cairo

