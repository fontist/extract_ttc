require 'mkmf'
require 'rbconfig'

if RbConfig::CONFIG['host_os'] !~ /darwin|mac os/
  CONFIG['LDSHARED'] << " -shared"
end

create_makefile 'stripttc'
