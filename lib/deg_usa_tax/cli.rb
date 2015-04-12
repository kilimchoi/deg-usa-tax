require 'deg_usa_tax'

module DegUsaTax
  class CLI
    def initialize(args, output, error_output)
      @args = args
      @output = output
      @error_output = error_output
    end

    # Returns true for success, false for failure.
    def run
      if @args.empty?
        @error_output.puts "No arguments passed."
        return false
      end

      command = @args[0]
      case command
      when 'btc'
        return run_btc(@args[1, @args.length])
      else
        @error_output.puts "Unrecognized command #{command}"
        return false
      end
    end

    def run_btc(args)
      filename = args[0]
      if filename.nil?
        @error_output.puts "No filename given."
        return false
      end

      history = bitcoin_history_from_file(filename)
      report_bitcoin_history(history)
      true
    end

    def bitcoin_history_from_file(filename)
      history = Bitcoin::History.new
      history_data = File.read(filename)
      history.instance_eval history_data
    end
  end
end
