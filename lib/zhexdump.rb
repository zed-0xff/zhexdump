#!/usr/bin/env ruby
require File.expand_path("zhexdump/version", File.dirname(__FILE__))

module ZHexdump

  # two methods for using when module ZHexdump is included in some class,
  # f.ex. String:

  # default hexdump to STDOUT (unless options[:output] overridden)
  def hexdump options = {}, &block
    ZHexdump.dump self, options, &block
  end

  # default hexdump to string (unless options[:output] overridden)
  def to_hexdump options = {}, &block
    r = ''
    options[:output] ||= r
    ZHexdump.dump self, options, &block
    r
  end

  @defaults = {}

  class << self
    attr_accessor :defaults

    def _get_param(h, key, default)
      h.fetch(key, defaults.fetch(key, default))
    end

    def dump data, h = {}
      offset      = h.fetch(:offset, 0)
      dedup       = h.fetch(:dedup, true)
      show_offset = h.fetch(:show_offset, h.fetch(:show_addr, true))

      if offset == false
        show_offset = false
        offset = 0
      end

      add           = _get_param(h, :add, 0)
      size          = _get_param(h, :size, data.size-offset)
      tail          = _get_param(h, :tail, "\n")
      width         = _get_param(h, :width, 16)
      output        = _get_param(h, :output, $stdout)
      indent        = _get_param(h, :indent, 0)
      offset_format = _get_param(h, :offset_format, "%08x: ")
      group_size    = _get_param(h, :group_size, 8)
      group_sep     = _get_param(h, :group_separator, ' ')
      show_ascii    = _get_param(h, :show_ascii, true)

      indent = ' ' * indent
      size = data.size-offset if size+offset > data.size

      prevhex = ''; c = nil; prevdup = false; start = offset
      while true
        ascii = ''; hex = ''
        width.times do |i|
          hex << group_sep if group_size > 0 && i > 0 && i % group_size == 0
          if c = ((size > 0) && data[offset+i])
            ord = c.ord
            hex << "%02x " % ord
            ascii << (ord == 0 ? ' ' : ((32..126).include?(ord) ? c : '.'))
          else
            hex << '   '
            ascii << ' '
          end
          size-=1
        end

        if dedup && hex == prevhex
          row = indent + "*"
          yield(row, offset+add, ascii) if block_given?
          unless prevdup
            output << "\n" if offset > start
            output << row
          end
          prevdup = true
        else
          row = indent + (show_offset ? (offset_format % (offset + add)) : '') + hex
          yield(row, offset+add, ascii) if block_given?
          if show_ascii
            row << ' |' + ascii + "|"
          else
            row.rstrip! # remove trailing spaces
          end
          output << "\n" if offset > start
          output << row
          prevdup = false
        end

        offset += width
        prevhex = hex
        break if size <= 0
      end
      if show_offset && prevdup
        row = indent + (offset_format % (offset + add))
        yield(row) if block_given?
        output << "\n" << row
      end
      output << tail
    end # dump

    alias :hexdump :dump
  end # class << self
end # module ZHexdump

Zhexdump = ZHexdump

class String
  include ZHexdump
end

if $0 == __FILE__
  h = {}
  case ARGV.size
    when 0
      puts "gimme fname [offset] [size]"
      exit
    when 1
      fname = ARGV[0]
    when 2
      fname = ARGV[0]
      h[:offset] = ARGV[1].to_i
    when 3
      fname = ARGV[0]
      h[:offset] = ARGV[1].to_i
      h[:size]   = ARGV[2].to_i
  end
  File.open(fname,"rb") do |f|
    f.seek h[:offset] if h[:offset]
    @data = f.read(h[:size])
  end
  puts ZHexdump.dump(@data)
end

