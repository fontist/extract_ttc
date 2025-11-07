# frozen_string_literal: true

require "spec_helper"

RSpec.describe ExtractTtc::Models::ValidationResult do
  describe "#initialize" do
    context "with default parameters" do
      it "creates a valid result with no errors" do
        result = described_class.new

        expect(result.valid).to be true
        expect(result.errors).to eq([])
      end
    end

    context "with valid validation" do
      it "creates a result with valid status" do
        result = described_class.new(valid: true, errors: [])

        expect(result.valid).to be true
        expect(result.errors).to be_empty
      end
    end

    context "with failed validation" do
      it "creates a result with errors" do
        errors = ["File not found", "Invalid format"]
        result = described_class.new(
          valid: false,
          errors: errors
        )

        expect(result.valid).to be false
        expect(result.errors).to eq(errors)
      end

      it "accepts single error" do
        result = described_class.new(
          valid: false,
          errors: ["Invalid TTC tag"]
        )

        expect(result.errors).to eq(["Invalid TTC tag"])
      end

      it "accepts multiple errors" do
        errors = ["Error 1", "Error 2", "Error 3"]
        result = described_class.new(
          valid: false,
          errors: errors
        )

        expect(result.errors.size).to eq(3)
      end
    end
  end

  describe "immutability" do
    let(:result) do
      described_class.new(
        valid: false,
        errors: ["Error 1", "Error 2"]
      )
    end

    it "freezes the errors array" do
      expect(result.errors).to be_frozen
    end

    it "prevents modification of errors" do
      expect { result.errors << "Error 3" }
        .to raise_error(FrozenError)
    end
  end

  describe "#valid?" do
    it "returns true for valid validation" do
      result = described_class.new(valid: true)
      expect(result.valid?).to be true
    end

    it "returns false for invalid validation" do
      result = described_class.new(valid: false)
      expect(result.valid?).to be false
    end

    it "returns true by default" do
      result = described_class.new
      expect(result.valid?).to be true
    end
  end

  describe "#invalid?" do
    it "returns false for valid validation" do
      result = described_class.new(valid: true)
      expect(result.invalid?).to be false
    end

    it "returns true for invalid validation" do
      result = described_class.new(valid: false)
      expect(result.invalid?).to be true
    end

    it "returns false by default" do
      result = described_class.new
      expect(result.invalid?).to be false
    end

    it "is opposite of valid?" do
      valid_result = described_class.new(valid: true)
      invalid_result = described_class.new(valid: false)

      expect(valid_result.valid?).to eq(!valid_result.invalid?)
      expect(invalid_result.valid?).to eq(!invalid_result.invalid?)
    end
  end

  describe "#add_error" do
    let(:original_result) do
      described_class.new(valid: true, errors: [])
    end

    it "returns a new ValidationResult with the error added" do
      new_result = original_result.add_error("Invalid tag")

      expect(new_result).to be_a(ExtractTtc::Models::ValidationResult)
      expect(new_result).not_to eq(original_result)
    end

    it "adds error to errors array" do
      new_result = original_result.add_error("Invalid tag")

      expect(new_result.errors).to include("Invalid tag")
      expect(new_result.errors.size).to eq(1)
    end

    it "sets valid to false" do
      new_result = original_result.add_error("Invalid tag")

      expect(new_result.valid).to be false
      expect(new_result.valid?).to be false
    end

    it "does not modify the original result" do
      original_result.add_error("Invalid tag")

      expect(original_result.valid).to be true
      expect(original_result.errors).to be_empty
    end

    it "can add multiple errors sequentially" do
      result1 = original_result.add_error("Error 1")
      result2 = result1.add_error("Error 2")
      result3 = result2.add_error("Error 3")

      expect(result3.errors).to eq(["Error 1", "Error 2", "Error 3"])
      expect(result3.valid).to be false
    end

    it "preserves existing errors when adding new ones" do
      result_with_error = described_class.new(
        valid: false,
        errors: ["Existing error"]
      )

      new_result = result_with_error.add_error("New error")

      expect(new_result.errors).to eq(["Existing error", "New error"])
    end

    it "maintains immutability through error additions" do
      result1 = original_result.add_error("Error 1")
      result2 = result1.add_error("Error 2")

      expect(original_result.errors).to be_empty
      expect(result1.errors).to eq(["Error 1"])
      expect(result2.errors).to eq(["Error 1", "Error 2"])
    end
  end

  describe "attribute readers" do
    let(:result) do
      described_class.new(
        valid: false,
        errors: ["Error 1", "Error 2"]
      )
    end

    it "provides read access to valid" do
      expect(result.valid).to be false
    end

    it "provides read access to errors" do
      expect(result.errors).to eq(["Error 1", "Error 2"])
    end
  end

  describe "usage scenarios" do
    it "handles file validation errors" do
      result = described_class.new(valid: true)
      result = result.add_error("File not found")
      result = result.add_error("Permission denied")

      expect(result.invalid?).to be true
      expect(result.errors).to contain_exactly("File not found", "Permission denied")
    end

    it "handles format validation errors" do
      result = described_class.new(valid: true)
      result = result.add_error("Invalid TTC tag: expected 'ttcf', got 'OTTO'")

      expect(result.invalid?).to be true
      expect(result.errors.first).to include("Invalid TTC tag")
    end

    it "represents successful validation" do
      result = described_class.new(valid: true)

      expect(result.valid?).to be true
      expect(result.errors).to be_empty
    end
  end
end