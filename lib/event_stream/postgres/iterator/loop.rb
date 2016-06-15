module EventStream
  module Postgres
    class Iterator
      class Loop
        def stop_time
          @stop_time ||= Time.now + sleep_time * 2
        end

        def sleep_time
          10
        end

        dependency :logger, Telemetry::Logger

        initializer :wait_condition

        def self.build(wait_condition)
          new(wait_condition).tap do |instance|
            Telemetry::Logger.configure instance
          end
        end

        def self.call(wait_condition, &blk)
          instance = build(wait_condition)
          instance.call(&blk)
        end

        def call(&blk)
          result = nil
          loop do
            result = blk.call

            if wait_condition.(result)
              logger.focus "no result. waiting."
              sleep sleep_time
            else
              logger.focus "got result. returning."
              break
            end

            if Time.now >= stop_time
              break
            end

          end
          result
        end
      end
    end
  end
end
