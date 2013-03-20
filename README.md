# ZHexdump

A very flexible hexdump implementation.

## Installation

Add this line to your application's Gemfile:

    gem 'zhexdump'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zhexdump

## Usage

### Simple dump (to STDOUT)
```ruby
  ZHexdump.dump "abc123"*5

  # output:
  00000000: 61 62 63 31 32 33 61 62  63 31 32 33 61 62 63 31  |abc123abc123abc1|
  00000010: 32 33 61 62 63 31 32 33  61 62 63 31 32 33        |23abc123abc123  |
```

### Dump to string
```ruby
  s = ''
  ZHexdump.dump "abc123", :output => s
  puts "START\n#{s}END"

  # output:
  START
  00000000: 61 62 63 31 32 33                                 |abc123          |
  END
```

### String#hexdump
```ruby
  "foobar".hexdump

  # output:
  00000000: 66 6f 6f 62 61 72                                 |foobar          |
```

### String#to_hexdump
```ruby
  s = 32.upto(63).map(&:chr).join
  puts s.to_hexdump

  # output:
  00000000: 20 21 22 23 24 25 26 27  28 29 2a 2b 2c 2d 2e 2f  | !"#$%&'()*+,-./|
  00000010: 30 31 32 33 34 35 36 37  38 39 3a 3b 3c 3d 3e 3f  |0123456789:;<=>?|
```

### Custom width
```ruby
  ZHexdump.dump "abc123"*2, :width => 3

  # output:
  00000000: 61 62 63  |abc|
  00000003: 31 32 33  |123|
  00000006: 61 62 63  |abc|
  00000009: 31 32 33  |123|
```

### Dumping only part of data
```ruby
  ZHexdump.dump "0123456789abcdef", :size => 5, :offset => 3

  # output:
  00000003: 33 34 35 36 37                                    |34567           |
```

### Hide offset
```ruby
  ZHexdump.dump "abc123", :offset => false

  # output:
  61 62 63 31 32 33                                 |abc123          |
```

### Add to offset
```ruby
  ZHexdump.dump "abc123", :add => 0x1234

  # output:
  00001234: 61 62 63 31 32 33                                 |abc123          |
```

### Duplicate rows hiding enabled (default)
```ruby
  ZHexdump.dump "0123456789abcdef"*5

  # output:
  00000000: 30 31 32 33 34 35 36 37  38 39 61 62 63 64 65 66  |0123456789abcdef|
  *
  00000050: 
```

### Duplicate rows hiding disabled
```ruby
  ZHexdump.dump "0123456789abcdef"*5, :dedup => false

  # output:
  00000000: 30 31 32 33 34 35 36 37  38 39 61 62 63 64 65 66  |0123456789abcdef|
  00000010: 30 31 32 33 34 35 36 37  38 39 61 62 63 64 65 66  |0123456789abcdef|
  00000020: 30 31 32 33 34 35 36 37  38 39 61 62 63 64 65 66  |0123456789abcdef|
  00000030: 30 31 32 33 34 35 36 37  38 39 61 62 63 64 65 66  |0123456789abcdef|
  00000040: 30 31 32 33 34 35 36 37  38 39 61 62 63 64 65 66  |0123456789abcdef|
```

### Tail comment
```ruby
  ZHexdump.dump "abc123", :tail => " comment here"

  # output:
  00000000: 61 62 63 31 32 33                                 |abc123          | comment here
```

### Row preprocessing
```ruby
  lineno = 1
  ZHexdump.dump "abc123"*10 do |row, pos, ascii|
    row.gsub!(/ 3[123]/, " ..")
    row.insert 0, "  (line ##{lineno})  "
    ascii.tr! '123',"_"
    lineno += 1
  end

  # output:
    (line #1)  00000000: 61 62 63 .. .. .. 61 62  63 .. .. .. 61 62 63 ..  |abc___abc___abc_|
    (line #2)  00000010: .. .. 61 62 63 .. .. ..  61 62 63 .. .. .. 61 62  |__abc___abc___ab|
    (line #3)  00000020: 63 .. .. .. 61 62 63 ..  .. .. 61 62 63 .. .. ..  |c___abc___abc___|
    (line #4)  00000030: 61 62 63 .. .. .. 61 62  63 .. .. ..              |abc___abc___    |
```
