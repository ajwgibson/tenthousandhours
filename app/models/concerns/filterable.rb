module Filterable

  extend ActiveSupport::Concern

  module ClassMethods

    def filter(filtering_params)
      results = self.where(nil)
      filtering_params.each do |key, value|
        results = results.public_send(key, value) if value.present?
      end
      results
    end

    def order_by(value)
      clause = (value.split(',').map { |x| x + " nulls first" }).join(",") unless value.include?('desc')
      clause = (value.split(',').map { |x| x + " nulls last" }).join(",") if value.include?('desc')
      order(clause)
    end
    
  end

end
