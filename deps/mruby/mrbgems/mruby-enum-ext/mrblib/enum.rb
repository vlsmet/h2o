##
# Enumerable
#
module Enumerable
  ##
  # call-seq:
  #    enum.drop(n)               -> array
  #
  # Drops first n elements from <i>enum</i>, and returns rest elements
  # in an array.
  #
  #    a = [1, 2, 3, 4, 5, 0]
  #    a.drop(3)             #=> [4, 5, 0]

  def drop(n)
    n = n.__to_int
    raise ArgumentError, "attempt to drop negative size" if n < 0

    ary = []
    self.each {|*val| n == 0 ? ary << val.__svalue : n -= 1 }
    ary
  end

  ##
  # call-seq:
  #    enum.drop_while {|arr| block }   -> array
  #    enum.drop_while                  -> an_enumerator
  #
  # Drops elements up to, but not including, the first element for
  # which the block returns +nil+ or +false+ and returns an array
  # containing the remaining elements.
  #
  # If no block is given, an enumerator is returned instead.
  #
  #    a = [1, 2, 3, 4, 5, 0]
  #    a.drop_while {|i| i < 3 }   #=> [3, 4, 5, 0]

  def drop_while(&block)
    return to_enum :drop_while unless block

    ary, state = [], false
    self.each do |*val|
      state = true if !state and !block.call(*val)
      ary << val.__svalue if state
    end
    ary
  end

  ##
  # call-seq:
  #    enum.take(n)               -> array
  #
  # Returns first n elements from <i>enum</i>.
  #
  #    a = [1, 2, 3, 4, 5, 0]
  #    a.take(3)             #=> [1, 2, 3]

  def take(n)
    n = n.__to_int
    i = n.to_i
    raise ArgumentError, "attempt to take negative size" if i < 0
    ary = []
    return ary if i == 0
    self.each do |*val|
      ary << val.__svalue
      i -= 1
      break if i == 0
    end
    ary
  end

  ##
  # call-seq:
  #    enum.take_while {|arr| block }   -> array
  #    enum.take_while                  -> an_enumerator
  #
  # Passes elements to the block until the block returns +nil+ or +false+,
  # then stops iterating and returns an array of all prior elements.
  #
  # If no block is given, an enumerator is returned instead.
  #
  #     a = [1, 2, 3, 4, 5, 0]
  #     a.take_while {|i| i < 3 }   #=> [1, 2]
  #
  def take_while(&block)
    return to_enum :take_while unless block

    ary = []
    self.each do |*val|
      return ary unless block.call(*val)
      ary << val.__svalue
    end
    ary
  end

  ##
  # Iterates the given block for each array of consecutive <n>
  # elements.
  #
  # @return [nil]
  #
  # @example
  #     (1..10).each_cons(3) {|a| p a}
  #     # outputs below
  #     [1, 2, 3]
  #     [2, 3, 4]
  #     [3, 4, 5]
  #     [4, 5, 6]
  #     [5, 6, 7]
  #     [6, 7, 8]
  #     [7, 8, 9]
  #     [8, 9, 10]

  def each_cons(n, &block)
    n = n.__to_int
    raise ArgumentError, "invalid size" if n <= 0

    return to_enum(:each_cons,n) unless block
    ary = []
    n = n.to_i
    self.each do |*val|
      ary.shift if ary.size == n
      ary << val.__svalue
      block.call(ary.dup) if ary.size == n
    end
    nil
  end

  ##
  # Iterates the given block for each slice of <n> elements.
  #
  # @return [nil]
  #
  # @example
  #     (1..10).each_slice(3) {|a| p a}
  #     # outputs below
  #     [1, 2, 3]
  #     [4, 5, 6]
  #     [7, 8, 9]
  #     [10]

  def each_slice(n, &block)
    n = n.__to_int
    raise ArgumentError, "invalid slice size" if n <= 0

    return to_enum(:each_slice,n) unless block
    ary = []
    n = n.to_i
    self.each do |*val|
      ary << val.__svalue
      if ary.size == n
        block.call(ary)
        ary = []
      end
    end
    block.call(ary) unless ary.empty?
    nil
  end

  ##
  # call-seq:
  #    enum.group_by {| obj | block }  -> a_hash
  #    enum.group_by                   -> an_enumerator
  #
  # Returns a hash, which keys are evaluated result from the
  # block, and values are arrays of elements in <i>enum</i>
  # corresponding to the key.
  #
  #     (1..6).group_by {|i| i%3}   #=> {0=>[3, 6], 1=>[1, 4], 2=>[2, 5]}
  #
  def group_by(&block)
    return to_enum :group_by unless block

    h = {}
    self.each do |*val|
      key = block.call(*val)
      sv = val.__svalue
      h.key?(key) ? (h[key] << sv) : (h[key] = [sv])
    end
    h
  end

  ##
  # call-seq:
  #    enum.sort_by { |obj| block }   -> array
  #    enum.sort_by                   -> an_enumerator
  #
  # Sorts <i>enum</i> using a set of keys generated by mapping the
  # values in <i>enum</i> through the given block.
  #
  # If no block is given, an enumerator is returned instead.

  def sort_by(&block)
    return to_enum :sort_by unless block

    ary = []
    orig = []
    self.each_with_index{|e, i|
      orig.push(e)
      ary.push([block.call(e), i])
    }
    if ary.size > 1
      ary.sort!
    end
    ary.collect{|e,i| orig[i]}
  end

  ##
  # call-seq:
  #    enum.first       ->  obj or nil
  #    enum.first(n)    ->  an_array
  #
  # Returns the first element, or the first +n+ elements, of the enumerable.
  # If the enumerable is empty, the first form returns <code>nil</code>, and the
  # second form returns an empty array.
  def first(*args)
    case args.length
    when 0
      self.each do |*val|
        return val.__svalue
      end
      return nil
    when 1
      i = args[0].__to_int
      raise ArgumentError, "attempt to take negative size" if i < 0
      ary = []
      return ary if i == 0
      self.each do |*val|
        ary << val.__svalue
        i -= 1
        break if i == 0
      end
      ary
    else
      raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 0..1)"
    end
  end

  ##
  # call-seq:
  #    enum.count                 -> int
  #    enum.count(item)           -> int
  #    enum.count { |obj| block } -> int
  #
  # Returns the number of items in +enum+ through enumeration.
  # If an argument is given, the number of items in +enum+ that
  # are equal to +item+ are counted.  If a block is given, it
  # counts the number of elements yielding a true value.
  def count(v=NONE, &block)
    count = 0
    if block
      self.each do |*val|
        count += 1 if block.call(*val)
      end
    else
      if v == NONE
        self.each { count += 1 }
      else
        self.each do |*val|
          count += 1 if val.__svalue == v
        end
      end
    end
    count
  end

  ##
  # call-seq:
  #    enum.flat_map       { |obj| block } -> array
  #    enum.collect_concat { |obj| block } -> array
  #    enum.flat_map                       -> an_enumerator
  #    enum.collect_concat                 -> an_enumerator
  #
  # Returns a new array with the concatenated results of running
  # <em>block</em> once for every element in <i>enum</i>.
  #
  # If no block is given, an enumerator is returned instead.
  #
  #    [1, 2, 3, 4].flat_map { |e| [e, -e] } #=> [1, -1, 2, -2, 3, -3, 4, -4]
  #    [[1, 2], [3, 4]].flat_map { |e| e + [100] } #=> [1, 2, 100, 3, 4, 100]
  def flat_map(&block)
    return to_enum :flat_map unless block

    ary = []
    self.each do |*e|
      e2 = block.call(*e)
      if e2.respond_to? :each
        e2.each {|e3| ary.push(e3) }
      else
        ary.push(e2)
      end
    end
    ary
  end
  alias collect_concat flat_map

  ##
  # call-seq:
  #    enum.max_by {|obj| block }      -> obj
  #    enum.max_by                     -> an_enumerator
  #
  # Returns the object in <i>enum</i> that gives the maximum
  # value from the given block.
  #
  # If no block is given, an enumerator is returned instead.
  #
  #    %w[albatross dog horse].max_by {|x| x.length }   #=> "albatross"

  def max_by(&block)
    return to_enum :max_by unless block

    first = true
    max = nil
    max_cmp = nil

    self.each do |*val|
      if first
        max = val.__svalue
        max_cmp = block.call(*val)
        first = false
      else
        if (cmp = block.call(*val)) > max_cmp
          max = val.__svalue
          max_cmp = cmp
        end
      end
    end
    max
  end

  ##
  # call-seq:
  #    enum.min_by {|obj| block }      -> obj
  #    enum.min_by                     -> an_enumerator
  #
  # Returns the object in <i>enum</i> that gives the minimum
  # value from the given block.
  #
  # If no block is given, an enumerator is returned instead.
  #
  #    %w[albatross dog horse].min_by {|x| x.length }   #=> "dog"

  def min_by(&block)
    return to_enum :min_by unless block

    first = true
    min = nil
    min_cmp = nil

    self.each do |*val|
      if first
        min = val.__svalue
        min_cmp = block.call(*val)
        first = false
      else
        if (cmp = block.call(*val)) < min_cmp
          min = val.__svalue
          min_cmp = cmp
        end
      end
    end
    min
  end

  ##
  #  call-seq:
  #     enum.minmax                  -> [min, max]
  #     enum.minmax { |a, b| block } -> [min, max]
  #
  #  Returns two elements array which contains the minimum and the
  #  maximum value in the enumerable.  The first form assumes all
  #  objects implement <code>Comparable</code>; the second uses the
  #  block to return <em>a <=> b</em>.
  #
  #     a = %w(albatross dog horse)
  #     a.minmax                                  #=> ["albatross", "horse"]
  #     a.minmax { |a, b| a.length <=> b.length } #=> ["dog", "albatross"]

  def minmax(&block)
    max = nil
    min = nil
    first = true

    self.each do |*val|
      if first
        val = val.__svalue
        max = val
        min = val
        first = false
      else
        val = val.__svalue
        if block
          max = val if block.call(val, max) > 0
          min = val if block.call(val, min) < 0
        else
          max = val if (val <=> max) > 0
          min = val if (val <=> min) < 0
        end
      end
    end
    [min, max]
  end

  ##
  #  call-seq:
  #     enum.minmax_by { |obj| block } -> [min, max]
  #     enum.minmax_by                 -> an_enumerator
  #
  #  Returns a two element array containing the objects in
  #  <i>enum</i> that correspond to the minimum and maximum values respectively
  #  from the given block.
  #
  #  If no block is given, an enumerator is returned instead.
  #
  #     %w(albatross dog horse).minmax_by { |x| x.length }   #=> ["dog", "albatross"]

  def minmax_by(&block)
    return to_enum :minmax_by unless block

    max = nil
    max_cmp = nil
    min = nil
    min_cmp = nil
    first = true

    self.each do |*val|
      if first
        max = min = val.__svalue
        max_cmp = min_cmp = block.call(*val)
        first = false
     else
        if (cmp = block.call(*val)) > max_cmp
          max = val.__svalue
          max_cmp = cmp
        end
        if (cmp = block.call(*val)) < min_cmp
          min = val.__svalue
          min_cmp = cmp
        end
      end
    end
    [min, max]
  end

  ##
  #  call-seq:
  #     enum.none? [{ |obj| block }]   -> true or false
  #     enum.none?(pattern)            -> true or false
  #
  #  Passes each element of the collection to the given block. The method
  #  returns <code>true</code> if the block never returns <code>true</code>
  #  for all elements. If the block is not given, <code>none?</code> will return
  #  <code>true</code> only if none of the collection members is true.
  #
  #  If a pattern is supplied instead, the method returns whether
  #  <code>pattern === element</code> for none of the collection members.
  #
  #     %w(ant bear cat).none? { |word| word.length == 5 } #=> true
  #     %w(ant bear cat).none? { |word| word.length >= 4 } #=> false
  #     %w{ant bear cat}.none?(/d/)                        #=> true
  #     [1, 3.14, 42].none?(Float)                         #=> false
  #     [].none?                                           #=> true
  #     [nil, false].none?                                 #=> true
  #     [nil, true].none?                                  #=> false

  def none?(pat=NONE, &block)
    if pat != NONE
      self.each do |*val|
        return false if pat === val.__svalue
      end
    elsif block
      self.each do |*val|
        return false if block.call(*val)
      end
    else
      self.each do |*val|
        return false if val.__svalue
      end
    end
    true
  end

  ##
  #  call-seq:
  #    enum.one? [{ |obj| block }]   -> true or false
  #    enum.one?(pattern)            -> true or false
  #
  # Passes each element of the collection to the given block. The method
  # returns <code>true</code> if the block returns <code>true</code>
  # exactly once. If the block is not given, <code>one?</code> will return
  # <code>true</code> only if exactly one of the collection members is
  # true.
  #
  # If a pattern is supplied instead, the method returns whether
  # <code>pattern === element</code> for exactly one collection member.
  #
  #    %w(ant bear cat).one? { |word| word.length == 4 }  #=> true
  #    %w(ant bear cat).one? { |word| word.length > 4 }   #=> false
  #    %w(ant bear cat).one? { |word| word.length < 4 }   #=> false
  #    %w{ant bear cat}.one?(/t/)                         #=> false
  #    [nil, true, 99].one?                               #=> false
  #    [nil, true, false].one?                            #=> true
  #    [ nil, true, 99 ].one?(Integer)                    #=> true
  #    [].one?                                            #=> false

  def one?(pat=NONE, &block)
    count = 0
    if pat!=NONE
      self.each do |*val|
        count += 1 if pat === val.__svalue
        return false if count > 1
      end
    elsif block
      self.each do |*val|
        count += 1 if block.call(*val)
        return false if count > 1
      end
    else
      self.each do |*val|
        count += 1 if val.__svalue
        return false if count > 1
      end
    end

    count == 1 ? true : false
  end

  # ISO 15.3.2.2.1
  #  call-seq:
  #     enum.all? [{ |obj| block } ]   -> true or false
  #     enum.all?(pattern)             -> true or false
  #
  #  Passes each element of the collection to the given block. The method
  #  returns <code>true</code> if the block never returns
  #  <code>false</code> or <code>nil</code>. If the block is not given,
  #  Ruby adds an implicit block of <code>{ |obj| obj }</code> which will
  #  cause #all? to return +true+ when none of the collection members are
  #  +false+ or +nil+.
  #
  #  If a pattern is supplied instead, the method returns whether
  #  <code>pattern === element</code> for every collection member.
  #
  #     %w[ant bear cat].all? { |word| word.length >= 3 } #=> true
  #     %w[ant bear cat].all? { |word| word.length >= 4 } #=> false
  #     %w[ant bear cat].all?(/t/)                        #=> false
  #     [1, 2i, 3.14].all?(Numeric)                       #=> true
  #     [nil, true, 99].all?                              #=> false
  #
  def all?(pat=NONE, &block)
    if pat != NONE
      self.each{|*val| return false unless pat === val.__svalue}
    elsif block
      self.each{|*val| return false unless block.call(*val)}
    else
      self.each{|*val| return false unless val.__svalue}
    end
    true
  end

  # ISO 15.3.2.2.2
  #  call-seq:
  #     enum.any? [{ |obj| block }]   -> true or false
  #     enum.any?(pattern)            -> true or false
  #
  #  Passes each element of the collection to the given block. The method
  #  returns <code>true</code> if the block ever returns a value other
  #  than <code>false</code> or <code>nil</code>. If the block is not
  #  given, Ruby adds an implicit block of <code>{ |obj| obj }</code> that
  #  will cause #any? to return +true+ if at least one of the collection
  #  members is not +false+ or +nil+.
  #
  #  If a pattern is supplied instead, the method returns whether
  #  <code>pattern === element</code> for any collection member.
  #
  #     %w[ant bear cat].any? { |word| word.length >= 3 } #=> true
  #     %w[ant bear cat].any? { |word| word.length >= 4 } #=> true
  #     %w[ant bear cat].any?(/d/)                        #=> false
  #     [nil, true, 99].any?(Integer)                     #=> true
  #     [nil, true, 99].any?                              #=> true
  #     [].any?                                           #=> false
  #
  def any?(pat=NONE, &block)
    if pat != NONE
      self.each{|*val| return true if pat === val.__svalue}
    elsif block
      self.each{|*val| return true if block.call(*val)}
    else
      self.each{|*val| return true if val.__svalue}
    end
    false
  end

  ##
  #  call-seq:
  #    enum.each_with_object(obj) { |(*args), memo_obj| ... }  ->  obj
  #    enum.each_with_object(obj)                              ->  an_enumerator
  #
  #  Iterates the given block for each element with an arbitrary
  #  object given, and returns the initially given object.
  #
  #  If no block is given, returns an enumerator.
  #
  #     (1..10).each_with_object([]) { |i, a| a << i*2 }
  #     #=> [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
  #

  def each_with_object(obj, &block)
    return to_enum(:each_with_object, obj) unless block

    self.each {|*val| block.call(val.__svalue, obj) }
    obj
  end

  ##
  #  call-seq:
  #     enum.reverse_each { |item| block } ->  enum
  #     enum.reverse_each                  ->  an_enumerator
  #
  #  Builds a temporary array and traverses that array in reverse order.
  #
  #  If no block is given, an enumerator is returned instead.
  #
  #      (1..3).reverse_each { |v| p v }
  #
  #    produces:
  #
  #      3
  #      2
  #      1
  #

  def reverse_each(&block)
    return to_enum :reverse_each unless block

    ary = self.to_a
    i = ary.size - 1
    while i>=0
      block.call(ary[i])
      i -= 1
    end
    self
  end

  ##
  #  call-seq:
  #     enum.cycle(n=nil) { |obj| block }  ->  nil
  #     enum.cycle(n=nil)                  ->  an_enumerator
  #
  #  Calls <i>block</i> for each element of <i>enum</i> repeatedly _n_
  #  times or forever if none or +nil+ is given.  If a non-positive
  #  number is given or the collection is empty, does nothing.  Returns
  #  +nil+ if the loop has finished without getting interrupted.
  #
  #  Enumerable#cycle saves elements in an internal array so changes
  #  to <i>enum</i> after the first pass have no effect.
  #
  #  If no block is given, an enumerator is returned instead.
  #
  #     a = ["a", "b", "c"]
  #     a.cycle { |x| puts x }  # print, a, b, c, a, b, c,.. forever.
  #     a.cycle(2) { |x| puts x }  # print, a, b, c, a, b, c.
  #

  def cycle(nv = nil, &block)
    return to_enum(:cycle, nv) unless block

    n = nil

    if nv.nil?
      n = -1
    else
      n = nv.__to_int
      return nil if n <= 0
    end

    ary = []
    each do |*i|
      ary.push(i)
      yield(*i)
    end
    return nil if ary.empty?

    while n < 0 || 0 < (n -= 1)
      ary.each do |i|
        yield(*i)
      end
    end

    nil
  end

  ##
  #  call-seq:
  #     enum.find_index(value)          -> int or nil
  #     enum.find_index { |obj| block } -> int or nil
  #     enum.find_index                 -> an_enumerator
  #
  #  Compares each entry in <i>enum</i> with <em>value</em> or passes
  #  to <em>block</em>.  Returns the index for the first for which the
  #  evaluated value is non-false.  If no object matches, returns
  #  <code>nil</code>
  #
  #  If neither block nor argument is given, an enumerator is returned instead.
  #
  #     (1..10).find_index  { |i| i % 5 == 0 and i % 7 == 0 }  #=> nil
  #     (1..100).find_index { |i| i % 5 == 0 and i % 7 == 0 }  #=> 34
  #     (1..100).find_index(50)                                #=> 49
  #

  def find_index(val=NONE, &block)
    return to_enum(:find_index, val) if !block && val == NONE

    idx = 0
    if block
      self.each do |*e|
        return idx if block.call(*e)
        idx += 1
      end
    else
      self.each do |*e|
        return idx if e.__svalue == val
        idx += 1
      end
    end
    nil
  end

  ##
  #  call-seq:
  #     enum.zip(arg, ...)                  -> an_array_of_array
  #     enum.zip(arg, ...) { |arr| block }  -> nil
  #
  #  Takes one element from <i>enum</i> and merges corresponding
  #  elements from each <i>args</i>.  This generates a sequence of
  #  <em>n</em>-element arrays, where <em>n</em> is one more than the
  #  count of arguments.  The length of the resulting sequence will be
  #  <code>enum#size</code>.  If the size of any argument is less than
  #  <code>enum#size</code>, <code>nil</code> values are supplied. If
  #  a block is given, it is invoked for each output array, otherwise
  #  an array of arrays is returned.
  #
  #     a = [ 4, 5, 6 ]
  #     b = [ 7, 8, 9 ]
  #
  #     a.zip(b)                 #=> [[4, 7], [5, 8], [6, 9]]
  #     [1, 2, 3].zip(a, b)      #=> [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
  #     [1, 2].zip(a, b)         #=> [[1, 4, 7], [2, 5, 8]]
  #     a.zip([1, 2], [8])       #=> [[4, 1, 8], [5, 2, nil], [6, nil, nil]]
  #
  #     c = []
  #     a.zip(b) { |x, y| c << x + y }  #=> nil
  #     c                               #=> [11, 13, 15]
  #

  def zip(*arg, &block)
    result = block ? nil : []
    arg = arg.map do |a|
      unless a.respond_to?(:to_a)
        raise TypeError, "wrong argument type #{a.class} (must respond to :to_a)"
      end
      a.to_a
    end

    i = 0
    self.each do |*val|
      a = []
      a.push(val.__svalue)
      idx = 0
      while idx < arg.size
        a.push(arg[idx][i])
        idx += 1
      end
      i += 1
      if result.nil?
        block.call(a)
      else
        result.push(a)
      end
    end
    result
  end

  ##
  #  call-seq:
  #     enum.to_h  -> hash
  #
  #  Returns the result of interpreting <i>enum</i> as a list of
  #  <tt>[key, value]</tt> pairs.
  #
  #     %i[hello world].each_with_index.to_h
  #       # => {:hello => 0, :world => 1}
  #

  def to_h(&blk)
    h = {}
    if blk
      self.each do |v|
        v = blk.call(v)
        raise TypeError, "wrong element type #{v.class} (expected Array)" unless v.is_a? Array
        raise ArgumentError, "element has wrong array length (expected 2, was #{v.size})" if v.size != 2
        h[v[0]] = v[1]
      end
    else
      self.each do |*v|
        v = v.__svalue
        raise TypeError, "wrong element type #{v.class} (expected Array)" unless v.is_a? Array
        raise ArgumentError, "element has wrong array length (expected 2, was #{v.size})" if v.size != 2
        h[v[0]] = v[1]
      end
    end
    h
  end

  def uniq(&block)
    hash = {}
    if block
      self.each do|*v|
        v = v.__svalue
        hash[block.call(v)] ||= v
      end
    else
      self.each do|*v|
        v = v.__svalue
        hash[v] ||= v
      end
    end
    hash.values
  end

  def filter_map(&blk)
    return to_enum(:filter_map) unless blk

    ary = []
    self.each do |x|
      x = blk.call(x)
      ary.push x if x
    end
    ary
  end

  alias filter select

  ##
  # call-seq:
  #   enum.tally -> a_hash
  #
  # Tallys the collection.  Returns a hash where the keys are the
  # elements and the values are numbers of elements in the collection
  # that correspond to the key.
  #
  #    ["a", "b", "c", "b"].tally #=> {"a"=>1, "b"=>2, "c"=>1}
  def tally
    hash = {}
    self.each do |x|
      hash[x] = (hash[x]||0)+1
    end
    hash
  end
end
