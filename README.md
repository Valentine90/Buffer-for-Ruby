## About
Reads and writes binary data.

## Examples
#### Writing:
```Ruby
binary_writer = Binary_Writer.new
binary_writer.write('text')
binary_writer.write(1)
```
Or:
```Ruby
binary_writer = Binary_Writer.new
binary_writer.write(:string, 'text')
binary_writer.write(:byte, 1)
```

#### Reading:
```Ruby
binary_reader = Binary_Reader.new(binary_writer)
binary_reader.read #=> 'text'
binary_reader.read #=> 1
```
Or:
```Ruby
binary_reader = Binary_Reader.new(binary_writer)
binary_reader.read(:string) #=> 'text'
binary_reader.read(:byte) #=> 1
```
