require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Get" do
  context "No Events" do
    stream_name = controls::StreamName.example

    events = Get.(stream_name: stream_name)

    test "Results in nil" do
      assert(events.nil?)
    end
  end
end
