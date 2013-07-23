default['nginx']['worker_processes'] = 1
default['nginx']['worker_connections'] = 1024
default['nginx']['keepalive_timeout'] = 0
default['nginx']['servers'] = {
  'default' => {
    'server_name' => 'localhost',
    'ssl' => false,
    'locations' => {
      '/' => {
        'root' => '/usr/share/nginx/html',
        'index' => ['index.html', 'index.htm'],
      }
    }
  }
}
