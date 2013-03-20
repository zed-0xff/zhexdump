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

  class << self
    def dump data, h = {}
      offset      = h.fetch(:offset, 0)
      dedup       = h.fetch(:dedup, true)
      show_offset = h.fetch(:show_offset, h.fetch(:show_addr, true))

      if offset == false
        show_offset = false
        offset = 0
      end

      add         = h[:add]    || 0
      size        = h[:size]   || (data.size-offset)
      tail        = h[:tail]   || "\n"
      width       = h[:width]  || 0x10                 # row width, in bytes
      output      = h[:output] || $>

      size = data.size-offset if size+offset > data.size

      prevhex = ''; c = nil; prevdup = false; start = offset
      while true
        ascii = ''; hex = ''
        width.times do |i|
          hex << ' ' if i%8==0 && i>0
          if c = ((size > 0) && data[offset+i])
            hex << "%02x " % c.ord
            ascii << ((32..126).include?(c.ord) ? c : '.')
          else
            hex << '   '
            ascii << ' '
          end
          size-=1
        end

        if dedup && hex == prevhex
          row = "*"
          yield(row, offset+add, ascii) if block_given?
          unless prevdup
            output << "\n" if offset > start
            output << row
          end
          prevdup = true
        else
          row = (show_offset ?  ("%08x: " % (offset + add)) : '') + hex
          yield(row, offset+add, ascii) if block_given?
          row << ' |' + ascii + "|"
          output << "\n" if offset > start
          output << row
          prevdup = false
        end

        offset += width
        prevhex = hex
        break if size <= 0
      end
      if show_offset && prevdup
        row = "%08x: " % (offset + add)
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

