# Define os tipos que serão escritos e lidos.
class BinaryBase
  TYPES = {
    # Integer 8-bit unsigned.
    byte: 'C',
    sbyte: 'c',
    short: 's',
    ushort: 'S',
    int: 'i',
    uint: 'I',
    float: 'f',
    # q representa um número de 64 bits, diferentemente
    # de l, que representa um número de 32 bits.
    long: 'q',
    # Tipos não-oficiais.
    boolean: 'b',
    string: 'r',
    date: 't'
  }.freeze
end
