# frozen_string_literal: true

require "spec_helper"

RSpec.describe ExtractTtc::Models::ExtractionResult do
  describe "#initialize" do
    context "with default parameters" do
      it "creates a successful result with no output files" do
        result = described_class.new

        expect(result.output_files).to eq([])
        expect(result.success).to be true
        expect(result.errors).to eq([])
      end
    end

    context "with successful extraction" do
      it "creates a result with output files" do
        output_files = ["font_00.ttf", "font_01.ttf"]
        result = described_class.new(
          output_files: output_files,
          success: true,
          errors: [],
        )

        expect(result.output_files).to eq(output_files)
        expect(result.success).to be true
        expect(result.errors).to be_empty
      end

      it "accepts single output file" do
        result = described_class.new(output_files: ["font_00.ttf"])

        expect(result.output_files).to eq(["font_00.ttf"])
      end

      it "accepts many output files" do
        files = (0..10).map { |i| "font_#{format('%02d', i)}.ttf" }
        result = described_class.new(output_files: files)

        expect(result.output_files.size).to eq(11)
      end
    end

    context "with failed extraction" do
      it "creates a result with errors" do
        errors = ["File not found", "Invalid format"]
        result = described_class.new(
          output_files: [],
          success: false,
          errors: errors,
        )

        expect(result.output_files).to be_empty
        expect(result.success).to be false
        expect(result.errors).to eq(errors)
      end

      it "accepts single error" do
        result = described_class.new(
          success: false,
          errors: ["File not found"],
        )

        expect(result.errors).to eq(["File not found"])
      end
    end
  end

  describe "immutability" do
    let(:result) do
      described_class.new(
        output_files: ["font_00.ttf", "font_01.ttf"],
        success: true,
        errors: [],
      )
    end

    it "freezes the output_files array" do
      expect(result.output_files).to be_frozen
    end

    it "freezes the errors array" do
      expect(result.errors).to be_frozen
    end

    it "prevents modification of output_files" do
      expect { result.output_files << "font_02.ttf" }
        .to raise_error(FrozenError)
    end

    it "prevents modification of errors" do
      expect { result.errors << "new error" }
        .to raise_error(FrozenError)
    end
  end

  describe "#success?" do
    it "returns true for successful extraction" do
      result = described_class.new(success: true)
      expect(result.success?).to be true
    end

    it "returns false for failed extraction" do
      result = described_class.new(success: false)
      expect(result.success?).to be false
    end

    it "returns true by default" do
      result = described_class.new
      expect(result.success?).to be true
    end
  end

  describe "#failure?" do
    it "returns false for successful extraction" do
      result = described_class.new(success: true)
      expect(result.failure?).to be false
    end

    it "returns true for failed extraction" do
      result = described_class.new(success: false)
      expect(result.failure?).to be true
    end

    it "returns false by default" do
      result = described_class.new
      expect(result.failure?).to be false
    end

    it "is opposite of success?" do
      successful = described_class.new(success: true)
      failed = described_class.new(success: false)

      expect(successful.success?).to eq(!successful.failure?)
      expect(failed.success?).to eq(!failed.failure?)
    end
  end

  describe "#add_error" do
    let(:original_result) do
      described_class.new(
        output_files: ["font_00.ttf"],
        success: true,
        errors: [],
      )
    end

    it "returns a new ExtractionResult with the error added" do
      new_result = original_result.add_error("File already exists")

      expect(new_result).to be_a(ExtractTtc::Models::ExtractionResult)
      expect(new_result).not_to eq(original_result)
    end

    it "adds error to errors array" do
      new_result = original_result.add_error("File already exists")

      expect(new_result.errors).to include("File already exists")
      expect(new_result.errors.size).to eq(1)
    end

    it "sets success to false" do
      new_result = original_result.add_error("File already exists")

      expect(new_result.success).to be false
      expect(new_result.success?).to be false
    end

    it "preserves output_files from original" do
      new_result = original_result.add_error("Error message")

      expect(new_result.output_files).to eq(["font_00.ttf"])
    end

    it "does not modify the original result" do
      original_result.add_error("Error message")

      expect(original_result.success).to be true
      expect(original_result.errors).to be_empty
    end

    it "can add multiple errors sequentially" do
      result1 = original_result.add_error("Error 1")
      result2 = result1.add_error("Error 2")
      result3 = result2.add_error("Error 3")

      expect(result3.errors).to eq(["Error 1", "Error 2", "Error 3"])
      expect(result3.success).to be false
    end

    it "preserves existing errors when adding new ones" do
      result_with_error = described_class.new(
        success: false,
        errors: ["Existing error"],
      )

      new_result = result_with_error.add_error("New error")

      expect(new_result.errors).to eq(["Existing error", "New error"])
    end
  end

  describe "attribute readers" do
    let(:result) do
      described_class.new(
        output_files: ["font_00.ttf", "font_01.ttf"],
        success: true,
        errors: [],
      )
    end

    it "provides read access to output_files" do
      expect(result.output_files).to eq(["font_00.ttf", "font_01.ttf"])
    end

    it "provides read access to success" do
      expect(result.success).to be true
    end

    it "provides read access to errors" do
      expect(result.errors).to eq([])
    end
  end
end
