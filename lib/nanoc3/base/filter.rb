# encoding: utf-8

module Nanoc3

  # Nanoc3::Filter is responsible for filtering items. It is the superclass
  # for all textual filters.
  #
  # When creating a filter with a hash containing assigned variables, those
  # variables will be made available in the `@assigns` instance variable and
  # the {#assigns} method. The assigns itself will also be available as
  # instance variables and instance methods.
  #
  # @example Accessing assigns in different ways
  #
  #     filter = SomeFilter.new({ :foo => 'bar' })
  #     filter.instance_eval { @assigns[:foo] }
  #       # => 'bar'
  #     filter.instance_eval { assigns[:foo] }
  #       # => 'bar'
  #     filter.instance_eval { @foo }
  #       # => 'bar'
  #     filter.instance_eval { foo }
  #       # => 'bar'
  #
  # @abstract Subclass and override {#run} to implement a custom filter.
  class Filter

    # A hash containing variables that will be made available during
    # filtering.
    #
    # @return [Hash]
    attr_reader :assigns

    # Creates a new filter that has access to the given assigns.
    #
    # @param [Hash] a_assigns A hash containing variables that should be made
    #   available during filtering.
    def initialize(hash={})
      @assigns = hash
      hash.each_pair do |key, value|
        # Build instance variable
        instance_variable_set('@' + key.to_s, value)

        # Define method
        metaclass = (class << self ; self ; end)
        metaclass.send(:define_method, key) { value }
      end
    end

    # Sets the identifiers for this filter.
    #
    # @param [Array<Symbol>] identifier A list of identifiers to assign to
    #   this filter.
    #
    # @return [void]
    def self.identifiers(*identifiers)
      Nanoc3::Filter.register(self, *identifiers)
    end

    # Sets the identifier for this filter.
    #
    # @param [Symbol] identifier An identifier to assign to this filter.
    #
    # @return [void]
    def self.identifier(identifier)
      Nanoc3::Filter.register(self, identifier)
    end

    # Registers the given class as a filter with the given identifier.
    #
    # @param [Class, String] class_or_name The class to register, or a string
    #   containing the class name to register.
    #
    # @param [Array<Symbol>] identifiers A list of identifiers to assign to
    #   this filter.
    #
    # @return [void]
    def self.register(class_or_name, *identifiers)
      Nanoc3::Plugin.register(Nanoc3::Filter, class_or_name, *identifiers)
    end

    # Returns the filter with the given name (identifier)
    #
    # @param [String] name The name of the filter class to find
    #
    # @return [Class] The filter class with the given name
    def self.named(name)
      Nanoc3::Plugin.find(self, name)
    end

    # Runs the filter on the given content.
    #
    # @abstract
    #
    # @param [String] content The unprocessed content that should be filtered.
    #
    # @param [Hash] params A hash containing parameters. Filter subclasses can
    #   use these parameters to allow modifying the filter's behaviour.
    #
    # @return [String] The filtered content
    def run(content, params={})
      raise NotImplementedError.new("Nanoc3::Filter subclasses must implement #run")
    end

    # Returns the filename associated with the item that is being filtered.
    # It is in the format `item <identifier> (rep <name>)`.
    #
    # @return [String] The filename
    def filename
      if assigns[:layout]
        "layout #{assigns[:layout].identifier}"
      elsif assigns[:item]
        "item #{assigns[:item].identifier} (rep #{assigns[:item_rep].name})"
      else
        '?'
      end
    end

  end

end
