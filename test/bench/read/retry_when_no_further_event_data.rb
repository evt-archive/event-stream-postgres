require_relative '../bench_init'

context "Read" do
  cycle = Iterator::Cycle.build(delay_milliseconds: 10, timeout_milliseconds: 100)
  sink = Iterator::Cycle.register_telemetry_sink(cycle)

  Read.(stream_name: 'some_stream', batch_size: 1, cycle: cycle) { |event_data| }

  test "Timed out" do
    assert(sink.recorded_timed_out?)
  end
end
