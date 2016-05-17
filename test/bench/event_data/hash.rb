require_relative '../bench_init'

context "EventData Hash" do
  context "Serialize" do
    example = EventStream::Postgres::Controls::EventData::Hash.example
    control_serialized_text = EventStream::Postgres::Controls::EventData::Hash::JSON.text

    serialized_text = Serialize::Write.(example, :json)

    assert(serialized_text == control_serialized_text)
  end
end
