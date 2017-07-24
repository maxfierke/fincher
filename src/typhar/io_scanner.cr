module Typhar
  class IOScanner
    @last_match : ::Regex::MatchData?
    @line = ""
    @line_offset = 0
    @line_start_offset : Int32 | Int64 = 0
    @line_size = 0

    getter io
    getter last_match
    forward_missing_to io

    def initialize(@io : Typhar::IO)
    end

    def [](index)
      @last_match.not_nil![index]
    end

    def []?(index)
      @last_match.try(&.[index]?)
    end

    def eos?
      io.closed? || offset >= size
    end

    def peek(*args)
    end

    def rest
      io.gets_to_end
    end

    def string
      @line
    end

    def reset
      @line = ""
      @line_offset = 0
      @line_start_offset = 0
      @line_size = 0
      @last_match = nil
      io.rewind
    end

    def terminate
      @last_match = nil
      @line_offset = @line_size
      io.close
    end

    def check(pattern)
      match(pattern, advance: false, options: Regex::Options::ANCHORED)
    end

    def check_until(pattern)
      match(pattern, advance: false, options: Regex::Options::None)
    end

    def skip(pattern : Regex)
      match = scan(pattern)
      match.size if match
    end

    def skip_until(pattern)
      match = scan_until(pattern)
      match.size if match
    end

    def scan(pattern)
      match(pattern, advance: true, options: Regex::Options::ANCHORED)
    end

    def scan_until(pattern)
      match(pattern, advance: true, options: Regex::Options::None)
    end

    def offset
      line_start_offset = @line_start_offset
      line_offset = @line_offset

      if line_start_offset > 0 || line_offset > 0
        line_start_offset + line_offset
      else
        io.pos
      end
    end

    def offset=(position)
      raise IndexError.new unless position >= 0
      io.pos = position
    end

    def pos
      offset
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
      if last_match = @last_match
        stream << " \"" << last_match[0] << "\" "
      end
      stream << ">"
    end

    private def match(pattern, advance = true, options = Regex::Options::ANCHORED)
      last_match = @last_match
      last_match_str = nil

      if last_match
        last_match_str = line_match(pattern, advance: true, options: Regex::Options::None)
      end

      unless last_match
        each_line(advance) do |line|
          @line = line
          last_match_str = line_match(pattern, advance: true, options: Regex::Options::None)
          break if last_match_str
        end
      end

      last_match_str
    end

    private def line_match(pattern, advance = true, options = Regex::Options::ANCHORED)
      match = pattern.match_at_byte_index(@line, @line_offset, options)
      if match
        start = @line_offset
        new_byte_offset = match.byte_end(0).to_i
        @line_offset = new_byte_offset if advance

        @last_match = match
        @line.byte_slice(start, new_byte_offset - start)
      else
        @last_match = nil
      end
    end

    private def each_line(advance = true)
      io.each_line do |line|
        @line_start_offset = io.pos - line.bytesize
        @line_offset = 0
        @line_size = line.size
        yield line
      end
    end
  end
end
