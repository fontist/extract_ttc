require "extract_ttc/version"
require "ffi"
require "tempfile"

module ExtractTtc
  class Error < StandardError; end

  class ReadFileError < Error; end

  class InvalidFileError < Error; end

  class WriteFileError < Error; end

  class UnknownResultError < Error; end

  extend FFI::Library
  # NOTE: ffi doesn't support bundles out of box https://github.com/ffi/ffi/issues/42#issuecomment-750031554
  # NOTE: rake-compiler doesn't support dylib generation https://github.com/rake-compiler/rake-compiler/issues/183
  macos_binary = "stripttc.bundle"
  lib_name = if File.exist?(File.join(File.dirname(__FILE__), macos_binary))
               macos_binary
             else
               "stripttc.so"
             end
  ffi_lib File.join(File.dirname(__FILE__), lib_name)
  attach_function :handlefile, [:string], :int

  def self.extract(path)
    stdout, stderr, code = capture3 do
      handlefile(path)
    end

    return handle_error(code, stderr) unless code.zero?

    fetch_filenames(stdout)
  end

  def self.handle_error(code, stderr)
    case code
    when -1
      raise ReadFileError, stderr
    when -2
      raise InvalidFileError, stderr
    when -3
      raise WriteFileError, stderr
    else
      raise UnknownResultError, "Return code: #{code}"
    end
  end

  def self.capture3
    stderr = status = nil

    stdout = capture_stream($stdout) do
      stderr = capture_stream($stderr) do
        status = yield
      end
    end

    [stdout, stderr, status]
  end

  def self.capture_stream(stream_io)
    origin_stream = stream_io.dup

    Tempfile.open("captured_stream") do |captured_stream|
      stream_io.reopen(captured_stream)
      yield
      captured_stream.rewind
      return captured_stream.read
    end
  ensure
    stream_io.reopen(origin_stream)
  end

  def self.fetch_filenames(stdout)
    stdout.split("=>").last.split
  end
end
