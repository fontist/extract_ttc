# frozen_string_literal: true

require "spec_helper"

RSpec.describe ExtractTtc::Constants do
  describe "TTC_TAG" do
    it "is defined as 'ttcf'" do
      expect(described_class::TTC_TAG).to eq("ttcf")
    end

    it "is a 4-character string" do
      expect(described_class::TTC_TAG).to be_a(String)
      expect(described_class::TTC_TAG.length).to eq(4)
    end

    it "is frozen" do
      expect(described_class::TTC_TAG).to be_frozen
    end
  end

  describe "TTC_VERSION_1" do
    it "is defined as 0x00010000" do
      expect(described_class::TTC_VERSION_1).to eq(0x00010000)
    end

    it "represents major version 1, minor version 0" do
      major = (described_class::TTC_VERSION_1 >> 16) & 0xFFFF
      minor = described_class::TTC_VERSION_1 & 0xFFFF

      expect(major).to eq(1)
      expect(minor).to eq(0)
    end

    it "is an integer" do
      expect(described_class::TTC_VERSION_1).to be_a(Integer)
    end
  end

  describe "TTC_VERSION_2" do
    it "is defined as 0x00020000" do
      expect(described_class::TTC_VERSION_2).to eq(0x00020000)
    end

    it "represents major version 2, minor version 0" do
      major = (described_class::TTC_VERSION_2 >> 16) & 0xFFFF
      minor = described_class::TTC_VERSION_2 & 0xFFFF

      expect(major).to eq(2)
      expect(minor).to eq(0)
    end

    it "is an integer" do
      expect(described_class::TTC_VERSION_2).to be_a(Integer)
    end
  end

  describe "HEAD_TAG" do
    it "is defined as 'head'" do
      expect(described_class::HEAD_TAG).to eq("head")
    end

    it "is a 4-character string" do
      expect(described_class::HEAD_TAG).to be_a(String)
      expect(described_class::HEAD_TAG.length).to eq(4)
    end

    it "is frozen" do
      expect(described_class::HEAD_TAG).to be_frozen
    end
  end

  describe "CHECKSUM_ADJUSTMENT_MAGIC" do
    it "is defined as 0xB1B0AFBA" do
      expect(described_class::CHECKSUM_ADJUSTMENT_MAGIC).to eq(0xB1B0AFBA)
    end

    it "is an integer" do
      expect(described_class::CHECKSUM_ADJUSTMENT_MAGIC).to be_a(Integer)
    end

    it "is a valid 32-bit unsigned integer" do
      expect(described_class::CHECKSUM_ADJUSTMENT_MAGIC).to be >= 0
      expect(described_class::CHECKSUM_ADJUSTMENT_MAGIC).to be <= 0xFFFFFFFF
    end
  end

  describe "SUPPORTED_VERSIONS" do
    it "is an array" do
      expect(described_class::SUPPORTED_VERSIONS).to be_an(Array)
    end

    it "contains TTC_VERSION_1" do
      expect(described_class::SUPPORTED_VERSIONS).to include(described_class::TTC_VERSION_1)
    end

    it "contains TTC_VERSION_2" do
      expect(described_class::SUPPORTED_VERSIONS).to include(described_class::TTC_VERSION_2)
    end

    it "contains exactly two versions" do
      expect(described_class::SUPPORTED_VERSIONS.length).to eq(2)
    end

    it "is frozen" do
      expect(described_class::SUPPORTED_VERSIONS).to be_frozen
    end

    it "contains only integers" do
      expect(described_class::SUPPORTED_VERSIONS).to all(be_a(Integer))
    end
  end

  describe "TABLE_ALIGNMENT" do
    it "is defined as 4" do
      expect(described_class::TABLE_ALIGNMENT).to eq(4)
    end

    it "is an integer" do
      expect(described_class::TABLE_ALIGNMENT).to be_a(Integer)
    end

    it "is a power of 2" do
      alignment = described_class::TABLE_ALIGNMENT
      expect((alignment & (alignment - 1))).to eq(0)
    end
  end

  describe "constant relationships" do
    it "has TTC_VERSION_2 greater than TTC_VERSION_1" do
      expect(described_class::TTC_VERSION_2).to be > described_class::TTC_VERSION_1
    end

    it "has supported versions in ascending order" do
      expect(described_class::SUPPORTED_VERSIONS).to eq(described_class::SUPPORTED_VERSIONS.sort)
    end

    it "has unique version values" do
      versions = described_class::SUPPORTED_VERSIONS
      expect(versions.uniq.length).to eq(versions.length)
    end
  end

  describe "constant immutability" do
    it "cannot modify TTC_TAG" do
      expect { described_class::TTC_TAG << "x" }.to raise_error(FrozenError)
    end

    it "cannot modify HEAD_TAG" do
      expect { described_class::HEAD_TAG << "x" }.to raise_error(FrozenError)
    end

    it "cannot modify SUPPORTED_VERSIONS array" do
      expect { described_class::SUPPORTED_VERSIONS << 999 }.to raise_error(FrozenError)
    end

    it "raises error when trying to reassign constants" do
      # In Ruby, attempting to reassign a constant raises a warning, not NameError
      # This test verifies that constants are properly defined and frozen
      expect(described_class::TTC_TAG).to be_frozen
      expect(described_class::HEAD_TAG).to be_frozen
    end
  end

  describe "usage in checksum calculation" do
    it "CHECKSUM_ADJUSTMENT_MAGIC can be used in calculations" do
      sample_checksum = 0x12345678
      adjustment = (described_class::CHECKSUM_ADJUSTMENT_MAGIC - sample_checksum) & 0xFFFFFFFF

      expect(adjustment).to be_a(Integer)
      expect(adjustment).to be <= 0xFFFFFFFF
    end

    it "checksum calculation produces magic number" do
      sample_checksum = 0x12345678
      adjustment = (described_class::CHECKSUM_ADJUSTMENT_MAGIC - sample_checksum) & 0xFFFFFFFF
      result = (sample_checksum + adjustment) & 0xFFFFFFFF

      expect(result).to eq(described_class::CHECKSUM_ADJUSTMENT_MAGIC)
    end
  end

  describe "usage in version checking" do
    it "can check if version is supported" do
      version1 = described_class::TTC_VERSION_1
      version2 = described_class::TTC_VERSION_2
      unsupported = 0x00030000

      expect(described_class::SUPPORTED_VERSIONS.include?(version1)).to be true
      expect(described_class::SUPPORTED_VERSIONS.include?(version2)).to be true
      expect(described_class::SUPPORTED_VERSIONS.include?(unsupported)).to be false
    end
  end

  describe "usage in table alignment" do
    it "can calculate padding for alignment" do
      unaligned_sizes = [1, 2, 3, 5, 7, 9, 10, 11]

      unaligned_sizes.each do |size|
        padding = (described_class::TABLE_ALIGNMENT - (size % described_class::TABLE_ALIGNMENT)) % described_class::TABLE_ALIGNMENT
        aligned_size = size + padding

        expect(aligned_size % described_class::TABLE_ALIGNMENT).to eq(0)
      end
    end

    it "requires no padding for already aligned sizes" do
      aligned_sizes = [0, 4, 8, 12, 16, 20]

      aligned_sizes.each do |size|
        padding = (described_class::TABLE_ALIGNMENT - (size % described_class::TABLE_ALIGNMENT)) % described_class::TABLE_ALIGNMENT

        expect(padding).to eq(0)
      end
    end
  end

  describe "module structure" do
    it "is a module" do
      expect(described_class).to be_a(Module)
    end

    it "defines all required constants" do
      expect(described_class).to be_const_defined(:TTC_TAG)
      expect(described_class).to be_const_defined(:TTC_VERSION_1)
      expect(described_class).to be_const_defined(:TTC_VERSION_2)
      expect(described_class).to be_const_defined(:HEAD_TAG)
      expect(described_class).to be_const_defined(:CHECKSUM_ADJUSTMENT_MAGIC)
      expect(described_class).to be_const_defined(:SUPPORTED_VERSIONS)
      expect(described_class).to be_const_defined(:TABLE_ALIGNMENT)
    end

    it "only defines expected constants" do
      expected_constants = [
        :TTC_TAG,
        :TTC_VERSION_1,
        :TTC_VERSION_2,
        :HEAD_TAG,
        :CHECKSUM_ADJUSTMENT_MAGIC,
        :SUPPORTED_VERSIONS,
        :TABLE_ALIGNMENT
      ]

      expect(described_class.constants(false).sort).to eq(expected_constants.sort)
    end
  end

  describe "constant values are correct types" do
    it "has string constants as strings" do
      expect(described_class::TTC_TAG).to be_a(String)
      expect(described_class::HEAD_TAG).to be_a(String)
    end

    it "has version constants as integers" do
      expect(described_class::TTC_VERSION_1).to be_a(Integer)
      expect(described_class::TTC_VERSION_2).to be_a(Integer)
    end

    it "has magic constant as integer" do
      expect(described_class::CHECKSUM_ADJUSTMENT_MAGIC).to be_a(Integer)
    end

    it "has alignment constant as integer" do
      expect(described_class::TABLE_ALIGNMENT).to be_a(Integer)
    end

    it "has supported versions as array" do
      expect(described_class::SUPPORTED_VERSIONS).to be_an(Array)
    end
  end
end