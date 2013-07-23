default['tomcat']['directory'] = '/usr/local/tomcat'
default['tomcat']['version'] = '7.0.40'
default['tomcat']['user'] = {
  'name' => 'tomcat',
  'home' => '/usr/local/tomcat',
  'shell' => '/bin/sh',
  'group' => 'tomcat',
}
default['tomcat']['catalina_opts'] = ''
