# Lê dados binários.
class BinaryReader < BinaryBase
  def initialize(binary, manual_types: false)
    # Cria a posição mutável da array, em vez de usar shift no
    # método unpack, para que a mesma array seja aproveitada,
    # e não recriada, durante a leitura.
    @b_pos = 0
    @f_index = 0
    @bytes = binary.is_a?(BinaryWriter) ? binary.to_s.bytes : binary.bytes
    @formats = read_string unless manual_types
    super()
  end

  def read(type = nil)
    type ||= @formats[@f_index]

    data = case type
           when TYPES[:byte], :byte then read_byte
           when TYPES[:sbyte], :sbyte then unpack(TYPES[:sbyte], 1)
           when TYPES[:boolean], :boolean then read_boolean
           when TYPES[:short], :short then read_short
           when TYPES[:ushort], :ushort then read_ushort
           when TYPES[:float], :float then unpack(TYPES[:float], 4)
           when TYPES[:int], :int then unpack(TYPES[:int], 4)
           when TYPES[:uint], :uint then unpack(TYPES[:uint], 4)
           when TYPES[:long], :long then unpack(TYPES[:long], 8)
           when TYPES[:string], :string then read_string
           when TYPES[:date], :date then read_date
           end

    @f_index += 1

    data
  end

  private

  def read_byte
    result = @bytes[@b_pos]

    @b_pos += 1

    result
  end

  def read_boolean
    read_byte == 1
  end

  def read_short
    unpack(TYPES[:short], 2)
  end

  def read_ushort
    unpack(TYPES[:ushort], 2)
  end

  def read_string
    size = read_ushort

    unpack("A#{size}", size)
  end

  def read_date
    Time.new(read_short, read_byte, read_byte)
  end

  def unpack(format, size)
    result = @bytes[@b_pos, size].pack('C*').unpack1(format)

    @b_pos += size

    result
  end
end
