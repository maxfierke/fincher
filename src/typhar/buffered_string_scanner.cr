require "string_scanner"

module Typhar
  class BufferedStringScanner
    BUFFER_SIZE = 8192

    @current_scanner : StringScanner?
    @total_buffered = 0
    @buffer : String?

    def initialize(@io : Typhar::IO)
    end

    def scan(pattern)
      if s = scanner
        s.scan(pattern)
      end
    end

    def scan_until(pattern)
      if s = scanner
        s.scan_until(pattern)
      end
    end

    def skip(pattern)
      if s = scanner
        s.skip(pattern)
      end
    end

    def skip_until(pattern)
      if s = scanner
        s.skip_until(pattern)
      end
    end

    def check(pattern)
      if s = scanner
        s.check(pattern)
      end
    end

    def check_until(pattern)
      if s = scanner
        s.check_until(pattern)
      end
    end

    def [](n)
      scanner.not_nil![n]
    end

    def []?(n)
      if s = scanner
        s[n]?
      end
    end

    def reset
      @current_scanner = nil
      @io.reset
    end

    def terminate
      @current_scanner = nil
      @io.gets_to_end
    end

    def rest
      String.build do |str|
        str << @io.gets(@current_scanner.offset)
        str << @io.gets_to_end
      end
    end

    def inspect(io : IO)
      io << "#<BufferedStringScanner "
      offset = offset()
      io << offset << "/" << @buffer.size
      start = Math.min(Math.max(offset - 2, 0), Math.max(0, @buffer.size - 5))
      io << " \"" << @buffer[start, 5] << "\" >"
    end

    private def scanner
      if !@current_scanner || @current_scanner.not_nil!.eos?
        next_scanner
      end
      @current_scanner
    end

    private def next_scanner
      buffer = @io.gets(BUFFER_SIZE).not_nil!

      if buffer
        @current_scanner = StringScanner.new(buffer)
        @buffer = buffer
        @total_buffered += buffer.size
      else
        @current_scanner = nil
      end
    end
  end
end
