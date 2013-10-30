
require 'resque_extensions'

require 'active_record'
require 'mock_redis'
require 'resque'


Bundler.setup

db_path = File.expand_path(
  File.dirname(__FILE__) + "/../tmp/test.sqlite"
)
puts db_path

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => db_path
)

Resque.redis = MockRedis.new

# This code will be run each time you run your specs.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.mock_with :mocha

  config.before(:each) do
    Resque.redis = MockRedis.new
  end

  config.before(:all) do

    ActiveRecord::Base.connection.create_table(:my_classes, :force => true) do |t|

      t.string(:name)
      t.timestamps
    end

    MyClass = Class.new(ActiveRecord::Base) do
      def my_instance_method(*args)
        return args
      end

      def self.my_class_method(*args)
        return args
      end

    end

    module RootModule
      class InnerClass
        def self.my_class_method(arg)
        end
      end
    end

    module InnerClass
      def self.my_class_method(arg)
      end
    end

  end

end