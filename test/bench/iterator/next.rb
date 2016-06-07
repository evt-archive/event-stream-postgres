require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Iterator" do
  stream_name = controls::Put.(instances: 2)

  iterator = Iterator.build(stream_name: stream_name)

  event_data_1 = iterator.next
  event_data_2 = iterator.next

  test "Gets individual events" do
    assert(event_data_2.stream_position == event_data_1.stream_position + 1)
  end
end
