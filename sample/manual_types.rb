require_relative '../lib/binary'

binary_writer = BinaryWriter.new(manual_types: true)
binary_writer.write(:string, 'text')
binary_writer.write(:byte, 1)
binary_writer.write(:boolean, true)

binary_reader = BinaryReader.new(binary_writer, manual_types: true)
puts binary_reader.read(:string)
puts binary_reader.read(:byte)
puts binary_reader.read(:boolean)
