## About
Reads and writes binary data.

## Examples
#### Writing:
```Ruby
binary_writer = Binary_Writer.new
binary_writer.write('text')
binary_writer.write(1)
binary_writer.write(true)
```
Or:
```Ruby
manual_types = true
binary_writer = Binary_Writer.new(manual_types)
binary_writer.write(:string, 'text')
binary_writer.write(:byte, 1)
binary_writer.write(:boolean, true)
```

#### Reading:
```Ruby
binary_reader = Binary_Reader.new(binary_writer)
binary_reader.read #=> 'text'
binary_reader.read #=> 1
binary_reader.read #=> true
```
Or:
```Ruby
manual_types = true
binary_reader = Binary_Reader.new(binary_writer, manual_types)
binary_reader.read(:string) #=> 'text'
binary_reader.read(:byte) #=> 1
binary_reader.read(:boolean) #=> true
```
