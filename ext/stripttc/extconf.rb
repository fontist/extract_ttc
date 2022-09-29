require "rbconfig"
require "mkmf"
create_makefile "stripttc"

File.write("Makefile",
            File.open("Makefile",&:read).gsub("--no-as-needed","--as-needed"))
