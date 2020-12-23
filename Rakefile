require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/clean"
require "rake/extensiontask"

require "rubygems"
require "rubygems/package_task"

RSpec::Core::RakeTask.new(:rspec)

task default: :rspec

spec = Gem::Specification.load("extract_ttc.gemspec")

# add your default gem packing task
Gem::PackageTask.new(spec) do |pkg|
end

Rake::ExtensionTask.new("stripttc", spec) do |ext|
  ext.lib_dir = 'lib'
  ext.cross_compile = true
  ext.cross_platform = %w[x86-mingw32 x64-mingw32 x86-linux x86_64-linux]
  ext.cross_compiling do |spec|
    spec.files.reject! { |path| File.fnmatch?('ext/*', path) }
  end
end