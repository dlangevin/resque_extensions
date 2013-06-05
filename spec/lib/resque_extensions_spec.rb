require 'spec_helper'

describe ResqueExtensions do

  context ".enqueue_class_method" do

    it "enqueues a class method from a string" do
      ResqueExtensions.enqueue_class_method(
        "MyClass", :my_class_method
      )
      MyClass.expects(:send).with("my_class_method")

      job = Resque.reserve("default")
      job.perform
    end

  end

  context "ObjectMethods" do

    context ".async" do

      it "enqueues a class method resque" do

        MyClass.async(:my_class_method, "a", "b", "c")

        MyClass.expects(:send).with("my_class_method", "a", "b", "c")

        job = Resque.reserve("default")
        job.perform
      end

      it "calls the method if ResqueExtensions.async is 
        set to false" do
        begin
          ResqueExtensions.async = false

          my_instance = MyClass.create(:name => "Dan")
          my_instance.expects(:my_instance_method)

          # async just calls send when ResqueExtensions.async is false
          my_instance.async(:my_instance_method)

        ensure
          ResqueExtensions.async = true
        end
      end

    end

    context "#async" do

      it "enqueues an instance method resque" do

        my_class = MyClass.create(:name => "test")

        my_class.async(:my_instance_method, {:a => my_class})

        MyClass.stubs(:find).with(my_class.id.to_s).returns(my_class)

        my_class.expects(:send)
          .with(
            "my_instance_method", 
            has_entries("a" => instance_of(MyClass))
          )

        job = Resque.reserve("default")
        job.perform


      end

    end

  end

end