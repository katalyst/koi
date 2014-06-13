module Reports
 
  class Overview

    attr_accessor :span, :field, :strategy, :name, :scope, :period, :current_value, :previous_value,
                  :prefix, :postfix

    def initialize(report, klass)
      @span       = report[:span]
      @field      = report[:field]
      @strategy   = report[:strategy]
      @period     = report[:period]
      @name       = report[:name]
      @prefix     = report[:prefix]
      @postfix    = report[:postfix]
      scope       = report[:scope] || :scoped

      time_range = Hash.new
      time_range[span] = current_date_range
      @current_value   = calculate(klass.send(scope).where(time_range))
      time_range[span] = previous_date_range
      @previous_value  = calculate(klass.send(scope).where(time_range))
    end

    def process
      {
        name:            name, 
        current_value:   "#{prefix}#{@current_value}#{postfix}",
        percent_change:  percent_change,
        change_type:     change_type,
        class:          'overview'
      }
    end

    def name
      @name || "#{@field} #{@strategy} #{@period}"
    end

    def renderer
      @renderer || 'line'
    end

    def span
      @span || :created_at
    end

    def strategy
      @strategy || :count
    end

    def period
      @period || :monthly
    end

    def prefix
      @prefix || ''
    end

    def postfix
      @postfix || ''
    end

  private

    def calculate(ar_scope)
      case strategy
      when :sum
        ar_scope.send(:sum, &field)
      when :count
        ar_scope.count
      else
        raise 'Strategy not supported. Please use :sum or :count'
      end
    end

    def percent_change
      return nil if @previous_value == 0
      change = @current_value - @previous_value * 1.0
      change / @previous_value * 100.0
    rescue
      nil
    end

    def change_type
      return '' unless percent_change
      percent_change >= 0.0 ? 'increase' : 'decrease'
    end

    def current_date_range
      (Date.today - 1.day - period_days)..(Date.today - 1.day)
    end

    def previous_date_range
      (Date.today - 1.day - period_days - period_days)..(Date.today - 1.day - period_days)
    end

    def period_days
      case period
      when :weekly    then 7.days
      when :monthly   then 1.month
      when :quarterly then 3.months
      when :yearly    then 1.year
      else
        1.day
      end
    end

  end
end
