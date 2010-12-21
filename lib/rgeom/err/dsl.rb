
class RGeom::Err
  class DSL
  end

  class << DSL

    def _raise(exception_class, untrimmed_message)
      msg = untrimmed_message.tabto(0).trim.yellow.bold
      raise exception_class, "\n" + msg
    end

    def type_string_doesnt_match_any_regex(string)
      _raise SpecificationError, %{
        Type string doesn't match any of the regular expressions that
        are programmed to parse it: #{string.inspect}
      }
    end

    def type_not_found(string, type_str)
      _raise SpecificationError, %{
        In the given string #{string.inspect}, the type #{type_str.inspect} could not
        be resolved.  It has not been defined.  Defined types are:
          #{Type.index.keys.join(', ')}
      }
    end

    def construction_spec_nonexistent_parameter(symbol, parameters)
      _raise SpecificationError, %{
        You attempted to access parameter '#{symbol}' in a ConstructionSpec object,
        but it does not exist.  Parameters are:
          #{parameters.join(', ')}
      }
    end

  end  # class << DSL
end  # class RGeom::Err
