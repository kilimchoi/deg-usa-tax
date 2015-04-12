module DegUsaTax
  module OptionChecker
    private

    def check_opts(opts, valid_keys)
      invalid_keys = opts.keys - valid_keys
      if !invalid_keys.empty?
        raise ArgumentError, "Invalid keys: #{invalid_keys.join(', ')}"
      end
    end
  end
end
