D "VertexList" do
  D.< do
    @register = RGeom::Register.instance
    @register.clear!
  end

  D "initialize" do
    VertexList.new(3, [:X, :Y, :Z], [p(1,1), p(5,1), p(3,3)]).tap do |vl|
      Eq vl[0], p(1,1)
      Eq vl[1], p(5,1)
      Eq vl[2], p(3,3)
      Eq vl.label, :XYZ     # TODO: should be Label[:XYZ] ?
      Eq vl.vertex_names, [:X, :Y, :Z]
      Eq vl.pointlist, PointList[p(1,1), p(5,1), p(3,3)]
      Eq vl.mask, "TTT"
    end
    D "enforce number of vertices" do
      E(ArgumentError) do
        VertexList.new(5, [:X, :Y, :Z], [p(1,1), p(5,1), p(3,3)])
      end
    end
  end

  D "default label (all vertices _)" do
    VertexList.new(3, nil, nil).tap do |vl|
      Eq vl.label, :___
      Eq vl.mask, "FFF"
    end
    VertexList.new(5, nil, nil).tap do |vl|
      Eq vl.label, :_____
      Eq vl.mask, "FFFFF"
    end
  end

  D "default resolve (all vertices nil)" do
    VertexList.resolve(5, nil).tap do |vl|
      Eq vl[0], nil
      Eq vl[1], nil
      Eq vl[2], nil
      Eq vl[3], nil
      Eq vl[4], nil
      Eq vl.mask, "FFFFF"
    end
  end

  D "resolve :AB where A and B are defined" do
    points :A => p(3,1), :B => p(9,7)
    VertexList.resolve(2, :AB).tap do |vl|
      Eq vl[0], p(3,1)
      Eq vl[1], p(9,7)
      Eq vl.label, :AB
      Eq vl.vertex_names, [:A, :B]
      Eq vl.pointlist, PointList[p(3,1), p(9,7)]
      Eq vl.mask, "TT"
    end
  end

  D "resolve and accommodate" do
    # Points X, Y and Z are not defined.  Calling VertexList.resolve(3, :XYZ)
    # will generate a vertex list with +nil+ points.  Calling accommodate(...)
    # will assign the points to the vertices.  A side effect, which we test, is
    # that the register is updated with those point definitions.
    D "where all points are nil" do
      VertexList.resolve(3, :XYZ).tap do |vl|
        Eq vl[0], nil
        Eq vl[1], nil
        Eq vl[2], nil
        Eq @register[:X], nil
        Eq @register[:Y], nil
        Eq @register[:Z], nil
        Eq vl.mask, "FFF"

        vl.accommodate [p(4,3), p(1,0), p(5,5)]
        Eq vl[0], p(4,3)
        Eq vl[1], p(1,0)
        Eq vl[2], p(5,5)
        Eq @register[:X], p(4,3)
        Eq @register[:Y], p(1,0)
        Eq @register[:Z], p(5,5)
        Eq vl.mask, "TTT"
      end
    end

    D "where some points are defined" do
      points :A => p(3,1), :B => p(9,7)
      VertexList.resolve(4, :ABCD).tap do |vl|
        Eq vl.label, :ABCD
        Eq vl[0], p(3,1)
        Eq vl[1], p(9,7)
        Eq vl[2], nil
        Eq vl[3], nil
        Eq vl.mask, "TTFF"
        Eq @register[:C], nil
        Eq @register[:D], nil

        vl.accommodate [nil, nil, p(4,5), p(0,0)]
        Eq vl[0], p(3,1)
        Eq vl[1], p(9,7)
        Eq vl[2], p(4,5)
        Eq vl[3], p(0,0)
        Eq vl.mask, "TTTT"
        Eq @register[:C], p(4,5)
        Eq @register[:D], p(0,0)
      end
    end
  end  # resolve and accommodate

  D "update points - legitimately and otherwise" do
    D.<< do
      points :A => p(3,1)
      @vl = VertexList.resolve(4, :ABC_)
    end

    D "create VertexList :ABC_ where A is defined" do
      # It was created in the setup block; we just confirm its correctness.
      Eq @vl.label, :ABC_
      Eq @vl[0], p(3,1)
      Eq @vl[1], nil
      Eq @vl[2], nil
      Eq @vl[3], nil
      Eq @vl.mask, "TFFF"
      Eq @register[:B], nil
      Eq @register[:C], nil
    end

    D "updating second vertex changes point B" do
      @vl[1] = p(5,6)
      Eq @vl[1], p(5,6)
      Eq @vl.mask, "TTFF"
      Eq @register[:B], p(5,6)
    end

    D "updating fourth vertex (point _) is legitimate, but has no effect in register" do
      @vl[3] = p(0,-2)
      Eq @vl.mask, "TTFT"
      Eq @vl[3], p(0,-2)
    end
      
    D "updating first vertex (point A) is an error as A is already defined" do
      E(ArgumentError) { @vl[0] = p(4,2) }
    end
  end  # update points -- legitimately and otherwise

  D "successive accommodates" do
    points :A => p(3,1)
    VertexList.resolve(4, :ABC_).tap do |vl|
      Eq vl.mask, "TFFF"
      vl.accommodate [p(3,1), p(2,2)]
      Eq vl[0], p(3,1)
      Eq vl[1], p(2,2)
      Eq vl[2], nil
      Eq vl[3], nil
      Eq vl.mask, "TTFF"
      vl.accommodate [p(3,1), p(2,2), p(1,9)]
      Eq vl[0], p(3,1)
      Eq vl[1], p(2,2)
      Eq vl[2], p(1,9)
      Eq vl[3], nil
      Eq vl.mask, "TTTF"
      vl.accommodate [p(3,1), p(2,2), p(1,9), p(5,2)]
      Eq vl[0], p(3,1)
      Eq vl[1], p(2,2)
      Eq vl[2], p(1,9)
      Eq vl[3], p(5,2)
      Eq vl.mask, "TTTT"
    end
  end

end  # VertexList
