CREATE OR REPLACE FUNCTION write_event(
  id uuid,
  type varchar,
  stream varchar,
  data jsonb,
  metadata jsonb DEFAULT NULL,
  expected_version int DEFAULT NULL
)
RETURNS int
AS $$
DECLARE
  stream_version int;
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

  stream_version := stream_version + 1;

  category := category(stream);

  insert into "events"
    (
      "id",
      "type",
      "stream",
      "stream_position",
      "category",
      "data",
      "metadata"
    )
  values
    (
      id,
      type,
      stream,
      stream_version,
      category,
      data,
      metadata
    )
  ;

  return stream_version;
END;
$$ LANGUAGE plpgsql;
