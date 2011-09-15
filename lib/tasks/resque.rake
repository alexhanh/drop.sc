require "resque/tasks"

task "resque:setup" => :environment do
  ENV['QUEUES'] = 'critical,high,low'
  
  # TODO: Find a better fix, see Evernote for details
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end