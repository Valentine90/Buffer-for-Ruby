## Sobre
![lANG](https://img.shields.io/badge/LANG-RUBY(%20RGSS%20)-red?style=for-the-badge&logo=appveyo)
<p>Lê e escreve dados binários.</p>

## Exemplos:
Escrevendo:
```
buffer_writer = Buffer_Writer.new
buffer_writer.write_string('texto')
buffer_writer.write_byte(1)
```
Lendo:
```
buffer_reader = Buffer_Reader.new(buffer_writer.to_s)
text = buffer_reader.read_string
number = buffer_reader.read_byte
```
