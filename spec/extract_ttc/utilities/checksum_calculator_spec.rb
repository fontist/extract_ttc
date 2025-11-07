# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe ExtractTtc::Utilities::ChecksumCalculator do
  describe ".calculate_file_checksum" do
    context "with valid files" do
      it "calculates checksum for file with multiple of 4 bytes" do
        Tempfile.create(["test", ".bin"]) do |file|
          # Write exactly 8 bytes (2 uint32 values)
          file.write([0x12345678, 0x9ABCDEF0].pack("N*"))
          file.flush

          checksum = described_class.calculate_file_checksum(file.path)

          # Sum should be (0x12345678 + 0x9ABCDEF0) & 0xFFFFFFFF
          expected = (0x12345678 + 0x9ABCDEF0) & 0xFFFFFFFF
          expect(checksum).to eq(expected)
        end
      end

      it "calculates checksum for file with padding needed" do
        Tempfile.create(["test", ".bin"]) do |file|
          # Write 5 bytes (needs 3 bytes padding to reach 8 bytes)
          file.write("\x12\x34\x56\x78\x9A")
          file.flush

          checksum = described_class.calculate_file_checksum(file.path)

          # First uint32: 0x12345678
          # Second uint32: 0x9A000000 (padded with zeros)
          expected = (0x12345678 + 0x9A000000) & 0xFFFFFFFF
          expect(checksum).to eq(expected)
        end
      end

      it "calculates checksum for empty file" do
        Tempfile.create(["test", ".bin"]) do |file|
          file.flush

          checksum = described_class.calculate_file_checksum(file.path)

          expect(checksum).to eq(0)
        end
      end

      it "calculates checksum for single byte file" do
        Tempfile.create(["test", ".bin"]) do |file|
          file.write("\xFF")
          file.flush

          checksum = described_class.calculate_file_checksum(file.path)

          # Single byte 0xFF becomes uint32 0xFF000000
          expect(checksum).to eq(0xFF000000)
        end
      end

      it "calculates checksum for 4-byte file" do
        Tempfile.create(["test", ".bin"]) do |file|
          file.write([0xDEADBEEF].pack("N"))
          file.flush

          checksum = described_class.calculate_file_checksum(file.path)

          expect(checksum).to eq(0xDEADBEEF)
        end
      end

      it "masks result to 32 bits on overflow" do
        Tempfile.create(["test", ".bin"]) do |file|
          # Write values that will overflow 32 bits when summed
          file.write([0xFFFFFFFF, 0xFFFFFFFF].pack("N*"))
          file.flush

          checksum = described_class.calculate_file_checksum(file.path)

          # (0xFFFFFFFF + 0xFFFFFFFF) & 0xFFFFFFFF = 0xFFFFFFFE
          expect(checksum).to eq(0xFFFFFFFE)
        end
      end

      it "calculates checksum for real TTC fixture" do
        fixture_path = File.join(__dir__, "../../fixtures/Helvetica.ttc")
        if File.exist?(fixture_path)
          checksum = described_class.calculate_file_checksum(fixture_path)

          # Checksum should be a valid 32-bit unsigned integer
          expect(checksum).to be_a(Integer)
          expect(checksum).to be >= 0
          expect(checksum).to be <= 0xFFFFFFFF
        end
      end
    end

    context "with invalid files" do
      it "raises error for non-existent file" do
        expect { described_class.calculate_file_checksum("nonexistent.ttc") }
          .to raise_error(Errno::ENOENT)
      end
    end
  end

  describe ".calculate_adjustment" do
    it "calculates correct adjustment value" do
      file_checksum = 0x12345678
      adjustment = described_class.calculate_adjustment(file_checksum)

      # CHECKSUM_ADJUSTMENT_MAGIC - file_checksum, masked to 32 bits
      expected = (ExtractTtc::Constants::CHECKSUM_ADJUSTMENT_MAGIC - file_checksum) & 0xFFFFFFFF
      expect(adjustment).to eq(expected)
    end

    it "handles zero checksum" do
      adjustment = described_class.calculate_adjustment(0)

      expect(adjustment).to eq(ExtractTtc::Constants::CHECKSUM_ADJUSTMENT_MAGIC)
    end

    it "handles maximum checksum value" do
      adjustment = described_class.calculate_adjustment(0xFFFFFFFF)

      expected = (ExtractTtc::Constants::CHECKSUM_ADJUSTMENT_MAGIC - 0xFFFFFFFF) & 0xFFFFFFFF
      expect(adjustment).to eq(expected)
    end

    it "handles checksum equal to magic number" do
      adjustment = described_class.calculate_adjustment(ExtractTtc::Constants::CHECKSUM_ADJUSTMENT_MAGIC)

      expect(adjustment).to eq(0)
    end

    it "masks result to 32 bits" do
      # If file_checksum is greater than magic, result should wrap around
      file_checksum = ExtractTtc::Constants::CHECKSUM_ADJUSTMENT_MAGIC + 1
      adjustment = described_class.calculate_adjustment(file_checksum)

      expected = (ExtractTtc::Constants::CHECKSUM_ADJUSTMENT_MAGIC - file_checksum) & 0xFFFFFFFF
      expect(adjustment).to eq(expected)
      expect(adjustment).to be <= 0xFFFFFFFF
    end

    it "returns consistent results for same input" do
      file_checksum = 0x9ABCDEF0
      adjustment1 = described_class.calculate_adjustment(file_checksum)
      adjustment2 = described_class.calculate_adjustment(file_checksum)

      expect(adjustment1).to eq(adjustment2)
    end
  end

  describe "checksum round-trip" do
    it "verifies that file checksum + adjustment equals magic number (with wrapping)" do
      Tempfile.create(["test", ".ttf"]) do |file|
        # Write some test data
        file.write([0x11111111, 0x22222222, 0x33333333].pack("N*"))
        file.flush

        file_checksum = described_class.calculate_file_checksum(file.path)
        adjustment = described_class.calculate_adjustment(file_checksum)

        # The sum should equal the magic number (modulo 2^32)
        sum = (file_checksum + adjustment) & 0xFFFFFFFF
        expect(sum).to eq(ExtractTtc::Constants::CHECKSUM_ADJUSTMENT_MAGIC)
      end
    end
  end
end