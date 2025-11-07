# frozen_string_literal: true

require "thor"
require_relative "commands/extract"
require_relative "commands/list"
require_relative "commands/info"

module ExtractTtc
  class Cli < Thor
    desc "extract FILE", "Extract TTF files from a TTC file"
    method_option :output_dir,
                  aliases: "-o",
                  type: :string,
                  desc: "Output directory for TTF files"
    method_option :verbose,
                  aliases: "-v",
                  type: :boolean,
                  default: false,
                  desc: "Enable verbose output"
    def extract(file)
      exit_code = ExtractCommand.new(options).run(file)
      exit(exit_code) unless exit_code.zero?
    end

    desc "ls FILE", "List fonts contained in a TTC file"
    method_option :verbose,
                  aliases: "-v",
                  type: :boolean,
                  default: false,
                  desc: "Enable verbose output"
    def ls(file)
      exit_code = ListCommand.new(options).run(file)
      exit(exit_code) unless exit_code.zero?
    end

    desc "info FILE", "Show detailed information about a TTC file"
    method_option :verbose,
                  aliases: "-v",
                  type: :boolean,
                  default: false,
                  desc: "Show detailed font information"
    def info(file)
      exit_code = InfoCommand.new(options).run(file)
      exit(exit_code) unless exit_code.zero?
    end
  end
end
