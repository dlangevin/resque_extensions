module ResqueExtensions
  class AsyncMethod

    OPTIONAL_SETTINGS = [:queue]

    ACTIVERECORD_PREFIX = "_ActiveRecord::"
    CLASS_PREFIX = "_Class::"


    attr_reader :args

    def self.perform(*args)
      self.new(*self.reify_data(args)).perform
    end

    # Constructor
    # @param [Object] caller The class or instance that is doing work
    # @param [String, Symbol] method The method we are calling
    # @param args Additional arguments we pass in
    def initialize(caller, method, *args)
      @caller = caller
      @method = method
      # set up our options
      self.set_options(args)
      # leftover args are assigned
      @args = args
    end

    # Is the caller a class or an instance of
    # a class
    def class_method?
      @caller.is_a?(Class)
    end

    # enqueue the job so that it can be
    # performed
    def enqueue!
      Resque::Job.create(
        self.queue, self.class, *self.data_to_enqueue
      )
    end

    # Is the caller an instance or a class
    def instance_method?
      !self.class_method?
    end

    # Run our method
    def perform
      @caller.send(@method, *@args)
    end

    # the queue for this job
    def queue
      @queue ||= "default"
    end


    protected

    def self.reify_data(data)
      # call recursively
      if data.is_a?(Array)
        data = data.collect{|d| self.reify_data(d)}
      # call on values
      elsif data.is_a?(Hash)
        data.each_pair do |k,v|
          data[k] = self.reify_data(v)
        end
      # our special ActiveRecord encoding
      elsif data.to_s =~ /^#{ACTIVERECORD_PREFIX}/
        # get our ActiveRecord back
        data = data.split("::")
        id = data.pop
        class_name = data[1..-1].join("::")
        data = Resque::Job.constantize(class_name).find(id)
      # classes become strings prefixed by _Class
      elsif data.to_s =~ /^#{CLASS_PREFIX}/
        data = Resque::Job.constantize(data.gsub(/^#{CLASS_PREFIX}/,''))
      end
      # return data
      data
    end

    def data_to_enqueue
      self.prepare_data([@caller, @method, *@args])
    end

    # prepare our data for Redis
    def prepare_data(data)
      # call recursively
      if data.is_a?(Array)
        data = data.collect{|d| self.prepare_data(d)}
      # call on values
      elsif data.is_a?(Hash)
        data.each_pair do |k,v|
          data[k] = self.prepare_data(v)
        end
      # our special ActiveRecord encoding
      elsif data.is_a?(ActiveRecord::Base)
        data = "_ActiveRecord::#{data.class}::#{data.id}"
      # classes become strings prefixed by _Class
      elsif data.is_a?(Class)
        data = "_Class::#{data.to_s}"
      end
      # return data
      data
    end

    # set the options passed in as instance variables
    def set_options(args)
      if self.has_options?(args.last)
        args.pop.each_pair do |key, val|
          instance_variable_set("@#{key}", val)
        end
      end
    end

    # Is the given argument a hash of valid options
    def has_options?(argument)
      return false unless argument.is_a?(Hash)
      # get our keys
      keys = argument.keys.collect(&:to_sym)
      # if we have overlaps, we've been passed options
      return (keys & OPTIONAL_SETTINGS).length > 0
    end
  end
end