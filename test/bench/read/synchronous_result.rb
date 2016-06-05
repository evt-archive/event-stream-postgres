require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Synchronous Result" do
  stream_name = controls::Put.(instances: 2)

  event_data = []

  Read.(stream_name: stream_name, batch_size: 1) do |datum|
    event_data << datum
  end

  test "Reads batches of events" do
    assert(event_data.length == 2)
  end
end
