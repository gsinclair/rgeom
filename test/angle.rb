
D "Angle" do

  D "Basic" do
    a = 31.d
    Ko a, Angle
    Eq a.deg, 31
    Ft a.rad, 0.541052068

    a = 4.7.r
    Ko a, Angle
    Ft a.deg, 269.2901637
    Ft a.rad, 4.7
  end

  D "Comparison" do
    Eq  35.d, 35.d
    Eq! 46.d, 46.r
    Eq  (2*Math::PI).r, 360.d
    Eq  4.27.r, 244.6529785.d
    T { 56.d < 56.312.d }
    T { 3.r > 3.d }
  end

  D "Arithmetic" do
    a = 35.d + 17.d - 2.d
    Ko a, Angle
    Eq a, 50.d

    b = 4.r * 3
    Ko b, Angle
    Eq b, 12.r
  end

  D "Trigonometry" do
    Ft 45.d.sin, (Math.sqrt(2) / 2)
    Ft 3.1.r.cos, -0.99913515
    Ft -76.34.d.tan, -4.114646729
  end

end  # D "Angle"
