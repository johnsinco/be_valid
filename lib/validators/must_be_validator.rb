class MustBeValidator < ActiveModel::EachValidator
  MATCHERS = {
    equal_to: :==,
    greater_than: :>,
    greater_or_equal_to: :>=,
    less_than: :<,
    less_or_equal_to: :<=,
    not_equal_to: :!=,
    matching: :=~,
    # one_of: :in?
  }.freeze

  MESSAGE_PREFIX = "must be"
  ERRORS_METHOD = :errors

  def validate_each(record, attribute, value) 
    raise "must_be_validator requires at least one comparison operator for attribute." unless options.slice(MATCHERS.keys + [:blank, :present])

    original_value = record.read_attribute_before_type_cast( attribute )

    message = self.class::MESSAGE_PREFIX.dup

    return if options[:blank] && value.blank?
    message << " blank" if options[:blank]
    return if options[:present] && value.present?
    message << " present" if options[:present]
    return if options[:one_of] && options[:one_of].include?(value)
    message = ": '#{value}' is not a valid value" if options[:one_of]
    return if options[:not_any_of] && !(options[:not_any_of].include?(value))
    message = ": '#{value}' is not a valid value" if options[:not_any_of]
    return if options[:only_from] && (options[:only_from] & Array(value) == Array(value))
    message = ": #{value} is not a valid value" if options[:only_from]

    # handle before and after date comparisons using date validator
    if options[:before] 
      before_resp = DateValidator.new(options.merge(attributes: attributes)).validate_before_option(record, attribute, value, original_value)
      return if before_resp == true
      message = before_resp
    end
    if options[:after] 
      after_resp = DateValidator.new(options.merge(attributes: attributes)).validate_after_option(record, attribute, value, original_value)
      return if after_resp == true
      message = after_resp
    end

    options.slice(*MATCHERS.keys).each do |key, operand|
      operand_msg = operand.to_s
      operand = record.send(operand) if operand.is_a? Symbol
      return if operand.nil?
      return if value&.send(MATCHERS[key], operand)
      message << " #{key.to_s.humanize(capitalize: false)} #{operand_msg}"
    end

    if options[:when].present?
      # check if conditions to validate satisfied
      conditions = options[:when]
      raise "Invalid :when option provided to must_be, must be a Hash or method" unless (conditions.is_a? Hash || conditions.is_a?(Method))
      # add error message with predicate info
      message << " when "
      condition_errors = []
      conditions.each do |field, values|
        case values
        when Regexp
          return if !values.match?(record[field])
        when Array
          return if !values.include?(record[field])
        when Symbol
          return if !record[field].send(values)
        else
          return if values != record[field]
        end
        condition_errors << "#{field} = #{record[field]}"
      end
      message << condition_errors.join(' and ')
    end

    if options[:one_of] && options.fetch(:show_values, true)
      message << ". Valid values: #{options[:one_of].join(', ')}"
    end
    if options[:only_from] && options.fetch(:show_values, true)
      message << ". Valid values: #{options[:only_from].join(', ')}"
    end
    if options[:not_any_of] && options.fetch(:show_values, true)
      message << ". Invalid values: #{options[:not_any_of].join(', ')}"
    end

    record.send(self.class::ERRORS_METHOD).add(attribute, (options[:message] || "#{message}."), rule_name: options[:rule_name])
  end
end
