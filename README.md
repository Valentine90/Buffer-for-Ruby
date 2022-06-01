## About
![lANG](https://img.shields.io/badge/LANG-RUBY(%20RGSS%20)-red?style=for-the-badge&logo=appveyo)
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
binary_reader = Binary_Reader.new(binary_writer.to_s)
text = binary_reader.read_string
number = binary_reader.read_byte
```
