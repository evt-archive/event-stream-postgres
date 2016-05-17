module EventStream
  module Postgres
    class Session
      def self.settings
        Settings.names
      end

      settings.each do |s|
        setting s
      end

      dependency :connection, PG::Connection
      dependency :logger, Telemetry::Logger

      def self.build(connection: nil, settings: nil)
        new.tap do |instance|
          Telemetry::Logger.configure instance

          settings ||= Settings.instance

          settings.set(instance)

          instance.connection = connect(instance)

          logger.opt_debug "Built HTTP session (Host: #{instance.host}, Port: #{instance.port})"
        end
      end

      def self.configure(receiver, session: nil, attr_name: nil)
        attr_name ||= :session

        instance = session || build
        receiver.public_send "#{attr_name}=", instance
        instance
      end

      def self.connect(instance)
        settings = instance.settings
        logger.trace "Connecting to database (Settings: #{settings.inspect})"

        connection = PG::Connection.open(settings)
        connection.type_map_for_results = PG::BasicTypeMapForResults.new(connection)

        instance.connection = connection

        logger.trace "Connected to database (Settings: #{settings.inspect})"

        connection
      end

      def connected?
        connection.status == PG::CONNECTION_OK
      end

      def close
        connection.close
      end

      def reset
        connection.reset
      end

      def settings
        settings = {}
        self.class.settings do |s|
          settings[s] = public_send(s)
        end
        settings
      end

      def self.logger
        @logger ||= Telemetry::Logger.get self
      end
    end
  end
end
