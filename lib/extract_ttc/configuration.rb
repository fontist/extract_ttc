# frozen_string_literal: true

module ExtractTtc
  # Configuration class for runtime settings
  #
  # This plain Ruby class encapsulates all runtime configuration options for
  # the extract_ttc gem. It provides sensible defaults and supports merging
  # with user-provided options.
  #
  # The configuration is immutable by design - the merge method returns a new
  # Configuration instance rather than modifying the existing one.
  #
  # @example Creating a default configuration
  #   config = Configuration.default
  #   config.output_directory # => "."
  #   config.verbose # => false
  #
  # @example Merging with custom options
  #   config = Configuration.default
  #   new_config = config.merge(output_directory: "/tmp", verbose: true)
  #   new_config.output_directory # => "/tmp"
  #   new_config.verbose # => true
  #   config.verbose # => false (original unchanged)
  class Configuration
    # @return [String] Directory path where extracted fonts will be written
    attr_accessor :output_directory

    # @return [Boolean] Whether to overwrite existing files during extraction
    attr_accessor :overwrite_existing

    # @return [Boolean] Whether to validate font table checksums
    attr_accessor :validate_checksums

    # @return [Boolean] Whether to enable verbose output during operations
    attr_accessor :verbose

    # Initialize a new configuration instance
    #
    # @param output_directory [String] Directory for output files (default: ".")
    # @param overwrite_existing [Boolean] Allow overwriting files (default: false)
    # @param validate_checksums [Boolean] Validate table checksums (default: true)
    # @param verbose [Boolean] Enable verbose output (default: false)
    def initialize(
      output_directory: ".",
      overwrite_existing: false,
      validate_checksums: true,
      verbose: false
    )
      @output_directory = output_directory
      @overwrite_existing = overwrite_existing
      @validate_checksums = validate_checksums
      @verbose = verbose
    end

    # Create a configuration instance with default values
    #
    # This is a convenience factory method that returns a new Configuration
    # with all default settings applied.
    #
    # @return [Configuration] A new configuration with defaults
    #
    # @example
    #   config = Configuration.default
    #   config.output_directory # => "."
    #   config.overwrite_existing # => false
    def self.default
      new
    end

    # Merge this configuration with new options
    #
    # Creates a new Configuration instance with values merged from the provided
    # options hash. The original configuration is not modified, ensuring
    # immutability.
    #
    # @param options [Hash] Hash of configuration options to merge
    # @option options [String] :output_directory Directory for output files
    # @option options [Boolean] :overwrite_existing Allow overwriting files
    # @option options [Boolean] :validate_checksums Validate table checksums
    # @option options [Boolean] :verbose Enable verbose output
    # @return [Configuration] A new configuration with merged values
    #
    # @example Merging with new options
    #   config = Configuration.default
    #   new_config = config.merge(verbose: true, output_directory: "/tmp")
    #   new_config.verbose # => true
    #   new_config.output_directory # => "/tmp"
    #   new_config.overwrite_existing # => false (from original)
    def merge(options)
      self.class.new(
        output_directory: options.fetch(:output_directory, @output_directory),
        overwrite_existing: options.fetch(:overwrite_existing,
                                          @overwrite_existing),
        validate_checksums: options.fetch(:validate_checksums,
                                          @validate_checksums),
        verbose: options.fetch(:verbose, @verbose),
      )
    end

    # Convert configuration to hash representation
    #
    # Returns a hash containing all configuration settings with their current
    # values. This is useful for serialization, debugging, or passing the
    # configuration to other components.
    #
    # @return [Hash] Hash representation of the configuration
    #
    # @example Converting to hash
    #   config = Configuration.default.merge(verbose: true)
    #   config.to_h
    #   # => {
    #   #   output_directory: ".",
    #   #   overwrite_existing: false,
    #   #   validate_checksums: true,
    #   #   verbose: true
    #   # }
    def to_h
      {
        output_directory: @output_directory,
        overwrite_existing: @overwrite_existing,
        validate_checksums: @validate_checksums,
        verbose: @verbose,
      }
    end
  end
end
