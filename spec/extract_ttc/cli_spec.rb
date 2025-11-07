# frozen_string_literal: true

require "spec_helper"
require "thor"
require "extract_ttc/cli"
require "tmpdir"

RSpec.describe ExtractTtc::Cli do
  let(:fixture_path) { File.join(__dir__, "../../fixtures/Helvetica.ttc") }
  let(:temp_dir) { Dir.mktmpdir }

  after do
    FileUtils.rm_rf(temp_dir) if File.exist?(temp_dir)
  end

  describe "#extract" do
    it "calls ExtractCommand with provided file" do
      command_instance = instance_double(ExtractTtc::ExtractCommand)
      allow(ExtractTtc::ExtractCommand).to receive(:new).and_return(command_instance)
      allow(command_instance).to receive(:run).and_return(0)

      described_class.start(["extract", fixture_path])

      expect(ExtractTtc::ExtractCommand).to have_received(:new)
      expect(command_instance).to have_received(:run).with(fixture_path)
    end

    it "passes output_dir option to ExtractCommand" do
      command_instance = instance_double(ExtractTtc::ExtractCommand)
      allow(ExtractTtc::ExtractCommand).to receive(:new).and_return(command_instance)
      allow(command_instance).to receive(:run).and_return(0)

      described_class.start(["extract", fixture_path, "-o", temp_dir])

      expect(ExtractTtc::ExtractCommand).to have_received(:new).with(
        hash_including("output_dir" => temp_dir)
      )
    end

    it "passes verbose option to ExtractCommand" do
      command_instance = instance_double(ExtractTtc::ExtractCommand)
      allow(ExtractTtc::ExtractCommand).to receive(:new).and_return(command_instance)
      allow(command_instance).to receive(:run).and_return(0)

      described_class.start(["extract", fixture_path, "-v"])

      expect(ExtractTtc::ExtractCommand).to have_received(:new).with(
        hash_including("verbose" => true)
      )
    end

    it "exits with non-zero code when command fails" do
      command_instance = instance_double(ExtractTtc::ExtractCommand)
      allow(ExtractTtc::ExtractCommand).to receive(:new).and_return(command_instance)
      allow(command_instance).to receive(:run).and_return(1)

      expect do
        described_class.start(["extract", "nonexistent.ttc"])
      end.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it "does not exit when command succeeds" do
      command_instance = instance_double(ExtractTtc::ExtractCommand)
      allow(ExtractTtc::ExtractCommand).to receive(:new).and_return(command_instance)
      allow(command_instance).to receive(:run).and_return(0)

      expect do
        described_class.start(["extract", fixture_path])
      end.not_to raise_error
    end
  end

  describe "help" do
    it "displays help for extract command" do
      expect do
        described_class.start(["help", "extract"])
      end.to output(/Extract TTF files from a TTC file/).to_stdout
    end
  end
end