require "bundler/gem_tasks"
require "rake/clean"
require "rake/extensiontask"
require "rake_compiler_dock"

require "rubygems"
require "rubygems/package_task"

# ++ Allow rake-compiler-dock configuration without dev. dependencies
begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
end

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end
# -- Allow rake-compiler-dock configuration without dev. dependencies

R_CC_V = "RUBY_CC_VERSION=3.1.0:3.0.0:2.7.0".freeze
bundler_ver = ENV["BUNDLER_VER"] || "2.3.22"

task default: :spec
task spec: :compile

spec = Gem::Specification.load("extract_ttc.gemspec")

ext_thru_rc_dock = %w[x86_64-linux aarch64-linux] +
  %w[x64-mingw32 x64-mingw-ucrt x86_64-darwin arm64-darwin]

ext_thru_qu_dock = %w[x86_64-linux-musl aarch64-linux-musl]

# add your default gem packing task
Gem::PackageTask.new(spec) do |pkg|
end

# HACK: Prevent rake-compiler from overriding required_ruby_version,
# because the shared library here is Ruby-agnostic.
# See https://github.com/rake-compiler/rake-compiler/issues/153
module FixRequiredRubyVersion
  def required_ruby_version=(*); end
end
Gem::Specification.prepend(FixRequiredRubyVersion)

exttask = Rake::ExtensionTask.new("stripttc", spec) do |ext|
  ext.lib_dir = "lib"
  ext.cross_compile = true
  ext.cross_platform = ext_thru_rc_dock + ext_thru_qu_dock
  ext.cross_compiling do |s|
    s.files.reject! { |path| File.fnmatch?("ext/*", path) }
  end
end

namespace "gem" do
  desc "Cache dependencies"
  task "cache" do
    sh <<~RCD
      bundle config set cache_all true &&
      bundle config set --local without 'development' &&
      bundle package
    RCD
  end

  desc "build native gems"
  task "native" => "cache" do
    ext_thru_rc_dock.each do |plat|
      RakeCompilerDock.sh <<~RCD, platform: plat
        gem install bundler:#{bundler_ver} --no-document &&
        bundle install --local &&
        bundle exec rake native:#{plat} gem #{R_CC_V}
      RCD
    end
  end
end

namespace "gem" do
  ext_thru_rc_dock.each do |plat|
    desc "Build all native binary gems in parallel"
    multitask "parallel" => plat

    desc "Build the native gem for #{plat}"
    task plat => "cache" do
      RakeCompilerDock.sh <<~RCD, platform: plat
        gem install bundler:#{bundler_ver} --no-document &&
        bundle install --local &&
        bundle exec rake native:#{plat} \
          pkg/#{exttask.gem_spec.full_name}-#{plat}.gem \
          #{R_CC_V}
      RCD
    end
  end
end
