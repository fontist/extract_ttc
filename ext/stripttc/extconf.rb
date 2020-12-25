require "mkmf"
require "rbconfig"

CONFIG["LDSHARED"] << " -shared" unless RbConfig::CONFIG["host_os"].match?(/darwin/)

create_makefile "stripttc"
