module EventStream
  module Postgres
    class Get
      initializer :stream_name, :category, :stream_position, :batch_size, :precedence

      dependency :session, Session
      dependency :logger, Telemetry::Logger

      def self.build(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        new(stream_name, category, stream_position, batch_size, precedence).tap do |instance|
          instance.configure(session: session)
        end
      end

      def self.configure(receiver, attr_name: nil, stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        attr_name ||= :get
        instance = build(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)
        receiver.public_send attr_name, instance
      end

      def self.call(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        instance = build(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)
        instance.()
      end

      def configure(session: nil)
        Session.configure self, session: session
        Telemetry::Logger.configure self
      end

      def call
        get_event_data
      end

      def get_event_data
        logger.opt_trace "Getting event data (Stream Name: #{stream_name.inspect}, Category: #{category.inspect}, Stream Position: #{stream_position.inspect}, Batch Size: #{batch_size.inspect}, Precedence: #{precedence.inspect})"

        stream = Stream.build stream_name: stream_name, category: category
        records = get_records(stream)

        events = convert(records)

        logger.opt_debug "Finished getting event data (Count: #{events.length}, Stream Name: #{stream_name.inspect}, Category: #{category.inspect}, Stream Position: #{stream_position.inspect}, Batch Size: #{batch_size.inspect}, Precedence: #{precedence.inspect})"

        events
      end

      def get_records(stream)
        logger.opt_trace "Getting records (Stream: #{stream.name}, Stream Position: #{stream_position.inspect}, Batch Size: #{batch_size.inspect}, Precedence: #{precedence.inspect})"

        select_statement = SelectStatement.build(stream, offset: stream_position, batch_size: batch_size, precedence: precedence)

        records = session.connection.exec_params(select_statement.sql, select_statement.args)

        logger.opt_debug "Finished getting records (Count: #{records.ntuples}, Stream: #{stream.name}, Stream Position: #{stream_position.inspect}, Batch Size: #{batch_size.inspect}, Precedence: #{precedence.inspect})"

        records
      end

      def convert(records)
        logger.opt_trace "Converting records to events (Records Count: #{records.ntuples})"

        events = records.map do |record|
          record['data'] = Deserialize.data(record['data'])
          record['metadata'] = Deserialize.metadata(record['metadata'])
          record['created_time'] = Time.utc_coerced(record['created_time'])

          EventData::Read.build record
        end

        logger.opt_debug "Converted records to events (Events Count: #{events.length})"

        events
      end

      module Deserialize
        def self.data(serialized_data)
          Serialize::Read.(serialized_data, EventData::Hash, :json)
        end

        def self.metadata(serialized_metadata)
          if serialized_metadata.nil?
            nil
          else
            Serialize::Read.(serialized_metadata, EventData::Hash, :json)
          end
        end
      end

      module Time
        def self.utc_coerced(local_time)
          Clock::UTC.coerce(local_time)
        end
      end
    end
  end
end
