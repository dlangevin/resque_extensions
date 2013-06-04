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
