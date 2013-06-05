require 'resque'

require "resque_extensions/version"
require "resque_extensions/async_method"

module ResqueExtensions

  # Whether or not we should be running 
  # asynchronously
  def self.async
    # if we have never set @async, we default
    # to true
    if @async.nil?
      @async = true
    end
    return @async
  end

  # Whether or not we should be running asynchronously
  # 
  # @example
  #   ResqueExtensions.async = false
  #   MyInstance.async(:do_something) # => calls synchronously
  # 
  def self.async=(new_val)
    @async = new_val
  end
  
  def self.enqueue_class_method(klass, *args)
    klass = "#{AsyncMethod::CLASS_PREFIX}#{klass}"
    AsyncMethod.new(klass, *args).enqueue!
  end

  module ObjectMethods
    # call this method asynchronously
    def async(*args)
      if ResqueExtensions.async == true
        ResqueExtensions::AsyncMethod.new(self, *args).enqueue!
      # just call inline
      else
        self.send(*args)
      end
    end
  end
end

Object.send(:extend, ResqueExtensions::ObjectMethods)
Object.send(:include, ResqueExtensions::ObjectMethods)
