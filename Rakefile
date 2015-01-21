require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec) do |task|
    task.rspec_opts = ["--color"]
    # task.rspec_opts = ["--color", "--format", "nested"]
  end
rescue LoadError
end

task :default => :spec
