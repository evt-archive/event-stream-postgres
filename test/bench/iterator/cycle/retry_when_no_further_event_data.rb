require_relative '../../bench_init'

controls = EventStream::Postgres::Controls

context "Iterator" do
  context "Cycle" do
    context "Retry when no further event data" do
      iterator = Iterator.build(stream_name: 'some_stream', delay_milliseconds: 10, timeout_milliseconds: 100)

      cycle = iterator.cycle
      sink = Iterator::Cycle.register_telemetry_sink(cycle)

      iterator.next

      test "Didn't get result" do
        refute(sink.recorded_got_result?)
      end

      test "Delayed before retrying" do
        assert(sink.recorded_delayed?)
      end

      test "Timed out" do
        assert(sink.recorded_timed_out?)
      end
    end
  end
end
