# frozen_string_literal: true

require "spec_helper"

RSpec.describe ExtractTtc::Configuration do
  describe "#initialize" do
    context "with default parameters" do
      it "creates a configuration with default values" do
        config = described_class.new

        expect(config.output_directory).to eq(".")
        expect(config.overwrite_existing).to be false
        expect(config.validate_checksums).to be true
        expect(config.verbose).to be false
      end
    end

    context "with custom parameters" do
      it "creates a configuration with custom output_directory" do
        config = described_class.new(output_directory: "/tmp/fonts")

        expect(config.output_directory).to eq("/tmp/fonts")
      end

      it "creates a configuration with custom overwrite_existing" do
        config = described_class.new(overwrite_existing: true)

        expect(config.overwrite_existing).to be true
      end

      it "creates a configuration with custom validate_checksums" do
        config = described_class.new(validate_checksums: false)

        expect(config.validate_checksums).to be false
      end

      it "creates a configuration with custom verbose" do
        config = described_class.new(verbose: true)

        expect(config.verbose).to be true
      end

      it "creates a configuration with all custom values" do
        config = described_class.new(
          output_directory: "/custom/path",
          overwrite_existing: true,
          validate_checksums: false,
          verbose: true,
        )

        expect(config.output_directory).to eq("/custom/path")
        expect(config.overwrite_existing).to be true
        expect(config.validate_checksums).to be false
        expect(config.verbose).to be true
      end
    end
  end

  describe ".default" do
    it "creates a configuration with default values" do
      config = described_class.default

      expect(config).to be_a(ExtractTtc::Configuration)
      expect(config.output_directory).to eq(".")
      expect(config.overwrite_existing).to be false
      expect(config.validate_checksums).to be true
      expect(config.verbose).to be false
    end

    it "returns a new instance each time" do
      config1 = described_class.default
      config2 = described_class.default

      expect(config1).not_to be(config2)
    end
  end

  describe "#merge" do
    let(:original_config) do
      described_class.new(
        output_directory: "/original",
        overwrite_existing: false,
        validate_checksums: true,
        verbose: false,
      )
    end

    it "returns a new Configuration instance" do
      new_config = original_config.merge(verbose: true)

      expect(new_config).to be_a(ExtractTtc::Configuration)
      expect(new_config).not_to be(original_config)
    end

    it "merges single option" do
      new_config = original_config.merge(verbose: true)

      expect(new_config.verbose).to be true
      expect(new_config.output_directory).to eq("/original")
      expect(new_config.overwrite_existing).to be false
      expect(new_config.validate_checksums).to be true
    end

    it "merges multiple options" do
      new_config = original_config.merge(
        output_directory: "/new",
        verbose: true,
      )

      expect(new_config.output_directory).to eq("/new")
      expect(new_config.verbose).to be true
      expect(new_config.overwrite_existing).to be false
      expect(new_config.validate_checksums).to be true
    end

    it "merges all options" do
      new_config = original_config.merge(
        output_directory: "/all_new",
        overwrite_existing: true,
        validate_checksums: false,
        verbose: true,
      )

      expect(new_config.output_directory).to eq("/all_new")
      expect(new_config.overwrite_existing).to be true
      expect(new_config.validate_checksums).to be false
      expect(new_config.verbose).to be true
    end

    it "does not modify the original configuration" do
      original_config.merge(
        output_directory: "/new",
        overwrite_existing: true,
        validate_checksums: false,
        verbose: true,
      )

      expect(original_config.output_directory).to eq("/original")
      expect(original_config.overwrite_existing).to be false
      expect(original_config.validate_checksums).to be true
      expect(original_config.verbose).to be false
    end

    it "returns same values when merging with empty hash" do
      new_config = original_config.merge({})

      expect(new_config.output_directory).to eq(original_config.output_directory)
      expect(new_config.overwrite_existing).to eq(original_config.overwrite_existing)
      expect(new_config.validate_checksums).to eq(original_config.validate_checksums)
      expect(new_config.verbose).to eq(original_config.verbose)
    end

    it "can be chained" do
      config = described_class.default
        .merge(output_directory: "/step1")
        .merge(verbose: true)
        .merge(overwrite_existing: true)

      expect(config.output_directory).to eq("/step1")
      expect(config.verbose).to be true
      expect(config.overwrite_existing).to be true
    end
  end

  describe "#to_h" do
    it "returns a hash representation of the configuration" do
      config = described_class.new(
        output_directory: "/test",
        overwrite_existing: true,
        validate_checksums: false,
        verbose: true,
      )

      hash = config.to_h

      expect(hash).to eq(
        output_directory: "/test",
        overwrite_existing: true,
        validate_checksums: false,
        verbose: true,
      )
    end

    it "returns a hash with default values" do
      config = described_class.default

      hash = config.to_h

      expect(hash).to eq(
        output_directory: ".",
        overwrite_existing: false,
        validate_checksums: true,
        verbose: false,
      )
    end

    it "returns a new hash each time" do
      config = described_class.default

      hash1 = config.to_h
      hash2 = config.to_h

      expect(hash1).not_to be(hash2)
      expect(hash1).to eq(hash2)
    end

    it "returned hash contains symbol keys" do
      config = described_class.default
      hash = config.to_h

      expect(hash.keys).to all(be_a(Symbol))
    end
  end

  describe "attribute accessors" do
    let(:config) { described_class.new }

    it "allows reading output_directory" do
      expect(config.output_directory).to eq(".")
    end

    it "allows writing output_directory" do
      config.output_directory = "/new/path"
      expect(config.output_directory).to eq("/new/path")
    end

    it "allows reading overwrite_existing" do
      expect(config.overwrite_existing).to be false
    end

    it "allows writing overwrite_existing" do
      config.overwrite_existing = true
      expect(config.overwrite_existing).to be true
    end

    it "allows reading validate_checksums" do
      expect(config.validate_checksums).to be true
    end

    it "allows writing validate_checksums" do
      config.validate_checksums = false
      expect(config.validate_checksums).to be false
    end

    it "allows reading verbose" do
      expect(config.verbose).to be false
    end

    it "allows writing verbose" do
      config.verbose = true
      expect(config.verbose).to be true
    end
  end

  describe "usage scenarios" do
    it "supports creating default and customizing" do
      config = described_class.default.merge(
        output_directory: "/output",
        verbose: true,
      )

      expect(config.output_directory).to eq("/output")
      expect(config.verbose).to be true
      expect(config.overwrite_existing).to be false
      expect(config.validate_checksums).to be true
    end

    it "supports building configuration step by step" do
      config = described_class.new
      config.output_directory = "/fonts"
      config.verbose = true

      expect(config.output_directory).to eq("/fonts")
      expect(config.verbose).to be true
    end

    it "supports converting to hash for inspection" do
      config = described_class.new(verbose: true)
      hash = config.to_h

      expect(hash).to include(verbose: true)
      expect(hash[:output_directory]).to eq(".")
    end
  end
end
