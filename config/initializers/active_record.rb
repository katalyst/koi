class DateTimeWithOffset < ActiveModel::Type::DateTime
  def value_from_multiparameter_assignment(values)
    # super does not validate time or offset fields. 4 = hour, 5 = minute, 8 = offset
    missing_parameters = [4, 5, 8].select { |key| !values.key?(key) || values[key].nil? }
    if missing_parameters.any?
      return nil
    end

    # rescue nil conceals many possible sins, but is essential as there is no clean way to validate and return useful errors
    # for the individual date components. This allows a higher level validator to look at the reconstituted field.
    # rubocop:disable Style/RescueModifier
    super(values.reverse_merge(6 => 0, 7 => 0)).change(offset: values[8]) rescue nil
    # rubocop:enable Style/RescueModifier
  end

end

ActiveRecord::Type.register(:date_time_with_offset, DateTimeWithOffset)
