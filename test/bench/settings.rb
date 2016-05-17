require_relative 'bench_init'

context "Settings" do
  settings = EventStream::Postgres::Settings.build

  context "Names" do
    settings_hash = settings.get.to_h

    names = EventStream::Postgres::Settings.names

    names.each do |name|
      test "#{name}" do
        assert(settings_hash.has_key? name)
      end
    end
  end
end
