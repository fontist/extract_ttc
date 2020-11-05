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
  ffi_lib File.expand_path("../ext/stripttc/stripttc.so", __dir__)
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
    stdout.split("=>").last.split(" ")
  end
end
