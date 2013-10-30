require 'spec_helper'

module ResqueExtensions

  describe AsyncMethod do

    context ".perform" do

      it "deserializes and calls a method on the caller" do
        async_method = AsyncMethod.new(MyClass, :my_class_method, "a")
        async_method.enqueue!

        # make sure we call the correct
        MyClass.expects(:send).with("my_class_method", "a")

        job = Resque.reserve("default")
        job.perform
      end

      it "deserializes and calls a method on an ActiveRecord" do

        my_instance = MyClass.create(:name => "Dan")

        async_method = AsyncMethod.new(my_instance, :my_instance_method)
        async_method.enqueue!

        MyClass.expects(:find).with(my_instance.id.to_s).returns(my_instance)
        my_instance.expects(:send).with("my_instance_method")

        job = Resque.reserve("default")
        job.perform

      end

      it 'properly looks up class names that are namespaced' do

        async_method = AsyncMethod.new(RootModule::InnerClass, :my_class_method, 'a')
        async_method.enqueue!

        RootModule::InnerClass.expects(:send).with('my_class_method', 'a')
        InnerClass.expects(:send).never

        job = Resque.reserve('default')
        job.perform
      end

    end


    context "#initialize" do

      it "initializes with a class" do

        async_method = AsyncMethod.new(MyClass, :my_class_method)
        async_method.should be_class_method

      end

      it "initializes with an instance" do

        async_method = AsyncMethod.new(MyClass.new, :my_class_method)
        async_method.should be_instance_method

      end

    end

    context "#args" do

      it "accepts a variable number of arguments" do

        async_method = AsyncMethod.new(
          MyClass, :my_class_method, :a, :b, "c"
        )
        async_method.args.should eql([:a, :b, "c"])

      end

      it "removes any options from the arguments" do
        async_method = AsyncMethod.new(
          MyClass, :my_class_method, :a, :b, {:queue => "test"}
        )
        async_method.args.should eql([:a, :b])
      end

    end

    context "#enqueue!" do

      it "creates a new job for the class or instance" do
        async_method = AsyncMethod.new(MyClass, :my_class_method)
        async_method.enqueue!

        job = Resque.reserve("default")

        job.payload.should eql({
          "class" => "ResqueExtensions::AsyncMethod",
          "args" => ["_Class::MyClass", "my_class_method"]
        })

      end

      it "serializes ActiveRecords passed in as the caller" do

        my_instance = MyClass.create(:name => "Dan")

        async_method = AsyncMethod.new(my_instance, :my_instance_method)
        async_method.enqueue!

        job = Resque.reserve("default")

        job.payload.should eql({
          "class" => "ResqueExtensions::AsyncMethod",
          "args" => [
            "_ActiveRecord::MyClass::#{my_instance.id}",
            "my_instance_method"
          ]
        })

      end

      it "serializes ActiveRecords passed in as arguments" do

        my_instance = MyClass.create(:name => "Dan")

        async_method = AsyncMethod.new(
          MyClass,
          :my_class_method,
          [my_instance],
          my_instance,
          {:a => my_instance}
        )
        async_method.enqueue!

        instance_string = "_ActiveRecord::MyClass::#{my_instance.id}"


        job = Resque.reserve("default")

        job.payload.should eql({
          "class" => "ResqueExtensions::AsyncMethod",
          "args" => [
            "_Class::MyClass",
            "my_class_method",
            [instance_string],
            instance_string,
            {"a" => instance_string}
          ]
        })

      end
    end

    context "#queue" do

      it "sets the queue if it is passed as an argument" do

        async_method = AsyncMethod.new(
          MyClass, :my_class_method, :queue => "test"
        )
        async_method.queue.should eql("test")

      end

    end

  end

end