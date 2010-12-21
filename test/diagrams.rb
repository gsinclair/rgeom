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

end if defined? Cairo  # "Circle diagram"

