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

Install `beanstalkd`

- Configure it to listen on `localhost` network
- Configure it to auto-start on system boot
- Give it a persistent store for queue data (needed in-order to not lose data)

Optional:  Install this Gem elsewhere
Optional:  

Set-up `backburner` to run in a daemon mode:

- Ruby "God" process supervisor (script provided by upstream)
- Upstart #TODO: copy scripts into a shared dir



## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/squashrepeater-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
