module Typhar
  class IOScanner
    @last_match : ::Regex::MatchData?
    @line_offset = 0
    @line_start_offset : Int32 | Int64 = 0

    getter io
    getter last_match
    forward_missing_to io

    def initialize(@io : ::IO::Memory | ::IO::FileDescriptor)
    end

    def initialize(io : IOScanner)
      @io = io.io
      @last_match = io.last_match
    end

    def scan_until(pattern)
      last_match = @last_match

      if last_match
        last_match = scan_next(pattern, last_match.post_match)
      end

      unless last_match
        io.each_line do |line|
          @line_start_offset = io.pos
          @line_offset = 0
          m = scan_next(pattern, line)
          if m
            break
          end

          @last_match = nil
        end
      end

      @last_match
    end

    def offset
      line_start_offset = @line_start_offset

      if line_start_offset
        line_start_offset + @line_offset
      else
        io.pos
      end
    end

    def size
      case _io = io
      when ::IO::FileDescriptor
        _io.stat.size
      else
        _io.size
      end
    end

    def inspect(stream : ::IO)
      stream << "#<IOScanner "
      stream << offset << "/" << size
      # start = Math.min(Math.max(offset - 2, 0), Math.max(0, @buffer.size - 5))
      if last_match = @last_match
        stream << " @last_match=\"" << last_match.string << "\" "
      end
      stream << ">"
    end

    private def scan_next(pattern, str)
      if m = pattern.match(str)
        @line_offset += m.pre_match.bytesize
        @last_match = m
        m
      else
        nil
      end
    end
  end
end
