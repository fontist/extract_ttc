# frozen_string_literal: true

require "spec_helper"

RSpec.describe ExtractTtc::Utilities::OutputPathGenerator do
  describe ".generate" do
    context "with default output directory" do
      it "generates path with two-digit index" do
        path = described_class.generate("Helvetica.ttc", 0)
        expect(path).to eq("Helvetica_00.ttf")
      end

      it "generates path with basename only" do
        path = described_class.generate("/path/to/Helvetica.ttc", 0)
        expect(path).to eq("Helvetica_00.ttf")
      end

      it "handles index 0" do
        path = described_class.generate("Font.ttc", 0)
        expect(path).to eq("Font_00.ttf")
      end

      it "handles single-digit index" do
        path = described_class.generate("Font.ttc", 5)
        expect(path).to eq("Font_05.ttf")
      end

      it "handles double-digit index" do
        path = described_class.generate("Font.ttc", 15)
        expect(path).to eq("Font_15.ttf")
      end

      it "handles triple-digit index" do
        path = described_class.generate("Font.ttc", 123)
        expect(path).to eq("Font_123.ttf")
      end

      it "removes file extension from input" do
        path = described_class.generate("MyFont.ttc", 0)
        expect(path).to eq("MyFont_00.ttf")
      end

      it "handles input without extension" do
        path = described_class.generate("MyFont", 0)
        expect(path).to eq("MyFont_00.ttf")
      end

      it "handles input with multiple dots" do
        path = described_class.generate("My.Font.File.ttc", 0)
        expect(path).to eq("My.Font.File_00.ttf")
      end

      it "handles input with path separators" do
        path = described_class.generate("fonts/subfolder/Helvetica.ttc", 3)
        expect(path).to eq("Helvetica_03.ttf")
      end
    end

    context "with custom output directory" do
      it "generates path in specified directory" do
        path = described_class.generate("Font.ttc", 0, output_dir: "/tmp")
        expect(path).to eq("/tmp/Font_00.ttf")
      end

      it "handles directory without trailing slash" do
        path = described_class.generate("Font.ttc", 2,
                                        output_dir: "/output/fonts")
        expect(path).to eq("/output/fonts/Font_02.ttf")
      end

      it "handles directory with trailing slash" do
        path = described_class.generate("Font.ttc", 1,
                                        output_dir: "/output/fonts/")
        expect(path).to eq("/output/fonts/Font_01.ttf")
      end

      it "handles relative directory" do
        path = described_class.generate("Font.ttc", 0, output_dir: "output")
        expect(path).to eq("output/Font_00.ttf")
      end

      it "handles nested directories" do
        path = described_class.generate("Font.ttc", 0,
                                        output_dir: "output/subfolder/fonts")
        expect(path).to eq("output/subfolder/fonts/Font_00.ttf")
      end

      it "treats dot as current directory" do
        path = described_class.generate("Font.ttc", 0, output_dir: ".")
        expect(path).to eq("Font_00.ttf")
      end

      it "treats empty string as current directory" do
        path = described_class.generate("Font.ttc", 0, output_dir: "")
        expect(path).to eq("Font_00.ttf")
      end

      it "treats nil as current directory" do
        path = described_class.generate("Font.ttc", 0, output_dir: nil)
        expect(path).to eq("Font_00.ttf")
      end
    end

    context "with edge cases" do
      it "handles very large index" do
        path = described_class.generate("Font.ttc", 99999)
        expect(path).to eq("Font_99999.ttf")
      end

      it "handles filename with spaces" do
        path = described_class.generate("My Font.ttc", 0)
        expect(path).to eq("My Font_00.ttf")
      end

      it "handles filename with special characters" do
        path = described_class.generate("Font-Bold_Italic.ttc", 0)
        expect(path).to eq("Font-Bold_Italic_00.ttf")
      end
    end

    context "with invalid parameters" do
      it "raises ArgumentError for negative index" do
        expect { described_class.generate("Font.ttc", -1) }
          .to raise_error(ArgumentError, /font_index must be non-negative/)
      end
    end
  end

  describe ".generate_with_format" do
    context "with custom index formats" do
      it "generates path with three-digit padding" do
        path = described_class.generate_with_format("Font.ttc", 5, "%03d")
        expect(path).to eq("Font_005.ttf")
      end

      it "generates path with no padding" do
        path = described_class.generate_with_format("Font.ttc", 5, "%d")
        expect(path).to eq("Font_5.ttf")
      end

      it "generates path with four-digit padding" do
        path = described_class.generate_with_format("Font.ttc", 42, "%04d")
        expect(path).to eq("Font_0042.ttf")
      end

      it "generates path with single-digit padding" do
        path = described_class.generate_with_format("Font.ttc", 9, "%01d")
        expect(path).to eq("Font_9.ttf")
      end

      it "handles large numbers with small padding" do
        path = described_class.generate_with_format("Font.ttc", 123, "%02d")
        expect(path).to eq("Font_123.ttf")
      end
    end

    context "with output directory" do
      it "generates path in specified directory with custom format" do
        path = described_class.generate_with_format("Font.ttc", 5, "%03d",
                                                    output_dir: "/tmp")
        expect(path).to eq("/tmp/Font_005.ttf")
      end

      it "handles nil output directory" do
        path = described_class.generate_with_format("Font.ttc", 5, "%03d",
                                                    output_dir: nil)
        expect(path).to eq("Font_005.ttf")
      end

      it "handles empty output directory" do
        path = described_class.generate_with_format("Font.ttc", 5, "%03d",
                                                    output_dir: "")
        expect(path).to eq("Font_005.ttf")
      end
    end

    context "with invalid parameters" do
      it "raises ArgumentError for negative index" do
        expect { described_class.generate_with_format("Font.ttc", -1, "%02d") }
          .to raise_error(ArgumentError, /font_index must be non-negative/)
      end
    end
  end

  describe "consistency" do
    it "generates different paths for different indices" do
      path0 = described_class.generate("Font.ttc", 0)
      path1 = described_class.generate("Font.ttc", 1)
      path2 = described_class.generate("Font.ttc", 2)

      expect(path0).not_to eq(path1)
      expect(path1).not_to eq(path2)
      expect(path0).not_to eq(path2)
    end

    it "generates same path for same inputs" do
      path1 = described_class.generate("Font.ttc", 5, output_dir: "/tmp")
      path2 = described_class.generate("Font.ttc", 5, output_dir: "/tmp")

      expect(path1).to eq(path2)
    end

    it "generates sequential paths" do
      paths = (0..5).map { |i| described_class.generate("Font.ttc", i) }

      expect(paths).to eq([
                            "Font_00.ttf",
                            "Font_01.ttf",
                            "Font_02.ttf",
                            "Font_03.ttf",
                            "Font_04.ttf",
                            "Font_05.ttf",
                          ])
    end
  end
end
