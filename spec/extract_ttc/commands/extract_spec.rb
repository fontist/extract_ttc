# frozen_string_literal: true

require "spec_helper"
require "extract_ttc/commands/extract"
require "tmpdir"

RSpec.describe ExtractTtc::ExtractCommand do
  let(:fixture_path) { File.join(__dir__, "../../fixtures/Helvetica.ttc") }
  let(:temp_dir) { Dir.mktmpdir }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe "#run" do
    context "with a valid TTC file" do
      it "returns exit code 0 on success" do
        command = described_class.new({})
        exit_code = command.run(fixture_path)

        expect(exit_code).to eq(0)
      end

      it "extracts fonts to default directory" do
        command = described_class.new({})
        command.run(fixture_path)

        expect(Dir.glob("Helvetica_*.ttf")).not_to be_empty
      ensure
        Dir.glob("Helvetica_*.ttf").each { |f| File.delete(f) }
      end

      it "extracts fonts to specified output directory" do
        command = described_class.new(output_dir: temp_dir)
        command.run(fixture_path)

        expect(Dir.glob(File.join(temp_dir, "Helvetica_*.ttf"))).not_to be_empty
      end
    end

    context "when file does not exist" do
      it "returns exit code 1 for missing file" do
        command = described_class.new({})
        exit_code = command.run("nonexistent.ttc")

        expect(exit_code).to eq(1)
      end
    end

    context "when file is not a valid TTC" do
      let(:invalid_file) { File.join(temp_dir, "invalid.ttc") }

      before do
        File.write(invalid_file, "not a valid TTC file")
      end

      it "returns exit code 2 for invalid file" do
        command = described_class.new({})
        exit_code = command.run(invalid_file)

        expect(exit_code).to eq(2)
      end
    end

    context "with verbose option" do
      it "accepts verbose option" do
        command = described_class.new(verbose: true)
        exit_code = command.run(fixture_path)

        expect(exit_code).to eq(0)
      ensure
        Dir.glob("Helvetica_*.ttf").each { |f| File.delete(f) }
      end
    end
  end

  describe "#initialize" do
    it "stores options" do
      options = { output_dir: temp_dir, verbose: true }
      command = described_class.new(options)

      expect(command.instance_variable_get(:@options)).to eq(options)
    end

    it "sets verbose to false by default" do
      command = described_class.new({})

      expect(command.instance_variable_get(:@verbose)).to eq(false)
    end

    it "sets verbose to true when option is provided" do
      command = described_class.new(verbose: true)

      expect(command.instance_variable_get(:@verbose)).to eq(true)
    end
  end
end
