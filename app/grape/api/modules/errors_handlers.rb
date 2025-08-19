# frozen_string_literal: true

module Api
  module Modules
    module ErrorsHandlers
      extend ActiveSupport::Concern

      included do
        # Handling argument error
        rescue_from ArgumentError do |exception|
          error!(exception.message, 422)
        end

        # Handling argument error
        rescue_from NoMethodError do |exception|
          default_message = 'Something went wrong!'
          default_message += "(#{exception.message})"
          error!(default_message, 422)
        end

        # Handling error unknown format parameter request
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          error_messages = e.errors.map do |field, messages|
            "#{field.join(', ')} #{messages.join(', ')}"
          end.join(', ')

          error!({ error: "Invalid parameters (#{error_messages})" }, 400)
        end
      end
    end
  end
end
