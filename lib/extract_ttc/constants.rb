# frozen_string_literal: true

module ExtractTtc
  # Constants module containing immutable constant definitions for TTC/TTF font file operations.
  #
  # This module defines all magic numbers, version identifiers, and file format constants
  # used throughout the extract_ttc gem. These values are based on the TrueType Collection
  # and TrueType Font specifications.
  module Constants
    # TrueType Collection file signature tag.
    # All valid TTC files must begin with this 4-byte tag.
    TTC_TAG = "ttcf"

    # TrueType Collection Version 1.0 identifier.
    # Represents the original TTC format version.
    TTC_VERSION_1 = 0x00010000

    # TrueType Collection Version 2.0 identifier.
    # Represents the extended TTC format with digital signature support.
    TTC_VERSION_2 = 0x00020000

    # Head table tag identifier.
    # The 'head' table contains global font header information including
    # the checksum adjustment field.
    HEAD_TAG = "head"

    # Magic number used for font file checksum adjustment calculation.
    # This constant is used in conjunction with the file checksum to compute
    # the checksumAdjustment value stored in the 'head' table.
    # Formula: checksumAdjustment = CHECKSUM_ADJUSTMENT_MAGIC - file_checksum
    CHECKSUM_ADJUSTMENT_MAGIC = 0xB1B0AFBA

    # Supported TTC version numbers.
    # An array of valid version identifiers for TrueType Collection files.
    SUPPORTED_VERSIONS = [TTC_VERSION_1, TTC_VERSION_2].freeze

    # Table data alignment boundary in bytes.
    # All table data in TTF files must be aligned to 4-byte boundaries,
    # with padding added as necessary.
    TABLE_ALIGNMENT = 4
  end
end
