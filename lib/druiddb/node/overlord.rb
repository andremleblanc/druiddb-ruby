module DruidDB
  module Node
    class Overlord
      INDEXER_PATH = '/druid/indexer/v1/'.freeze
      RUNNING_TASKS_PATH = (INDEXER_PATH + 'runningTasks').freeze
      TASK_PATH = (INDEXER_PATH + 'task/').freeze
      SUPERVISOR_PATH = (INDEXER_PATH + 'supervisor/').freeze

      attr_reader :config, :zk
      def initialize(config, zk)
        @config = config
        @zk = zk
      end

      #TODO: DRY: copy/paste
      def connection
        overlord = zk.registry["#{config.discovery_path}/druid:overlord"].first
        raise DruidDB::ConnectionError, 'no druid overlords available' if overlord.nil?
        zk.registry["#{config.discovery_path}/druid:overlord"].rotate! # round-robin load balancing
        DruidDB::Connection.new(host: overlord[:host], port: overlord[:port])
      end

      def running_tasks(datasource_name = nil)
        response = connection.get(RUNNING_TASKS_PATH)
        raise ConnectionError, 'Could not retrieve running tasks' unless response.code.to_i == 200
        tasks = JSON.parse(response.body).map{|task| task['id']}
        tasks.select!{ |task| task.include? datasource_name } if datasource_name
        tasks ? tasks : []
      end

      def shutdown_task(task)
        response = connection.post(TASK_PATH + task + '/shutdown')
        raise ConnectionError, 'Unable to shutdown task' unless response.code.to_i == 200
        bounded_wait_for_shutdown(task)
      end

      def shutdown_tasks(datasource_name = nil)
        tasks = running_tasks(datasource_name)
        tasks.each{|task| shutdown_task(task)}
      end

      def supervisor_tasks
        response = connection.get(SUPERVISOR_PATH)
        raise ConnectionError, 'Could not retrieve supervisors' unless response.code.to_i == 200
        JSON.parse(response.body)
      end

      def submit_supervisor_spec(filepath)
        spec = JSON.parse(File.read(filepath))
        response = connection.post(SUPERVISOR_PATH, spec)
        raise ConnectionError, 'Unable to submit spec' unless response.code.to_i == 200
        JSON.parse(response.body)
      end

      private

      def bounded_wait_for_shutdown(task)
        condition = !(running_tasks.include? task)
        attempts = 0
        max = 10

        until(condition) do
          attempts += 1
          sleep 1
          condition = !(running_tasks.include? task)
          break if attempts >= max
        end

        raise ClientError, 'Task did not shutdown.' unless condition
        true
      end
    end
  end
end
