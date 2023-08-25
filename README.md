## About
Reads and writes binary data.

## Examples
#### Writing:
```Ruby
binary_writer = BinaryWriter.new
binary_writer.write('text')
binary_writer.write(1)
binary_writer.write(true)
```
Or:
```Ruby
binary_writer = BinaryWriter.new(manual_types: true)
binary_writer.write(:string, 'text')
binary_writer.write(:byte, 1)
binary_writer.write(:boolean, true)
```

#### Reading:
```Ruby
binary_reader = BinaryReader.new(binary_writer)
binary_reader.read #=> 'text'
binary_reader.read #=> 1
binary_reader.read #=> true
```
Or:
```Ruby
binary_reader = BinaryReader.new(binary_writer, manual_types: true)
binary_reader.read(:string)  #=> 'text'
binary_reader.read(:byte)    #=> 1
binary_reader.read(:boolean) #=> true
```
