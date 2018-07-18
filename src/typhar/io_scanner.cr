module Typhar
  class IOScanner
    BUFFER_SIZE = 4096

    @last_match : ::Regex::MatchData?
    @buffer = ""
    @buffer_cursor = 0
    @buffer_io_offset : Int32 | Int64 = 0
    @eof_reached = false

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
      offset >= size
    end

    def peek(len)
      buffer[offset, len]
    end

    def rest
      rest_of_buffer + io.gets_to_end
    end

    def string
      @buffer + io.gets_to_end
    end

    def reset
      reset_buffer_match!
      io.rewind
    end

    def terminate
      @last_match = nil
      @buffer_cursor = buffer_size
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
      @buffer_io_offset + @buffer_cursor
    end

    def offset=(position)
      raise IndexError.new unless position >= 0
      @buffer_io_offset = position
      io.pos = position
      @eof_reached = false
      next_buffer!
    end

    def pos
      offset
    end

    def pos=(position)
      self.offset = position
    end

    def size
      case _io = io
      when ::IO::FileDescriptor
        _io.info.size
      else
        if _io.responds_to?(:size)
          _io.size
        else
          raise "Unsupported IO subclass"
        end
      end
    end

    def inspect(stream : ::IO)
      stream << "#<Typhar::IOScanner "
      stream << offset << "/" << size
      start = Math.min(Math.max(@buffer_cursor - 2, 0), Math.max(0, @buffer.size - 5))
      stream << " \"" << buffer.byte_slice(start).chars.first(5).join("") << "\" "
      stream << ">"
    end

    private def buffer
      if @buffer.empty?
        next_buffer!
      else
        @buffer
      end
    end

    private def rest_of_buffer
      @buffer[@buffer_cursor, buffer_size]
    end

    private def buffer_size
      @buffer.bytesize
    end

    private def match(pattern, **kwargs)
      last_match_str = nil

      if buffer = @buffer
        last_match_str = buffer_match(pattern, **kwargs)
      end

      unless last_match_str
        each_buffer do |buffer|
          last_match_str = buffer_match(pattern, **kwargs)
          break if last_match_str
        end
      end

      last_match_str
    end

    private def buffer_match(pattern, advance = true, options = Regex::Options::ANCHORED)
      match = pattern.match_at_byte_index(@buffer, @buffer_cursor, options)
      if match
        start = @buffer_cursor
        new_byte_offset = match.byte_end(0).to_i
        @buffer_cursor = new_byte_offset if advance

        @last_match = match
        @buffer.byte_slice(start, new_byte_offset - start)
      else
        @last_match = nil
      end
    end

    private def each_buffer
      while !io_eof?
        buf = next_buffer!
        yield buf
      end
    end

    private def reset_buffer_match!
      @last_match = nil
      @eof_reached = false
      @buffer_io_offset = 0
      @buffer_cursor = 0
      @buffer = ""
    end

    private def next_buffer!
      before_offset = offset

      begin
        buf = io.read_string(BUFFER_SIZE)
      rescue ::IO::EOFError
        io.pos = before_offset
        buf = io.gets_to_end
        @eof_reached = true
      end

      @buffer_io_offset = io.pos - buf.bytesize
      @buffer_cursor = 0
      @buffer = buf
      buf
    end

    private def io_eof?
      @eof_reached || io.closed?
    end
  end
end
