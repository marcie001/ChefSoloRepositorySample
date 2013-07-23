default['postgresql']['local_authentication'] = 'trust'

default['postgresql']['listen_addresses'] = 'localhost'
default['postgresql']['port'] = '5432'
default['postgresql']['shared_buffers'] = '256MB'
default['postgresql']['wal_buffers'] = '-1'
default['postgresql']['checkpoint_segments'] = '16'

default['postgresql']['users'] = {}
default['postgresql']['tablespaces'] = {}
default['postgresql']['databases'] = {}
