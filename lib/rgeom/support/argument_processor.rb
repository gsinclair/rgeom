
# Helps to make sense of the mixture of arguments that are used to define shapes.
#
# Given arguments:
#   :ABC, :scalene, :dashed, :blue, { :base => 8, :angles => [13, 75] }
#
# We can do:
#   extract_vertices       # -> [:A, :B, :C]
#   extract(:iscosceles, :equilateral, :scalene)   # -> :scalene
#   extract(:base)                                 # -> 8
#   extract(:dashed)                               # -> :dashed
#   extract(:angles)                               # -> [13, 75]
#   extract(:nonexistent)                          # -> nil
#   given                  # -> [:ABC, :scalene, :dashed, :base, :angles]
#                          # Note: blue does not appear because it was never
#                            asked for.  And the keys :base and :angles are
#                            included but not their values.
#
# So "extract" can accept multiple keys, but will only return the first one it finds.
class ArgumentProcessor
  def initialize(args=[])
    @hash = Dictionary.new
    args.each do |arg|
      if @hash.key? arg
        STDERR.puts "Warning: repeated argument '#{arg.inspect}'"
      end
      if arg.is_a? Hash
        @hash = @hash.merge(arg)
      else
        @hash[arg] = arg
      end
    end
    @keyset = Set.new(@hash.keys)
    @processed = Set.new
  end
  def to_s() "ArgumentProcessor: #{@hash.inspect}" end
  def inspect() to_s end
    # Returns the data (keys only) that _has_ been processed.
  def processed() @processed end
    # Returns the data (keys and values) that has _not_ been processed.
  def unprocessed()
    unprocessed_keys = @keyset - @processed
    unprocessed_keys.build_hash do |key|
      [key, @hash[key]]
    end
  end
    # Extract a single piece of data.  If multiple keys are given, extract the first one
    # that matches.
  def extract(*keys)
    if keys.size == 1
      match, value = extract_single(keys.first)
    elsif keys.size > 1
      match, value = extract_multi(keys)
    end
    if match.not_nil?
      @processed << match
      return value
    else
      return nil
    end
  end

    # Look for something like :ABC or :GM_ and return it.
  def extract_label(length)
    keys = @hash.keys.map { |k|
      k.to_s if k.is_a? Symbol and k.to_s =~ /^[A-Z_]+$/
    }
    keys = keys.compact.select { |k| k.length == length }
    return if keys.empty?
    sym = keys.first.to_sym
    @processed << sym
    return sym
  end

  def contains?(key)
    @hash.key? key
  end
    # Return a set of the "given" information, checked against the provided list.
    # May be useful for later code to know what information the user provided, as opposed
    # to default or derived information.
  def givens(*list)
    Set[*list] & @keyset
  end

  private

  def extract_single(key)
    if @hash.key? key
      return [key, @hash[key]]
    else
      return [nil, nil]
    end
  end
  def extract_multi(keys)
    key = @keyset.find { |elt| elt.in? keys }
    if key.not_nil?
      return [key, @hash[key]]
    else
      return [nil, nil]
    end
  end
end

