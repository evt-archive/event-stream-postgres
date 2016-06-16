require_relative '../test_init'

delay_condition = lambda { |batch| batch.empty? }
cycle = Iterator::Cycle.build(delay_condition: delay_condition)

Read.(stream_name: 'some_stream', batch_size: 1, cycle: cycle) { |event_data| }
