require 'json'

class Consumer
  attr_accessor :logfile, :block

  def initialize(logfile, &block)
    self.logfile = logfile
    self.block = block
  end

  def start
    file = File.open(logfile, 'r')

    # TODO read offset from consumer checkpoint file
    # TODO seek to offset

    loop do
      begin
        sleep 1
        print '.'
      end while file.eof?

      line = file.readline.chomp

      begin
        event = JSON.parse(line)
        block.call(event)
      rescue
        puts 'oh no'
      end

      # TODO update consumer checkpoint file with new offset
    end
  end
end
