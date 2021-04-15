class DateValidator < ActiveModel::EachValidator

  # https://stackoverflow.com/questions/28538080/rails-validate-dates-in-model-before-type-cast

  def validate_each(record, attribute, value)

    @error_hash = options[:error_level].present? ? record.send(options[:error_level]) : record.errors

    original_value = record.read_attribute_before_type_cast( attribute )
    # dont display date format error unless date could not be parsed
    if value.nil?
      # if blank date was given it's still not a format issue, still show message if desired
      return if original_value.blank? && options[:allow_blank]

      # display helpful date format validation message with original value
      message = options[:time] ?  ": #{original_value} is not a valid value. Value must be a date in YYYY-MM-DD or YYYY-MM-DD HH:MM:SS format." : ": #{original_value} is not a valid value. Value must be a date in YYYY-MM-DD."
      @error_hash.add(attribute, (options[:message] || message))
    else
      # handle validation options on valid date instances
      return unless value.respond_to?(:strftime)
      if(options[:after] && (after_message = validate_after_option(record, attribute, value, original_value)) != true)
        @error_hash.add(attribute, (options[:after_message] || "#{after_message}."))
      end
      if(options[:before] && (before_message = validate_before_option(record, attribute, value, original_value)) != true)
        @error_hash.add(attribute, (options[:before_message] || "#{before_message}."))
      end
    end
  end

  def validate_after_option(record, attribute, value, original_value)
    date, value = date_for(record, value, options[:after])
    return true unless date.present?
    return true if value.present? && date.present? && (value && date && value >= date)

    after_message = ": #{original_value} is not a valid value."
    if options[:after] == :now || options[:after] == :today
      after_message << " Date cannot be in the past"
    elsif options[:after].respond_to?(:strftime)
      after_message << " Date cannot be before #{options[:after]}"
    elsif options[:after].is_a? Proc
      after_message << " Date cannot be before #{options[:after].call(record)}"
    elsif record.respond_to?(options[:after])
      after_message << " Date cannot be before #{options[:after]}"
    end
    after_message
  end

  def validate_before_option(record, attribute, value, original_value)
    date, value = date_for(record, value, options[:before])
    return true unless date.present?
    return true if value.present? && date.present? && (value && date && value <= date)

      before_message = ": #{original_value} is not a valid value."
      if options[:before] == :now || options[:before] == :today
        before_message << " Date cannot be in the future" 
      elsif options[:before].respond_to?(:strftime)
        before_message << " Date cannot be after #{options[:before]}"
      elsif options[:before].is_a? Proc
        before_message << " Date cannot be after #{options[:before].call(record)}"
      elsif record.respond_to?(options[:before])
        before_message << " Date cannot be after #{options[:before]}"
      end
      before_message
  end

  # source: https://github.com/fnando/validators/blob/main/lib/validators/validates_datetime.rb
  def date_for(record, value, option)
    date = case option
           when :today
             Date.today
           when :now
             Time.now + 60  # be lenient on now for server clocks
           when Time, Date, DateTime, ActiveSupport::TimeWithZone
             option
           when Proc
             option.call(record)
           else
             record.__send__(option) if record.respond_to?(option)
           end
    return unless date.present?
    date = date.to_date unless options[:time]
    if date.is_a?(Time)
      value = value.to_time
    elsif date.is_a?(Date)
      value = value.to_date
    end
    [date, value]
  end

end
