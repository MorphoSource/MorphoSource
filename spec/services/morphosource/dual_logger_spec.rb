require 'rails_helper'

RSpec.describe Morphosource::DualLogger do
  describe '#log' do
    it 'writes to both the given logger and STDOUT' do
      logger = instance_double(Logger)
      expect(logger).to receive(:info).with('hello')

      dual_logger = described_class.new(logger)
      expect { dual_logger.log('hello') }.to output("hello\n").to_stdout
    end

    it 'prefixes the STDOUT output but not the logger message' do
      logger = instance_double(Logger)
      expect(logger).to receive(:info).with('hello')

      dual_logger = described_class.new(logger, prefix: '[test]')
      expect { dual_logger.log('hello') }.to output("[test] hello\n").to_stdout
    end

    it 'respects the level: keyword' do
      logger = instance_double(Logger)
      expect(logger).to receive(:error).with('bad thing')

      dual_logger = described_class.new(logger)
      expect { dual_logger.log('bad thing', level: :error) }.to output("bad thing\n").to_stdout
    end

    it 'does not raise when no logger is given, and still writes to STDOUT' do
      dual_logger = described_class.new
      expect { dual_logger.log('hello') }.to output("hello\n").to_stdout
    end
  end
end
