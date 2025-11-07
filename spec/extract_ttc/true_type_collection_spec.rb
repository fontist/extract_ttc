# frozen_string_literal: true

require "spec_helper"

RSpec.describe ExtractTtc::TrueTypeCollection do
  let(:fixture_path) { File.join(__dir__, "../fixtures/Helvetica.ttc") }

  describe ".from_file" do
    context "with valid TTC file" do
      it "reads a TTC file successfully" do
        skip "Fixture not available" unless File.exist?(fixture_path)

        ttc = described_class.from_file(fixture_path)

        expect(ttc).to be_a(ExtractTtc::TrueTypeCollection)
        expect(ttc.tag).to eq("ttcf")
        expect(ttc.num_fonts).to be > 0
      end

      it "reads font offsets correctly" do
        skip "Fixture not available" unless File.exist?(fixture_path)

        ttc = described_class.from_file(fixture_path)

        expect(ttc.font_offsets.length).to eq(ttc.num_fonts)
        expect(ttc.font_offsets.all? { |o| o > 0 }).to be true
      end

      it "reads version information" do
        skip "Fixture not available" unless File.exist?(fixture_path)

        ttc = described_class.from_file(fixture_path)

        expect(ttc.major_version).to be >= 0
        expect(ttc.minor_version).to be >= 0
        expect(ttc.version).to be >= 0
      end
    end

    context "with invalid parameters" do
      it "raises ArgumentError for nil path" do
        expect { described_class.from_file(nil) }
          .to raise_error(ArgumentError, /path cannot be nil or empty/)
      end

      it "raises ArgumentError for empty path" do
        expect { described_class.from_file("") }
          .to raise_error(ArgumentError, /path cannot be nil or empty/)
      end

      it "raises Errno::ENOENT for non-existent file" do
        expect { described_class.from_file("nonexistent.ttc") }
          .to raise_error(Errno::ENOENT, /File not found/)
      end
    end

    context "with invalid file format" do
      it "raises RuntimeError for non-TTC file" do
        Tempfile.create(["invalid", ".ttc"]) do |file|
          file.write("INVALID_DATA")
          file.flush

          expect { described_class.from_file(file.path) }
            .to raise_error(RuntimeError, /Invalid TTC file/)
        end
      end

      it "raises RuntimeError for truncated file" do
        Tempfile.create(["truncated", ".ttc"]) do |file|
          # Write only partial header
          file.write("ttcf")
          file.flush

          expect { described_class.from_file(file.path) }
            .to raise_error(RuntimeError, /Invalid TTC file/)
        end
      end
    end
  end

  describe "#extract_fonts" do
    context "with valid TTC file" do
      it "extracts all fonts from TTC" do
        skip "Fixture not available" unless File.exist?(fixture_path)

        File.open(fixture_path, "rb") do |io|
          ttc = described_class.read(io)
          fonts = ttc.extract_fonts(io)

          expect(fonts).to be_an(Array)
          expect(fonts.length).to eq(ttc.num_fonts)
          expect(fonts).to all(be_a(ExtractTtc::TrueTypeFont))
        end
      end

      it "extracts fonts with valid table data" do
        skip "Fixture not available" unless File.exist?(fixture_path)

        File.open(fixture_path, "rb") do |io|
          ttc = described_class.read(io)
          fonts = ttc.extract_fonts(io)

          fonts.each do |font|
            expect(font.header).not_to be_nil
            expect(font.tables.length).to be > 0
            expect(font.tables.length).to be > 0
            expect(font.table_data).to be_a(Hash)
            expect(font.table_data.keys.length).to eq(font.tables.length)
          end
        end
      end
    end
  end

  describe "#valid?" do
    context "with valid TTC structure" do
      it "returns true for valid TTC from file" do
        skip "Fixture not available" unless File.exist?(fixture_path)

        ttc = described_class.from_file(fixture_path)
        expect(ttc.valid?).to be true
      end

      it "returns true when tag is 'ttcf'" do
        skip "Fixture not available" unless File.exist?(fixture_path)

        ttc = described_class.from_file(fixture_path)
        expect(ttc.tag).to eq(ExtractTtc::Constants::TTC_TAG)
        expect(ttc.valid?).to be true
      end

      it "returns true when num_fonts matches font_offsets length" do
        skip "Fixture not available" unless File.exist?(fixture_path)

        ttc = described_class.from_file(fixture_path)
        expect(ttc.font_offsets.length).to eq(ttc.num_fonts)
        expect(ttc.valid?).to be true
      end
    end

    context "with invalid TTC structure" do
      it "returns false when tag is incorrect" do
        Tempfile.create(["invalid_tag", ".ttc"]) do |file|
          # Write incorrect tag
          file.write("OTTO")
          file.write([1, 0, 1].pack("n2N"))
          file.write([100].pack("N")) # offset
          file.flush

          File.open(file.path, "rb") do |io|
            # BinData raises ValidityError due to assert, so we catch it
            expect { described_class.read(io) }.to raise_error(BinData::ValidityError)
          end
        end
      end

      it "returns false when num_fonts is zero" do
        Tempfile.create(["zero_fonts", ".ttc"]) do |file|
          file.write("ttcf")
          file.write([1, 0, 0].pack("n2N")) # num_fonts = 0
          file.flush

          File.open(file.path, "rb") do |io|
            ttc = described_class.read(io)
            expect(ttc.valid?).to be false
          end
        end
      end
    end
  end

  describe "#version" do
    it "combines major and minor version correctly" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expected_version = (ttc.major_version << 16) | ttc.minor_version

      expect(ttc.version).to eq(expected_version)
    end

    it "returns version 1.0 as 0x00010000" do
      Tempfile.create(["version1", ".ttc"]) do |file|
        file.write("ttcf")
        file.write([1, 0].pack("n2")) # version 1.0
        file.write([1].pack("N")) # num_fonts
        file.write([100].pack("N")) # font offset
        file.flush

        ttc = described_class.from_file(file.path)
        expect(ttc.version).to eq(ExtractTtc::Constants::TTC_VERSION_1)
      end
    end

    it "returns version 2.0 as 0x00020000" do
      Tempfile.create(["version2", ".ttc"]) do |file|
        file.write("ttcf")
        file.write([2, 0].pack("n2")) # version 2.0
        file.write([1].pack("N")) # num_fonts
        file.write([100].pack("N")) # font offset
        file.flush

        ttc = described_class.from_file(file.path)
        expect(ttc.version).to eq(ExtractTtc::Constants::TTC_VERSION_2)
      end
    end
  end

  describe "BinData structure" do
    it "reads tag as 4-character string" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expect(ttc.tag.length).to eq(4)
    end

    it "reads version fields correctly" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expect(ttc.major_version).to be >= 0
      expect(ttc.minor_version).to be >= 0
    end

    it "reads num_fonts correctly" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expect(ttc.num_fonts).to be >= 0
    end

    it "reads font_offsets as array" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expect(ttc.font_offsets.length).to eq(ttc.num_fonts)
      expect(ttc.font_offsets.all? { |o| o.respond_to?(:to_i) }).to be true
    end
  end

  describe "round-trip" do
    it "reads and writes TTC structure correctly" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      original_data = File.binread(fixture_path, 1024)

      File.open(fixture_path, "rb") do |io|
        ttc = described_class.read(io)

        Tempfile.create(["roundtrip", ".ttc"]) do |temp|
          File.open(temp.path, "wb") do |out_io|
            ttc.write(out_io)
          end

          roundtrip_data = File.binread(temp.path, 1024)

          # Header should match
          expect(roundtrip_data[0, 16]).to eq(original_data[0, 16])
        end
      end
    end
  end

  describe "attribute access" do
    it "provides read access to tag" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expect(ttc.tag.to_s).to be_a(String)
      expect(ttc.tag.length).to eq(4)
    end

    it "provides read access to major_version" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expect(ttc.major_version).to be >= 0
    end

    it "provides read access to minor_version" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expect(ttc.minor_version).to be >= 0
    end

    it "provides read access to num_fonts" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expect(ttc.num_fonts).to be >= 0
    end

    it "provides read access to font_offsets" do
      skip "Fixture not available" unless File.exist?(fixture_path)

      ttc = described_class.from_file(fixture_path)
      expect(ttc.font_offsets.length).to be > 0
    end
  end
end