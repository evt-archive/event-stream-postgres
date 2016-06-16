require_relative '../test_init'

cycle = Iterator::Cycle.build

Read.(stream_name: 'some_stream', batch_size: 1, cycle: cycle) { |event_data| }
