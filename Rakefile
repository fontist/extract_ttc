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

ruby_cc_version = "3.1.0"
bundler_ver = ENV["BUNDLER_VER"] || "2.3.22"

task default: :spec
task spec: :compile

spec = Gem::Specification.load("extract_ttc.gemspec")

ext_thru_rc_dock = %w[
  x86_64-linux
  aarch64-linux
  x64-mingw32
  x64-mingw-ucrt
  x86_64-darwin
  arm64-darwin
]

# TODO automate build with:
# "rbsys/x86_64-linux-musl:latest" - for x86_64-linux-musl
# "*" - find/create image for aarch64-linux-musl
ext_thru_musl_cc = %w[x86_64-linux-musl aarch64-linux-musl]

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
  ext.cross_platform = ext_thru_rc_dock + ext_thru_musl_cc
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

  ext_thru_rc_dock.each do |plat|
    desc "Build native gems with rake-compiler-dock in parallel"
    multitask "parallel" => plat

    desc "Build the native gem for #{plat}"
    task plat => "cache" do
      ruby_cc_ver = if plat == "x64-mingw32"
                      "3.0.0"
                    else
                      ruby_cc_version
                    end

      RakeCompilerDock.sh <<~RCD, platform: plat
        gem install bundler:#{bundler_ver} --no-document &&
        bundle install --local &&
        bundle exec rake native:#{plat} \
          pkg/#{exttask.gem_spec.full_name}-#{plat}.gem \
          RUBY_CC_VERSION=#{ruby_cc_ver}
      RCD
    end
  end

  ext_thru_musl_cc.each do |plat|
    desc "Define the gem task to build on the #{plat} platform (binary gem)"
    task plat do
      s = spec.dup
      s.platform = Gem::Platform.new(plat)
      s.files += Dir.glob("lib/extract_ttc/*.{dll,so,dylib}")
      s.extensions = []

      task = Gem::PackageTask.new(s)
      task.define
    end
  end
end
