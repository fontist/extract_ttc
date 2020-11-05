require_relative "lib/extract_ttc/version"

Gem::Specification.new do |spec|
  spec.name          = "extract_ttc"
  spec.version       = ExtractTtc::VERSION
  spec.authors       = ["Ribose Inc.", "Alexey Morozov"]
  spec.email         = ["operations@ribose.com", "alexey.morozov.is@gmail.com"]

  spec.summary       = "Extract TTC file to TTF files"
  spec.description   = "Extract font collection to separate font files"
  spec.homepage      = "https://github.com/fontist/extract_ttc"
  spec.license       = "BSD-3-Clause"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fontist/extract_ttc"
  spec.metadata["changelog_uri"]   = "https://github.com/fontist/extract_ttc"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`
      .split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ffi"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "0.75.0"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"

  spec.extensions << "ext/stripttc/extconf.rb"
end
