## About
![lANG](https://img.shields.io/badge/LANG-RUBY-red?style=for-the-badge&logo=appveyo)
<p>Reads and writes binary data.</p>

## Examples
Writing:
```Ruby
binary_writer = Binary_Writer.new
binary_writer.write_string('text')
binary_writer.write_byte(1)
```
Reading:
```Ruby
binary_reader = Binary_Reader.new(binary_writer)
binary_reader.read_string #=> 'text'
binary_reader.read_byte #=> 1
```
