CREATE OR REPLACE FUNCTION write_event(
  stream_name varchar,
  type varchar,
  data jsonb,
  metadata jsonb DEFAULT NULL,
  expected_version int DEFAULT NULL
)
RETURNS int
AS $$
DECLARE
  stream_version int;
  next_version int;
  category varchar;
BEGIN
  stream_version := stream_version(stream);

  if expected_version is not null then
    if expected_version != stream_version then
      raise exception 'Wrong expected version: % (Stream: %, Stream Version: %)', expected_version, stream, stream_version using
        errcode='XPCTV',
        hint='The event cannot be written if the stream version and expected verion do not match';
    end if;
  end if;

  next_version := stream_version + 1;

  category := category(stream_name);

  insert into "events"
    (
      "stream_name",
      "stream_position",
      "type",
      "category",
      "data",
      "metadata"
    )
  values
    (
      stream_name,
      next_version,
      type,
      category,
      data,
      metadata
    )
  ;

  return next_version;
END;
$$ LANGUAGE plpgsql;
