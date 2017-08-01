module DruidDB
  class ZK
    attr_accessor :registry
    attr_reader :client, :config, :listeners

    #TODO: Test and handle ZK partitions
    def initialize(config)
      @client = ::ZK.new(config.zookeeper)
      @config = config
      @listeners = []
      @registry = {}
      register
    end

    def register_listener(object, method)
      listeners << ->(*args) { object.send(method, *args) }
    end

    private

    def announce(service)
      # puts "announcing #{service}"
      listeners.each { |listener| listener.call(service) }
    end

    def register
      register_service("#{config.discovery_path}/druid:broker")
      register_service("#{config.discovery_path}/druid:coordinator")
      register_service("#{config.discovery_path}/druid:overlord")
      register_service("#{config.kafka_broker_path}")
    end

    def register_service(service)
      # puts "registering #{service}"
      #TODO: Thead safety, lock this registry key
      subscribe_to_service(service)
      renew_service_instances(service)
    end

    def renew_service_instances(service)
      # puts "activating registered subscriptions on #{service}"
      instances = client.children(service, watch: true)

      # puts "emptying #{service} from registry"
      registry[service] = []
      instances.each do |instance|
        data = JSON.parse(client.get("#{service}/#{instance}").first)
        host = data['address'] || data['host']
        port = data['port']
        # puts "adding #{host}:#{port} to registry for #{service}"
        registry[service] << { host: host, port: port }
      end
    end

    def subscribe_to_service(service)
      subscription = client.register(service) do |event|
        # puts "watched event for #{service} detected"
        renew_service_instances(event.path)
        announce(event.path)
      end
    end
  end
end
