require "spec_helper"

RSpec.describe ExtractTtc::InfoCommand do
  let(:fixture_path) { File.join(__dir__, "../../fixtures/Helvetica.ttc") }
  let(:command) { described_class.new(options) }
  let(:options) { {} }

  describe "#run" do
    context "with valid TTC file" do
      it "displays header information" do
        output = capture_stdout { command.run(fixture_path) }

        # Strip ANSI codes for testing
        plain_output = output.gsub(/\e\[[0-9;]*m/, "")

        expect(plain_output).to include("TTC File Information")
        expect(plain_output).to include("File:")
        expect(plain_output).to include("Tag:")
        expect(plain_output).to include("Version: 2.0")
        expect(plain_output).to include("Number of fonts:")
        expect(plain_output).to include("Font Offsets")
      end

      it "returns success exit code" do
        silence_stdout do
          exit_code = command.run(fixture_path)
          expect(exit_code).to eq(0)
        end
      end

      context "with verbose option" do
        let(:options) { { verbose: true } }

        it "displays detailed font information" do
          output = capture_stdout { command.run(fixture_path) }

          expect(output).to include("Font Details")
          expect(output).to include("Font 0:")
          expect(output).to include("SFNT version:")
          expect(output).to include("Number of tables:")
          expect(output).to include("Tables:")
        end
      end
    end

    context "with missing file" do
      it "displays error and returns exit code 1" do
        output = capture_stderr { command.run("missing.ttc") }

        # Strip ANSI codes for testing
        plain_output = output.gsub(/\e\[[0-9;]*m/, "")

        expect(plain_output).to include("Error: File read error")
        expect(plain_output).to include("File not found")
      end

      it "returns error exit code" do
        silence_stderr do
          exit_code = command.run("missing.ttc")
          expect(exit_code).to eq(1)
        end
      end
    end

    context "with invalid file" do
      let(:invalid_file) { Tempfile.new.path }

      it "displays error and returns exit code 2" do
        output = capture_stderr { command.run(invalid_file) }

        expect(output).to include("Error:")
      end
    end
  end

  private

  def capture_stdout
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end

  def capture_stderr
    old_stderr = $stderr
    $stderr = StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = old_stderr
  end

  def silence_stdout
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = old_stdout
  end

  def silence_stderr
    old_stderr = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = old_stderr
  end
end