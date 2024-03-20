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
        output = process_file
        post_process(output)
      end

      def process_file
        IO.popen(command + " 2>&1") do |command_io|
          res = command_io.readlines.join('; ')
          command_io.close
          puts "Possible issue with derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{res}\"" if !$?.success? && res
          return res
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

      def post_process(raw_output)
        # does nothing, override to use in inherited classes
      end
  end
end
