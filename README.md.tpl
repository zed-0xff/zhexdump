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
```

### Dump to string
```ruby
  s = ''
  ZHexdump.dump "abc123", :output => s
  puts "START\n#{s}END"
```

### String#hexdump
```ruby
  "foobar".hexdump
```

### String#to_hexdump
```ruby
  s = 32.upto(63).map(&:chr).join
  puts s.to_hexdump
```

### Custom width
```ruby
  ZHexdump.dump "abc123"*2, :width => 3
```

### Dumping only part of data
```ruby
  ZHexdump.dump "0123456789abcdef", :size => 5, :offset => 3
```

### Hide offset
```ruby
  ZHexdump.dump "abc123", :offset => false
```

### Add to offset
```ruby
  ZHexdump.dump "abc123", :add => 0x1234
```

### Duplicate rows hiding enabled (default)
```ruby
  ZHexdump.dump "0123456789abcdef"*5
```

### Duplicate rows hiding disabled
```ruby
  ZHexdump.dump "0123456789abcdef"*5, :dedup => false
```

### Tail comment
```ruby
  ZHexdump.dump "abc123", :tail => " comment here"
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
```
