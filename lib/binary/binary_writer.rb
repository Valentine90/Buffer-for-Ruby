# Escreve dados binários.
class BinaryWriter < BinaryBase
  def initialize(manual_types: false)
    @manual_types = manual_types
    @formats = '' unless manual_types?
    @binary = []
    @pack = ''
    # Embora a superclasse não precise inicializar seu próprio estado, é
    # uma boa prática chamar o super e faz parte do guia de estilo Ruby.
    super()
  end

  def write(type, data = nil)
    data ||= type
    case data
    when String then write_string(data)
    when Integer then write_int(data, type)
    when Float then write_float(data)
    when Time then write_date(data)
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
    if value >= -128 && value <= 127
      :sbyte
    elsif value > 127 && value <= 255
      :byte
    elsif value >= -32_767 && value <= 32_767
      :short
    elsif value > 32_767 && value <= 65_535
      :ushort
    elsif value >= -2_147_483_647 && value <= 2_147_483_647
      :int
    elsif value > 2_147_483_647 && value <= 4_294_967_295
      :uint
    else
      :long
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
    # Reduz formatos utilizando RegExp quando muitos dados forem escritos no buffer.
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
