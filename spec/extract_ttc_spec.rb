require "spec_helper"
require "pathname"
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

    context "backward compatibility" do
      it "returns relative filenames for current directory extraction" do
        in_tmp_dir do |dir|
          filenames = described_class.extract(ttc_path)

          # Should return just filenames, not full paths
          expect(filenames.first).to eq("Helvetica_00.ttf")
          expect(filenames.first).not_to include(File::SEPARATOR)

          # User can join with their own directory
          full_paths = filenames.map { |filename| File.join(dir, filename) }
          expect(full_paths.first).to include(dir)
          expect(File.exist?(full_paths.first)).to be true
        end
      end

      it "returns full paths when output_dir is specified" do
        Dir.mktmpdir do |tmp_dir|
          output_dir = File.join(tmp_dir, "output")
          filenames = described_class.extract(ttc_path, output_dir: output_dir)

          # Should return full paths when output_dir is specified
          expect(filenames.first).to include(output_dir)
          expect(filenames.first).to include(File::SEPARATOR)
          expect(File.exist?(filenames.first)).to be true
        end
      end
    end

    context "backward compatibility" do
      it "returns relative filenames for current directory extraction" do
        in_tmp_dir do |dir|
          filenames = described_class.extract(ttc_path)

          # Should return just filenames, not full paths
          expect(filenames.first).to eq("Helvetica_00.ttf")
          expect(filenames.first).not_to include(File::SEPARATOR)

          # User can join with their own directory
          full_paths = filenames.map { |filename| File.join(dir, filename) }
          expect(full_paths.first).to include(dir)
          expect(File.exist?(full_paths.first)).to be true
        end
      end

      it "returns full paths when output_dir is specified" do
        Dir.mktmpdir do |tmp_dir|
          output_dir = File.join(tmp_dir, "output")
          filenames = described_class.extract(ttc_path, output_dir: output_dir)

          # Should return full paths when output_dir is specified
          expect(filenames.first).to include(output_dir)
          expect(filenames.first).to include(File::SEPARATOR)
          expect(File.exist?(filenames.first)).to be true
        end
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
