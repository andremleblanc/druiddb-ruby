require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'druiddb'

namespace :db do
  namespace :test do
    task :prepare do
      client = DruidDB::Client.new(zookeeper: 'zookeeper:2181')
      client.submit_supervisor_spec("#{Dir.pwd}/spec/ingestion_specs/xwings_spec.json")
      puts client.supervisor_tasks
    end
  end
end
