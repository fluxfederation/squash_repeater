# Squashrepeater::Ruby

One difficulty with Squash is that whenever any exception occurs, it contacts the
Squash server to upload details of that failure, which means the code blocks until
contact is made or the connection times-out.

In many cases, an exception is a failure, and you probably don't want to be nice
about it, but for user-facing app's, you're degrading the user-experience even
further.  A quick-response "failure" is still many times better.

On top of that, almost all exceptions are valuable, in that they have captured a
failure-mode that you weren't previously aware of.  If the server is down, then the
chances are that data is lost.

Squash Repeater uses a low-overhead queueing service to capture any exceptions and
return control as quickly as possible, after which an independent "worker" process
will attempt to send the queued exception reports to the Squash server.
This should mean:
- the local Squash client code can return far more quickly
- any exception reports that fail to be accepted by the Squash server aren't lost
  (or dropped from the queue)
- we can "distribute" part of the Squash service throughout all the client servers

It doesn't solve things like
- multi-homed / distributed Squash server

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'squashrepeater-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install squashrepeater-ruby

If you're using Rails, you can install an initialiser template with:

 #TODO(willjr): Is this correct?

    $ bundle exec rails generate intitializer squashrepeater

## Install `beanstalkd`

- Configure it to listen on `localhost` network
- Configure it to auto-start on system boot
- Give it a persistent store for queue data (needed in-order to not lose data)

## Configure `backburner`

`backburner` is the Gem used to interact with the `beanstalk` queue.
It works in two parts:  client libraries that put data on the queue, and background-worker jobs that process the data on
queue.

Simply adding the Gem to your app will configure the client part with useful defaults.

To enable the background-worker part, you need to be able to automatically start the `backburner` worker.
The `backburner` Gem documentation covers this is detail, but they include a God script.

I've included a set of example Ubuntu Upstart scripts in the `share/upstart` directory, which you will need to update
with details like "app_name" and "app_dir" and install to your machine's `/etc/init/` dir.
You may also need to make other adjustments to it according to your needs and/or skill.

Alternatively, you can either start `backburner` in daemon mode with:

    $ cd ${app_dir}
    $ bundle exec backburner -d -r ${app_config}

Or wrapped with some-other daemoniser (such as Niet) with:

    $ niet -t backburner -c ${app_dir} -- bundle exec backburner -r ${app_config}

NB: Replace ${app_dir} with the directory your app is installed to, and ${app_config} with the path to your Squash
Repeater config.

## Configure Squash Repeater

You need to `require "squashrepeater/ruby"` and then use `SquashRepeater::Ruby.configure` to configure it, e.g:

```ruby
require "squashrepeater/ruby"

SquashRepeater::Ruby.configure do |c|
  # The nature of SquashRepeater is that a tiny local queueing system
  # captures the Squash notification, and retransmits it from a worker.
  # Therefore, we assume beanstalkd is running locally:

  ###
  # Backburner defaults:
  # c.queue_host = "localhost"
  # c.namespace = "squash-repeater"

  ###
  # You can set Squash::Ruby config here, or through their configration method. Either way, they must be set:
  # @param api_host:
  # c.squash_url = "http://no.where"
  # @param api_key:
  # c.squash_key = "12345"
  # @param environment:
  c.environment = Rails.env if defined? Rails.env

  ###
  # This sets the Backburner (queue) logging.  There's no easy way to set Squash to use Logger:
  c.logger = Rails.logger if defined? Rails.logger
end
```

As mentioned above, you can configure a few `Squash::Ruby` settings via this config block, or configure it in the Squash
way via `Squash::Ruby.configure()`

## Contributing

 #TODO(willjr): Update

1. Fork it ( https://github.com/[my-github-username]/squashrepeater-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
