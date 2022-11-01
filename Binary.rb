#==============================================================================
# ** Binary
#------------------------------------------------------------------------------
#  Esta classe lê e escreve dados binários.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Binary

  TYPES = {
    :byte => 'c',
    :sbyte => 'C',
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
# ** Binary_Writer
#==============================================================================
class Binary_Writer < Binary

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
    unless manual_types?
      @binary = [@formats.bytesize] + @formats.bytes + @binary
      @pack = "#{TYPES[:ushort]}#{TYPES[:byte] * @formats.size}#{@pack}"
    end
    @binary.pack(@pack)
  end
  
  private

  def write_int(value, type)
    type = type.is_a?(Symbol) ? type : auto_int_type(value)
    push(value, type)
    @formats << TYPES[type] unless manual_types?
  end

  def auto_int_type(value)
    if value >= 0 && value <= 255; :byte
    elsif value >= -128 && value < 0; :sbyte
    elsif value >= -32_767 && value <= 32_767; :short
    elsif value > 32_767 && value <= 65_535; :ushort
    elsif value >= -2_147_483_647 && value <= 2_147_483_647; :int
    elsif value > 2_147_483_647 && value <= 4_294_967_295; :uint
    else; :long
    end
  end

  def write_float(value)
    push(value, :float)
    @formats << TYPES[:float] unless manual_types?
  end
  
  def write_boolean(value)
    push(value ? 1 : 0, :byte)
    @formats << TYPES[:boolean] unless manual_types?
  end
  
  def write_string(str)
    push(str.bytesize, :ushort)
    str.each_byte { |c| push(c, :byte) }
    @formats << TYPES[:string] unless manual_types?
  end

  def write_date(time)
    push(time.year, :short)
    push(time.month, :byte)
    push(time.day, :byte)
    @formats << TYPES[:date] unless manual_types?
  end

  def manual_types?
    @manual_types
  end
  
  def push(value, type)
    @binary << value
    @pack << TYPES[type]
  end
  
end

#==============================================================================
# ** Binary_Reader
#==============================================================================
class Binary_Reader < Binary

  def initialize(binary, manual_types = false)
    @bytes = binary.is_a?(Binary_Writer) ? binary.to_s.bytes : binary.bytes
    @formats = read_string unless manual_types
    @index = 0
  end

  def read(type = nil)
    type ||= @formats[@index]
    data = case type
           when TYPES[:byte], TYPES[:sbyte], :byte, :sbyte; read_byte
           when TYPES[:boolean], :boolean; read_boolean
           when TYPES[:short], :short; read_short
           when TYPES[:ushort], :ushort; read_ushort
           when TYPES[:float], :float; shift(4, TYPES[:float])
           when TYPES[:int], :int; shift(4, TYPES[:int])
           when TYPES[:uint], :uint; shift(4, TYPES[:uint])
           when TYPES[:long], :long; shift(8, TYPES[:long])
           when TYPES[:string], :string; read_string
           when TYPES[:date], :date; read_date
           end
    @index += 1
    data
  end

  private
  
  def read_byte
    @bytes.shift
  end
  
  def read_boolean
    read_byte == 1
  end

  def read_short
    shift(2, TYPES[:short])
  end

  def read_ushort
    shift(2, TYPES[:ushort])
  end

  def read_string
    size = read_ushort
    shift(size, "A#{size}")
  end
  
  def read_date
    Time.new(read_short, read_byte, read_byte)
  end

  def shift(n, format)
    @bytes.shift(n).pack('C*').unpack1(format)
  end
  
end
