# RGeom::Err -- a catalogue of errors.

require 'term/ansicolor'

class String
  include Term::ANSIColor
end

module RGeom;
  class Err
    class SpecificationError < Exception
    end
  end

  class << Err

    def redefine_point(name, old, new)
      msg = %{
      Attempt to redefine point #{name.inspect}.
      Old value: #{old}   New value: #{new}
      }.tabto(0).trim
      raise ArgumentError, msg.yellow.bold
    end

    def vertex_list_update_point(label, index, old, new)
      msg = %{
        In VertexList<#{label}>, invalid attempt to update point #{index}.
        Current value: #{old}       New value: #{new}
        You are only allowed to update points that are nil.
      }.tabto(0).trim
      raise ArgumentError, msg.yellow.bold
    end

    def right_angle_not_in_triangle(angle, vertex_names)
      msg = %{
      In triangle #{vertex_names}, specified right angle #{angle.inspect}
      does not exist.
      }.tabto(0).trim
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def invalid_height_in_right_angled_triangle(vertex_names, base, height)
      msg = %{
        In right-angled triangle #{vertex_names}, where the right-angle is in the apex,
        the height cannot exceed half the base.  (base = #{base}, height = #{height})
      }.tabto(0).trim
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def invalid_base_spec(base)
      msg = "Invalid specification of 'base': #{base.inspect}"
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def inconsistent_points_spec(label, existing, new)
      msg = "Inconsistent specification of points in shape <#{label}>.\n"
      msg += "Existing = #{existing};  New = #{new}"
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def incorrect_number_of_vertices(label, expected, actual)
      msg = %{
        The vertex list you are tring to operate on (%s) is supposed to have %d
        vertices, but you provided %d names or points.
      }.tabto(0).trim
      msg = sprintf msg, label, expected, actual
      raise ArgumentError, msg.yellow.bold
    end

    def invalid_generator
      msg = %{
        Invalid arguments to Shape.generator.  Expect
          Integer, Shape, Proc, Proc, Proc, ...
      }.tabto(0).trim
      raise ArgumentError, msg.yellow.bold
    end

    # General method for dealing with specification errors.
    # It prints the argument list that the user provided in addition to the
    # error message that the code provides.
    #
    # This method is designed to replace all the methods like
    # invalid_circle_spec etc., although other methods could _use_ this one.
    #
    #   @shape : Symbol, like :triangle, :segment, etc.
    #   @spec  : Specification object
    #   @msg   : String providing details about the error
    #
    # NOTE: we're in flux between the old specification code and the new DSL;
    # this method is in flux too, and will be great when we have a nice new
    # ConstructionSpec class!
    def invalid_spec(shape, spec, msg)
      message = %{
        Invalid specification for shape '#{shape.to_s.green.bold}'.
        Details: #{msg.red.bold}
        Arguments:
      }.tabto(0).trim + spec.to_s.indent(4).green.bold
      raise RGeom::Err::SpecificationError, message.yellow.bold
    end

    def invalid_circle_spec(args)
      msg = %{
        The arguments given do not form a valid circle specification:
          #{args.inspect}
      }.tabto(0).trim
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def invalid_square_spec(spec, msg)
      msg = %{
        The arguments given do not form a valid circle specification.
        (Detail: #{msg})
          #{spec.inspect}
      }.tabto(0).trim
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def invalid_arc_no_angles
      msg = %{
        No angle boundaries were provided for the arc.
      }.tabto(0).trim
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def nonexistent_centre(label)
      msg = %{The specified centre (#{label}) does not exist.}
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def attempt_to_set_id_a_second_time(shape, id)
      msg = %{Attempt to reset a shape's id.  Current: #{shape.id}  New: #{id}}
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def not_implemented
      msg = %{This method is not implemented by this class; look in subclasses!}
      raise StandardError, msg.yellow.bold
    end

    def invalid_label_specified(name, label)
      msg = %{Invalid label specified for shape <#{name}>: #{label.inspect}}
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def no_parameter_spec_matches_arguments(keyword_args, parameter_sets)
      parameter_sets_str = parameter_sets.join("\n")
      msg = %{
        The keyword arguments provided do not match any specified parameter set.
          Arguments: #{keyword_args.inspect}
          Parameter sets:
      }.tabto(0).trim + parameter_sets_str.indent(4)
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end

    def problem_processing_arguments(keyword_args, msg)
      msg = %{
        Error occurred while processing the arguments
          Arguments: #{keyword_args.inspect}
          Message:   #{msg}
      }.tabto(0).trim
      raise RGeom::Err::SpecificationError, msg.yellow.bold
    end
  end  # class << Err
end  # module RGeom

