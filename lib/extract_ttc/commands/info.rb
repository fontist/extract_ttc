# frozen_string_literal: true

require "paint"

module ExtractTtc
  # Command to show detailed information about a TTC file
  class InfoCommand
    def initialize(options = {})
      @options = options
      @verbose = options[:verbose] || false
    end

    def run(file_path)
      validate_file_exists(file_path)

      File.open(file_path, "rb") do |file|
        ttc = TrueTypeCollection.read(file)

        display_header_info(ttc, file_path)
        display_font_info(ttc, file) if @verbose

        0 # Success
      end
    rescue ExtractTtc::ReadFileError => e
      display_error("File read error: #{e.message}")
      1
    rescue ExtractTtc::InvalidFileError => e
      display_error("Invalid file: #{e.message}")
      2
    rescue StandardError => e
      display_error("Error: #{e.message}")
      3
    end

    private

    def validate_file_exists(file_path)
      return if File.exist?(file_path)

      raise ExtractTtc::ReadFileError, "File not found: #{file_path}"
    end

    def display_header_info(ttc, file_path)
      filesize = File.size(file_path)

      puts Paint["═══ TTC File Information ═══", :cyan, :bold]
      puts
      puts Paint["📦 File: ", :bold] + file_path
      puts Paint["💾 Size: ", :bold] + Paint[format_bytes(filesize), :green]
      puts
      puts Paint["═══ Header ═══", :cyan, :bold]
      puts Paint["🏷️  Tag: ", :bold] + Paint[ttc.tag.to_s, :yellow]
      puts Paint["📌 Version: ", :bold] + "#{ttc.major_version}.#{ttc.minor_version}" +
           Paint[" (0x#{ttc.version.to_i.to_s(16).upcase})", :white]
      puts Paint["🔢 Number of fonts: ", :bold] + Paint[ttc.num_fonts.to_s, :green]
      puts
      puts Paint["═══ Font Offsets ═══", :cyan, :bold]
      ttc.font_offsets.each_with_index do |offset, index|
        puts Paint["  #{index}.", :white] + " " +
             Paint["Offset: ", :bold] + offset.to_s.rjust(8) +
             Paint[" (0x#{offset.to_i.to_s(16).upcase})", :white]
      end
    end

    def display_font_info(ttc, file)
      puts
      puts Paint["═══ Font Details ═══", :cyan, :bold]

      ttc.num_fonts.times do |index|
        offset = ttc.font_offsets[index]
        font = TrueTypeFont.from_ttc(file, offset)

        puts
        puts Paint["📝 Font #{index}:", :magenta, :bold]
        puts "  " + Paint["SFNT version: ", :bold] +
             Paint["0x#{font.header.sfnt_version.to_i.to_s(16).upcase}", :cyan]
        puts "  " + Paint["Number of tables: ", :bold] +
             Paint[font.header.num_tables.to_s, :green]
        puts "  " + Paint["Tables:", :bold]

        font.tables.each do |table|
          puts "    " + Paint["•", :yellow] + " " +
               table.tag.to_s.ljust(8) +
               Paint["checksum: ", :white] + Paint["0x#{table.checksum.to_i.to_s(16).upcase.rjust(8, '0')}", :cyan] +
               Paint[" offset: ", :white] + table.offset.to_i.to_s.rjust(8) +
               Paint[" length: ", :white] + Paint[table.table_length.to_i.to_s.rjust(8), :green]
        end
      end
    end

    def format_bytes(bytes)
      if bytes < 1024
        "#{bytes} B"
      elsif bytes < 1024 * 1024
        "#{(bytes / 1024.0).round(2)} KB"
      else
        "#{(bytes / (1024.0 * 1024)).round(2)} MB"
      end
    end

    def display_error(message)
      warn Paint["❌ Error: ", :red] + message
    end
  end
end