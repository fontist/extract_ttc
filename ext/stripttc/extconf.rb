require "rbconfig"
require "mkmf"
create_makefile "stripttc"
m = File.read("Makefile").gsub("--no-as-needed", "--as-needed")
File.write("Makefile", m)
