# frozen_string_literal: true

module BootstrapForm
  module Components
    module Validation
      extend ActiveSupport::Concern

      private

      def error?(name)
        object.respond_to?(:errors) && !(name.nil? || object.errors[name].empty?)
      end

      def required_attribute?(obj, attribute)
        return false unless obj && attribute

        target = obj.class == Class ? obj : obj.class

        target_validators = if target.respond_to? :validators_on
                              target.validators_on(attribute).map(&:class)
                            else
                              []
                            end

        presence_validator?(target_validators)
      end

      def presence_validator?(target_validators)
        has_presence_validator = target_validators.include?(
          ActiveModel::Validations::PresenceValidator
        )

        if defined? ActiveRecord::Validations::PresenceValidator
          has_presence_validator |= target_validators.include?(
            ActiveRecord::Validations::PresenceValidator
          )
        end

        has_presence_validator
      end

      def inline_error?(name)
        error?(name) && inline_errors
      end

      def generate_error(name)
        return unless inline_error?(name)

        help_text = get_error_messages(name)
        help_klass = "invalid-feedback"
        help_tag = :div

        content_tag(help_tag, help_text, class: help_klass)
      end

      def get_error_messages(name, hide_attribute_name = true)
        return object.errors[name].join(", ") if hide_attribute_name

        # replace first error message with full text version of it
        # and then let Rails build a sentence
        errors = [].concat(object.errors[name])
        errors[0] = object.errors.full_messages_for(name).first
        msg = errors.to_sentence
        # add a dot if string does not already end with one of the chars !, ? or .
        /[!.?]/.match(msg[-1, 1]).nil? ? "#{msg}." : msg
      end

    end
  end
end
