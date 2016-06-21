require_relative '../bench_init'

context "Read" do
  read = Read.build(stream_name: 'some_stream', batch_size: 1, delay_milliseconds: 10, timeout_milliseconds: 100)

  cycle = read.iterator.cycle
  sink = Iterator::Cycle.register_telemetry_sink(cycle)

  read.() { |event_data| }

  test "Timed out" do
    assert(sink.recorded_timed_out?)
  end
end
