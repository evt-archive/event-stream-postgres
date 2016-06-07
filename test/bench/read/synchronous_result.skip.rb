require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Read" do
  context "Synchronous Result" do
    res = Read.(stream_name: 'some_stream_name') { }

    test "Returns a result that fails if actuated" do
      assert(res == AsyncInvocation::Incorrect)
    end
  end
end
