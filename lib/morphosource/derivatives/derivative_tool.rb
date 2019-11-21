require 'open3'
require 'logger'

module Morphosource::Derivatives
  class DerivativeTool
    include Open3

    def logger
      @logger ||= activefedora_logger || Logger.new(STDERR)
    end

    protected
      def internal_call
        process_file
      end

      def process_file
        IO.popen(command) do |command_io|
          res = command_io.readlines.join('; ')
          command_io.close
          puts "Possible issue with derivative tool executing command \"#{command}\": \"#{res}\"" if $?.to_i == 0 && res
        end
      end

      def process_file0
        stdin, stdout, stderr, wait_thr = popen3(command)
        begin
          out = stdout.read
          err = stderr.read
          exit_status = wait_thr.value
          raise "Unable to execute command \"#{command}\"\n#{err}" unless exit_status.success?
          out
        ensure
          stdin.close
          stdout.close
          stderr.close
        end
      end

      def command
        ""
      end
  end
end
