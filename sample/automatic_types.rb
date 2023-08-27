require_relative '../lib/binary'

binary_writer = BinaryWriter.new
binary_writer.write('text')
binary_writer.write(1)
binary_writer.write(true)

binary_reader = BinaryReader.new(binary_writer)
puts binary_reader.read
puts binary_reader.read
puts binary_reader.read
