# ResqueExtensions

Adds behavior to Resque to make it a bit more like Delayed::Job

To use, call `async` where you would have used `send_later`

ActiveRecord Objects are serialized with their class name and ID and pulled
out of the database when they are run.

## Usage

### Instance Method
    @my_instance = MyClass.find(params[:id])
    @my_instance.async(:expensive_method)

### Class Method
    # This will store just the ID of the MyClass instance passed in and pull 
    # it out of the DB when the code is run
    MyClass.async(:other_expensive_method, MyClass.find(1))

### Class Method on a class defined elsewhere

If you don't have access to the Class/Module you need (e.g. a Mailer that
is defined in a different codebase), you can use 
`ResqueExtensions.enqueue_class_method`

    ResqueExtensions.enqueue_class_method("MissingClass", :my_method, arg...)

### Serializing ActiveRecord objects

In Delayed::Job, you can enqueue whole objects or collections of objects,
which are then serialized by Marshal or YAML.  This is problematic for
several reasons

1. Objects enqueued in one version of Ruby may not be able to be loaded in
    another
2. The underlying data may have changed and we can have an invalid version
    of the object when our job is performed
3. It is hard to debug jobs and determine exactly what they are doing because
    Marshal and YAML are not particularly readable formats

To get around this ResqueExtensions serializes Classes and ActiveRecords in
a string format and then constantizes them or pulls them from the database
when the job is performed.

This allows us to enqueue jobs in a very flexible way.  The following would
be converted to strings and the objects would be reified when the job is 
performed.

    my_instance.async(:my_method, other_instance, array_of_instances)


### Specifying a Queue

You can specify a queue to run this job in when you enqueue it as an optional
last argument

    MyClass.async(
      :other_expensive_method, MyClass.find(1), :queue => "custom-queue"
    )


## Installation

Add this line to your application's Gemfile:

    gem 'resque_extensions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque_extensions

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
