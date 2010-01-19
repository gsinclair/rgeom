#
# This file contains the implementations of Type.parse, Type::Compound.parse and
# Type::Alias.parse.  They're separated from the definitions of those classes
# (in lib/rgeom/dsl/types.rb) so that they may be kept clean.
#

module RGeom; module DSL; class Type;

  # == Type.parse(string)
  #
  # +string+ could be something like one of these:
  #   
  #   integer    point=origin     (segment,n=5)      [n,n]
  #
  # Our job is to work out what _kind_ of type it is (simple, compound, array)
  # and pass it off to Type::Compound.parse (etc.) for further processing.
  #
  # Return value: OpenStruct with the fields
  # ::type::        Instance of Type or Type::Alias or Type::Compound or Type::Array
  # ::default::     Default value, if one was specified
  # ::constraint::  Constraint, if one was specified (not yet implemented)
  #
  # To get this far, the +string+ has been through the Treetop parser, so we
  # can be sure it's well-formed.  It could have problems like two defaults or
  # a nonsensical constraint, though.
  def Type.parse(string)
    case string
    when nil
      raise ArgumentError, "No type string given"
    when /\A([a-z]+)(=[a-z0-9]+)?\Z/
      # Simple type with possible default.
      type = Type[$1] or Err::DSL.type_not_found(string, $1)
      default = Type::NO_DEFAULT
      if $2
        # Look up the 'value' of the specified default; e.g. "origin" -> Point[0,0]
        default = Value[$2.sub('=', '')]
      end
      constraint = nil
      OpenStruct.new(:type => type, :default => default, :constraint => constraint)
    when %r|\A \(  .*  \) \Z|x
      # Compound type.
      Type::Compound.parse(string)
    when %r|\A \[  .*  \] \Z|x
      # Array type.
      Type::Array.parse(string)
    else
      Err::DSL.type_string_doesnt_match_any_regex(string)
    end
  end

  class Compound
    # +string+ looks something like the following, our example for this code.
    #   (segment,number=5)
    def Compound.parse(string)
      label = string
      # 1. We don't need the brackets anymore.
      string = string[1..-2]         # "segment,number=5"
      # 2. Split on the commas so we can treat each type individually.
      data = string.split(',').map { |type_str|
        # 3. We're now dealing with a simple type like "point=origin",
        #    so we can hand it back to Type.parse.
        Type.parse(type_str)
      }
      # At this point, 'data' is an array of OpenStructs.  We need to ensure
      # that there's at most one default specified, then create the
      # Type::Compound object and generate the required OpenStruct for return.
      defaults = data.map { |o| o.default }.reject { |d| d == NO_DEFAULT }
      default =
        case defaults.size
        when 0; NO_DEFAULT
        when 1; defaults.first
        else;   Err.more_than_one_default_specified
        end
      constraint = nil
        # How would constraints work in a compound type anyway?  I think
        # constraints need to be part of the type, not part of the parameter.
      types = data.map { |o| o.type }
      OpenStruct.new( :type => Type::Compound.new(string, types),
                      :default => default, :constraint => constraint )
    end
  end

  class Array
    # +string+ looks something like the following, our example for this code.
    #   [length,length]
    # No defaults may be specified in an array type.
    def Array.parse(string)
      # This method is similar in implementation to Type::Compound.parse; which
      # see for commentary.
      label = string
      string = string[1..-2]         # "length,length"
      data = string.split(',').map { |type_str|
        Type.parse(type_str)
      }
        # -> [ OpenStruct[type, default, constraint] ]
      if data.map { |o| o.default }.find { |d| d != NO_DEFAULT }
        Err.no_default_can_be_specified_in_array_type
      end
      types = data.map { |o| o.type }
      OpenStruct.new( :type => Type::Array.new(label, types),
                      :default => NO_DEFAULT, :constraint => nil )
    end
  end

end; end; end   # class Type; module DSL; module RGeom
