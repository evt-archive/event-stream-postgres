require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Read Synchronously" do
  res = Read.(stream_name: 'some_stream_name')

  test "Returns a result that fails when invoked" do
    assert(res == AsyncInvocation::Incorrect)
  end
end
