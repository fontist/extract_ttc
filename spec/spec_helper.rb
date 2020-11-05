require "extract_ttc"

RSpec.configure do |config| # rubocop:disable Style/SymbolProc
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
end
