require_relative "lib/extract_ttc/version"

Gem::Specification.new do |spec|
  spec.name          = "extract_ttc"
  spec.version       = ExtractTtc::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["operations@ribose.com"]

  spec.summary       = "Extract TTC file to TTF files"
  spec.description   = "Extract font collection to separate font files"
  spec.homepage      = "https://github.com/fontist/extract_ttc"
  spec.license       = "BSD-3-Clause"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fontist/extract_ttc"
  spec.metadata["changelog_uri"]   = "https://github.com/fontist/extract_ttc"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`
      .split("\x0").reject { |f| f.match(%r{^(.github|test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ffi", "~> 1.0"
  spec.add_runtime_dependency "bundler", "~> 2.0"
  spec.add_runtime_dependency "rake", "~> 13"
  spec.add_runtime_dependency "rake-compiler", "~> 1.2"
  spec.add_runtime_dependency "rake-compiler-dock", "~> 1.2"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.5"
  spec.add_development_dependency "rubocop-performance", "~> 1.10"
  spec.add_development_dependency "rubocop-rails", "~> 2.9"

  spec.extensions << "ext/stripttc/extconf.rb"
  spec.metadata["rubygems_mfa_required"] = "false"
end
