require 'spec_helper'
require 'stringio'

describe ZHexdump do
  it "dumps to string" do
    s = ''
    ZHexdump.dump "foo", :output => s
    s.should == "00000000: 66 6f 6f                                          |foo             |\n"
  end

  it "dumps to stdout" do
    io = StringIO.new
    begin
      saved_stdout, $> = $>, io
      ZHexdump.dump "foo"
    ensure
      $> = saved_stdout
    end

    io.rewind
    io.read.should == "00000000: 66 6f 6f                                          |foo             |\n"
  end

  it "dumps w/o addr if show_addr=false" do
    s = ''
    ZHexdump.dump "foo", :output => s, :show_addr => false
    s.should == "66 6f 6f                                          |foo             |\n"
  end

  it "dumps w/o addr if show_offset=false" do
    s = ''
    ZHexdump.dump "foo", :output => s, :show_offset => false
    s.should == "66 6f 6f                                          |foo             |\n"
  end

  it "dumps w/o addr if offset=false" do
    s = ''
    ZHexdump.dump "foo", :output => s, :offset => false
    s.should == "66 6f 6f                                          |foo             |\n"
  end

  it "respects :size" do
    data = 'foo'*100
    s = ''
    ZHexdump.dump data, :output => s, :size => 3
    s.should == "00000000: 66 6f 6f                                          |foo             |\n"
  end

  it "respects :offset" do
    data = 'foobar'*100
    s = ''
    ZHexdump.dump data, :output => s, :offset => 2, :size => 3
    s.should == "00000002: 6f 62 61                                          |oba             |\n"
  end

  it "adds :add to offset shown" do
    data = 'foo'*100
    s = ''
    ZHexdump.dump data, :output => s, :size => 3, :add => 0x1234
    s.should == "00001234: 66 6f 6f                                          |foo             |\n"
  end

  it "shows tail" do
    data = 'foo'
    s = ''
    ZHexdump.dump data, :output => s, :tail => 'tail'
    s.should == "00000000: 66 6f 6f                                          |foo             |tail"
  end

  it "shows tail only on last line" do
    data = 'foo'*6
    s = ''
    ZHexdump.dump data, :output => s, :tail => 'tail'
    s.should == <<-EOF.split("\n").map(&:strip).join("\n")
      00000000: 66 6f 6f 66 6f 6f 66 6f  6f 66 6f 6f 66 6f 6f 66  |foofoofoofoofoof|
      00000010: 6f 6f                                             |oo              |tail
    EOF
  end

  it "no dedup: should have exactly 0x10 lines" do
    s = ''
    ZHexdump.dump "x"*0x100, :output => s, :dedup => false
    s.count("\n").should == 0x10
  end

  it "default dedup: should have exactly 2 lines" do
    s = ''
    ZHexdump.dump "x"*0x100, :output => s
    s.count("\n").should == 3
    s.strip.should == <<-EOF.split("\n").map(&:strip).join("\n")
      00000000: 78 78 78 78 78 78 78 78  78 78 78 78 78 78 78 78  |xxxxxxxxxxxxxxxx|
      *
      00000100:
    EOF
  end

  it "column width=4, no offset, each row prepend" do
    data = "ABCDEFGHIJKLMNOPQRST"
    s = ''
    ZHexdump.dump(data, :output => s, :width => 4, :show_offset => false) do |row, offset|
      row.insert(0,"color %4s:  " % "##{(offset/4)}")
    end
    s.should == <<-EOF.split("\n").map(&:strip).join("\n") + "\n"
      color   #0:  41 42 43 44  |ABCD|
      color   #1:  45 46 47 48  |EFGH|
      color   #2:  49 4a 4b 4c  |IJKL|
      color   #3:  4d 4e 4f 50  |MNOP|
      color   #4:  51 52 53 54  |QRST|
    EOF
  end

  it "column width=3, no offset, each row prepend" do
    data = "ABCDEFGHI"
    s = ''
    ZHexdump.dump(data, :output => s, :width => 3, :show_offset => false) do |row, offset|
      row.insert(0,"color %4s:  " % "##{(offset/3)}")
    end
    s.should == <<-EOF.split("\n").map(&:strip).join("\n") + "\n"
      color   #0:  41 42 43  |ABC|
      color   #1:  44 45 46  |DEF|
      color   #2:  47 48 49  |GHI|
    EOF
  end

  it "prepends spaces before offset" do
    data = 'foo'
    s = ''
    ZHexdump.dump(data, :output => s) do |x|
      x.insert(0,"  ")
    end
    s.should == "  00000000: 66 6f 6f                                          |foo             |\n"
  end

  it "modifies ascii" do
    data = 'foo'
    s = ''
    ZHexdump.dump(data, :output => s) do |row, offset, ascii|
      ascii.sub! 'foo', 'xxx'
    end
    s.should == "00000000: 66 6f 6f                                          |xxx             |\n"
  end

  it "String#hexdump dumps to stdout" do
    data = "foo"
    io = StringIO.new
    begin
      saved_stdout, $> = $>, io
      data.hexdump
    ensure
      $> = saved_stdout
    end

    io.rewind
    io.read.should == "00000000: 66 6f 6f                                          |foo             |\n"
  end

  it "String#to_hexdump dumps to a new string" do
    data = "foo"
    data.to_hexdump.should == "00000000: 66 6f 6f                                          |foo             |\n"
  end
end
