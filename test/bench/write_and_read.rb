require_relative 'bench_init'

# "id" uuid DEFAULT gen_random_uuid() NOT NULL,
# "type" varchar NOT NULL COLLATE "default",
# "stream" varchar NOT NULL COLLATE "default",
# "stream_position" int4 NOT NULL,
# "category" varchar NOT NULL COLLATE "default",
# "global_position" bigserial NOT NULL ,
# "data" jsonb NOT NULL,
# "metadata" jsonb,
# "created_time" TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'utc') NOT NULL


# attribute :number
# attribute :position
# attribute :stream_name
# attribute :created_time
# attribute :links
# attribute :type
# attribute :data
# attribute :metadata


context "Write and Read an Event" do
  test do
    event = Controls::EventData::Write.example
    stream_version = Write.(event)
  end
end
