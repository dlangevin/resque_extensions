require 'resque'

require "resque_extensions/version"
require "resque_extensions/async_method"

module ResqueExtensions
  
  def self.enqueue_class_method(klass, *args)
    klass = "#{AsyncMethod::CLASS_PREFIX}#{klass}"
    AsyncMethod.new(klass, *args).enqueue!
  end

  module ObjectMethods
    # call this method asynchronously
    def async(*args)
      ResqueExtensions::AsyncMethod.new(self, *args).enqueue!
    end
  end
end

Object.send(:extend, ResqueExtensions::ObjectMethods)
Object.send(:include, ResqueExtensions::ObjectMethods)
