require "spec_helper"
require "tmpdir"
require "tempfile"

RSpec.describe ExtractTtc do
  describe ".extract" do
    let(:command) { described_class.extract(ttc_path) }
    let(:ttc_path) { fixture_path("Helvetica.ttc") }

    context "given ttc file" do
      it "extracts it to several ttf files" do
        in_tmp_dir do |dir|
          expect(command).to include("Helvetica_01.ttf")
          expect(file_path(dir, "Helvetica_01.ttf")).to exist
        end
      end
    end

    context "given no file" do
      let(:ttc_path) { "missing" }

      it "throws read error" do
        in_tmp_dir do
          expect { command }.to raise_error(ExtractTtc::ReadFileError,
                                            /Could not open/)
        end
      end
    end

    context "given empty file" do
      let(:ttc_path) { Tempfile.new.path }

      it "throws invalid file error" do
        in_tmp_dir do
          expect { command }.to raise_error(ExtractTtc::InvalidFileError,
                                            /does not look like a ttc file/)
        end
      end
    end

    context "given no permission file" do
      let(:ttc_path) { fixture_path("Helvetica.ttc") }
      let(:output_file) { "Helvetica_00.ttf" }

      it "throws write error" do
        in_tmp_dir do
          FileUtils.touch(output_file)
          FileUtils.chmod("a=", output_file)
          expect { command }.to raise_error(ExtractTtc::WriteFileError,
                                            /Failed to open/)
        end
      end
    end

    context "returning unknown code" do
      let(:ttc_path) { "" }
      let(:unknown_code) { -4 }

      it "throws unknown result" do
        allow(ExtractTtc).to receive(:handlefile).and_return(unknown_code)
        expect { command }.to raise_error(ExtractTtc::UnknownResultError)
      end
    end
  end

  def fixture_path(filename)
    File.join(__dir__, "fixtures", filename)
  end

  def in_tmp_dir
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        yield dir
      end
    end
  end

  def file_path(dir, filename)
    Pathname.new(File.join(dir, filename))
  end
end
