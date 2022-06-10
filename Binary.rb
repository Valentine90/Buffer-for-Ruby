#==============================================================================
# ** Binary
#------------------------------------------------------------------------------
#  Esta classe lê e escreve dados binários.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Binary

  TYPE = {
    :byte => 'c',
    :short => 's',
    :int => 'i',
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
      @pack = "#{TYPE[:short]}#{TYPE[:byte] * @formats.size}#{@pack}"
    end
    @binary.pack(@pack)
  end
  
  private

  def write_int(value, type)
    type = type.is_a?(Symbol) ? type : auto_int_type(value)
    push(value, type)
    @formats << TYPE[type] unless manual_types?
  end
  
  def auto_int_type(value)
    if value >= 0 && value <= 255; :byte
    elsif value >= -32_767 && value <= 32_767; :short
    elsif value >= -2_147_483_647 && value <= 2_147_483_647; :int
    else; :long
    end
  end

  def write_float(value)
    push(value, :float)
    @formats << TYPE[:float] unless manual_types?
  end
  
  def write_boolean(value)
    push(value ? 1 : 0, :byte)
    @formats << TYPE[:boolean] unless manual_types?
  end
  
  def write_string(str)
    push(str.bytesize, :short)
    str.each_byte { |c| push(c, :byte) }
    @formats << TYPE[:string] unless manual_types?
  end

  def write_date(time)
    push(time.year, :short)
    push(time.month, :byte)
    push(time.day, :byte)
    @formats << TYPE[:date] unless manual_types?
  end

  def manual_types?
    @manual_types
  end
  
  def push(value, type)
    @binary << value
    @pack << TYPE[type]
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
           when TYPE[:byte], :byte; read_byte
           when TYPE[:boolean], :boolean; read_boolean
           when TYPE[:short], :short; read_short
           when TYPE[:float], :float; shift(4, TYPE[:float])
           when TYPE[:int], :int; shift(4, TYPE[:int])
           when TYPE[:long], :long; shift(8, TYPE[:long])
           when TYPE[:string], :string; read_string
           when TYPE[:date], :date; read_date
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
    shift(2, TYPE[:short])
  end

  def read_string
    size = read_short
    shift(size, "A#{size}")
  end
  
  def read_date
    Time.new(read_short, read_byte, read_byte)
  end

  def shift(n, format)
    @bytes.shift(n).pack('C*').unpack1(format)
  end
  
end
