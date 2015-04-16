require 'squash_repeater'

module SquashRepeater::Console
  module_function

  def beanstalk
    Backburner::Worker.connection
  end

  def tube_namespace
    SquashRepeater.configuration.backburner.tube_namespace
  end


  def queue_name
    SquashRepeater::ExceptionQueue::queue
  end

  def fq_queue_name
    "#{tube_namespace}.#{queue_name}"
  end

  def queue
    beanstalk.tubes[fq_queue_name]
  end
end
