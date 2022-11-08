#==============================================================================
# ** Binary
#------------------------------------------------------------------------------
#  Esta classe lê e escreve dados binários.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Binary

  TYPES = {
    # Integer 8-bit unsigned
    :byte => 'C',
    :sbyte => 'c',
    :short => 's',
    :ushort => 'S',
    :int => 'i',
    :uint => 'I',
    :float => 'f',
    # q representa um número de 64 bits, diferentemente
    #de l, que representa um número de 32 bits
    :long => 'q',
    # Tipos não-oficiais
    :boolean => 'b',
    :string => 'r',
    :date => 't'
  }
  
end

#==============================================================================
# ** BinaryWriter
#==============================================================================
class BinaryWriter < Binary

  def initialize(manual_types = false)
    @manual_types = manual_types
    @formats = '' unless manual_types?
    @binary = []
    @pack = ''
  end

  def write(type, data = nil)
    data ||= type
    case data
    when String; write_string(data)
    when Integer; write_int(data, type)
    when Float; write_float(data)
    when Time; write_date(data)
    else; write_boolean(data)
    end
  end
  
  def to_s
    concat_formats unless manual_types?
    @binary.pack(@pack)
  end
  
  private

  def write_int(value, type)
    type = type.is_a?(Symbol) ? type : auto_int_type(value)
    push(type, value)
    @formats << TYPES[type] unless manual_types?
  end

  def auto_int_type(value)
    if value >= -128 && value <= 127; :sbyte
    elsif value > 127 && value <= 255; :byte
    elsif value >= -32_767 && value <= 32_767; :short
    elsif value > 32_767 && value <= 65_535; :ushort
    elsif value >= -2_147_483_647 && value <= 2_147_483_647; :int
    elsif value > 2_147_483_647 && value <= 4_294_967_295; :uint
    else; :long
    end
  end

  def write_float(value)
    push(:float, value)
    @formats << TYPES[:float] unless manual_types?
  end
  
  def write_boolean(value)
    push(:byte, value ? 1 : 0)
    @formats << TYPES[:boolean] unless manual_types?
  end
  
  def write_string(str)
    push(:ushort, str.bytesize)
    @binary += str.bytes
    @pack << "#{TYPES[:byte]}#{str.bytesize}"
    @formats << TYPES[:string] unless manual_types?
  end
  
  def write_date(time)
    push(:short, time.year)
    push(:byte, time.month)
    push(:byte, time.day)
    @formats << TYPES[:date] unless manual_types?
  end

  def concat_formats
    # Reduz formatos utilizando RegExp quando muitos dados forem escritos no buffer
    @formats.gsub!(/(([a-z])(\2)+)/) { |f| "#{f[0]}#{f.size}" } if @formats.bytesize > 50
    @binary = [@formats.bytesize] + @formats.bytes + @binary
    @pack = "#{TYPES[:ushort]}#{TYPES[:byte]}#{@formats.bytesize}#{@pack}"
  end

  def manual_types?
    @manual_types
  end
  
  def push(type, value)
    @binary << value
    @pack << TYPES[type]
  end
  
end

#==============================================================================
# ** BinaryReader
#==============================================================================
class BinaryReader < Binary

  def initialize(binary, manual_types = false)
    # Cria a posição mutável da array, em vez de usar shift no
    #método unpack, para que a mesma array seja aproveitada,
    #e não recriada, durante a leitura
    @b_pos = 0
    @f_index = 0
    @bytes = binary.is_a?(Binary_Writer) ? binary.to_s.bytes : binary.bytes
    @formats = read_string unless manual_types
  end

  def read(type = nil)
    type ||= @formats[@f_index]
    data = case type
           when TYPES[:byte], :byte; read_byte
           when TYPES[:sbyte], :sbyte; unpack(TYPES[:sbyte], 1)
           when TYPES[:boolean], :boolean; read_boolean
           when TYPES[:short], :short; read_short
           when TYPES[:ushort], :ushort; read_ushort
           when TYPES[:float], :float; unpack(TYPES[:float], 4)
           when TYPES[:int], :int; unpack(TYPES[:int], 4)
           when TYPES[:uint], :uint; unpack(TYPES[:uint], 4)
           when TYPES[:long], :long; unpack(TYPES[:long], 8)
           when TYPES[:string], :string; read_string
           when TYPES[:date], :date; read_date
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
