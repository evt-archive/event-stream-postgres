require_relative 'test_init'

TestBench::Runner.(
  'bench/**/*.rb',
  exclude_pattern: %r{/^skip_|(?:_init\.rb|\.sketch\.rb|_sketch\.rb|sketch\.rb|\.skip\.rb)\z}
) or exit 1


ENV['LOGGER'] = 'on'
ENV['LOG_LEVEL'] = 'warn'
logger = Telemetry::Logger.get self

logger.warn 'TODO: Implement no stream tests'
