default['iptables-setting']['rules'] = [
  '-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT',
]
