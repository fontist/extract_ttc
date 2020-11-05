require "bundler/gem_tasks"
task default: :compile

desc "Build stripttc C library"
task :compile do
  print "Building stripttc..."
  Dir.chdir("ext/stripttc") do
    `make`
  end
  puts " done."
end

desc "Recompile the stripttc C library"
task recompile: %i[clean compile]

desc "Remove compiled stripttc library"
task :clean do
  print "Cleaning stripttc..."
  Dir.glob("ext/stripttc/*.{o,so}") do |path|
    File.delete(path)
  end
  puts " done."
end
