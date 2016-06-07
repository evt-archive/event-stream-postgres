module EventStream
  module Postgres
    class Iterator
      class Error < RuntimeError; end

      attr_accessor :batch
      attr_writer :batch_position
      attr_writer :stream_offset

      def batch_position
        @batch_position ||= 0
      end

      def stream_offset
        @stream_offset ||= (stream_position || 0)
      end

      initializer :stream_name, :category, a(:stream_position, 0), :batch_size, :precedence

      dependency :session, Session
      dependency :logger, Telemetry::Logger

      def self.build(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        new(stream_name, category, stream_position, batch_size, precedence).tap do |instance|
          instance.configure(session: session)
        end
      end

      def self.configure(receiver, attr_name: nil, stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        attr_name ||= :reader
        instance = build(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)
        receiver.public_send attr_name, instance
      end

      def configure(session: nil)
        Session.configure self, session: session
        Telemetry::Logger.configure self
      end

      def next
        logger.opt_trace "Getting next event data (Batch Length: #{batch.nil? ? '<none>' : batch.length}, Batch Position: #{batch_position}, Stream Offset: #{stream_offset})"

        if batch.nil? || batch_position > batch.length
          self.batch = get_batch
          reset(batch)
        end

        event_data = batch[batch_position]

        logger.opt_debug "Done getting next event data (Batch Length: #{batch.nil? ? '<none>' : batch.length}, Batch Position: #{batch_position}, Stream Offset: #{stream_offset})"
        logger.opt_data "Event Data: #{event_data.inspect}"

        advance_positions

        event_data
      end

      def reset(batch)
        logger.opt_trace "Resetting batch"
        self.batch = batch
        self.batch_position = 0
        logger.opt_debug "Reset batch"
      end

      def advance_positions
        self.batch_position += 1
        self.stream_offset += 1
        logger.opt_debug "Advanced positions (Batch Position: #{batch_position}, Stream Offset: #{stream_offset})"
      end

      def get_batch
        logger.opt_trace "Getting batch"

        batch = Get.(stream_name: stream_name, category: category, stream_position: stream_offset, batch_size: batch_size, precedence: precedence, session: session)

        logger.opt_debug "Finished getting batch (Count: #{batch.length})"

        batch
      end
    end
  end
end
