CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

SELECT write_event(gen_random_uuid(), 'SomeType', 'someStream-123', '{"someField":"some value"}', '{"someMetadataField":"some metadata value"}');
