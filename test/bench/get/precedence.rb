require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Get" do
  context "Precedence" do
    stream_name = controls::Put.(instances: 3)

    context "Ascending" do
      events = Get.(stream_name: stream_name, precedence: :asc)

      first_event_postition = events.first.stream_position

      test "First event written is first in the list of results" do
        assert(first_event_postition == 0)
      end
    end

    context "Descending" do
      events = Get.(stream_name: stream_name, precedence: :desc)

      first_event_postition = events.first.stream_position

      test "Last event written is first in the list of results" do
        assert(first_event_postition == 2)
      end
    end
  end
end
