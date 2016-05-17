require_relative 'bench_init'

context "Session" do
  session = EventStream::Postgres::Session.build

  test "Connected" do
    connected_session = EventStream::Postgres::Session.build
    connected = connected_session.connected?

    assert(connected)
  end

  context "Settings" do
    settings = EventStream::Postgres::Settings.build
    settings_hash = settings.get.to_h

    names = EventStream::Postgres::Settings.names

    names.each do |name|
      test "#{name}" do
        session_val = session.public_send name
        settings_val = settings_hash[name]

        assert(session_val == settings_val)
      end
    end
  end
end
