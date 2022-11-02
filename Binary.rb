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
      @pack = "#{TYPES[:ushort]}#{TYPES[:byte]}#{@formats.bytesize}#{@pack}"
    end
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

  def manual_types?
    @manual_types
  end
  
  def push(type, value)
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
           when TYPES[:float], :float; shift(TYPES[:float], 4)
           when TYPES[:int], :int; shift(TYPES[:int], 4)
           when TYPES[:uint], :uint; shift(TYPES[:uint], 4)
           when TYPES[:long], :long; shift(TYPES[:long], 8)
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
    shift(TYPES[:short], 2)
  end

  def read_ushort
    shift(TYPES[:ushort], 2)
  end

  def read_string
    bytesize = read_ushort
    shift("A#{bytesize}", bytesize)
  end
  
  def read_date
    Time.new(read_short, read_byte, read_byte)
  end

  def shift(format, n)
    @bytes.shift(n).pack('C*').unpack1(format)
  end
  
end
