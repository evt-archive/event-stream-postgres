require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Read" do
  stream_name = controls::Put.(instances: 2)

  events = Read.(stream_name: stream_name, batch_size: 1)

  test "Reads batches of events" do
    assert(events.length == 2)
  end
end
