# frozen_string_literal: true

module BootstrapForm
  module Inputs
    module RadioButton
      extend ActiveSupport::Concern
      include Base

      included do
        def radio_button_with_bootstrap(name, value, *args)
          options = args.extract_options!.symbolize_keys!
          radio_button_options = options.except(:class, :label, :label_class, :error_message, :help,
                                                :inline, :custom, :hide_label, :skip_label, :wrapper_class,
                                                :label_scope, :title_scope, :translate_params)

          radio_button_options[:class] = radio_button_classes(name, options)

          content_tag(:div, class: radio_button_wrapper_class(options), title: radio_button_wrapper_title(name, value, options)) do
            html = radio_button_without_bootstrap(name, value, radio_button_options)
            html.concat(radio_button_label(name, value, options)) unless options[:skip_label]
            html.concat(generate_error(name)) if options[:error_message]
            html
          end
        end

        bootstrap_alias :radio_button
      end

      private

      def radio_button_label(name, value, options)
        label_options = { value: value, class: radio_button_label_class(options) }
        label_options[:for] = options[:id] if options[:id].present?
        label(name, radio_button_description(name, options, value), label_options)
      end

      def radio_button_description(name, options, value)
        options.delete(:label) do
          if options[:label_scope]
            translate_by_i18n_key name, value, options[:label_scope], options[:translate_params]
          end
        end
      end

      def radio_button_classes(name, options)
        classes = [options[:class]]
        classes << (options[:custom] ? "custom-control-input" : "form-check-input")
        classes << "is-invalid" if error?(name)
        classes << "position-static" if options[:skip_label] || options[:hide_label]
        classes.flatten.compact
      end

      def radio_button_label_class(options)
        classes = []
        classes << (options[:custom] ? "custom-control-label" : "form-check-label")
        classes << options[:label_class]
        classes << hide_class if options[:hide_label]
        classes.flatten.compact
      end

      def radio_button_wrapper_class(options)
        classes = []
        classes << if options[:custom]
                     custom_radio_button_wrapper_class(options)
                   else
                     standard_radio_button_wrapper_class(options)
                   end
        classes << options[:wrapper_class] if options[:wrapper_class].present?
        classes.flatten.compact
      end

      def standard_radio_button_wrapper_class(options)
        classes = %w[form-check]
        classes << "form-check-inline" if layout_inline?(options[:inline])
        classes << "disabled" if options[:disabled]
        classes
      end

      def custom_radio_button_wrapper_class(options)
        classes = []
        classes << 'custom-control'
        classes << (options[:custom] == true ? 'custom-radio' : "custom-#{options[:custom]}")
        classes << 'custom-control-inline' if layout_inline?(options[:inline])
        classes
      end

      def radio_button_wrapper_title(name, value, options)
        if options[:title_scope]
          translate_by_i18n_key name, value, options[:title_scope], options[:translate_params]
        end
      end
    end
  end
end
