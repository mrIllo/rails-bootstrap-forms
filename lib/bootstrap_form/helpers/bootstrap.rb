module BootstrapForm
  module Helpers
    module Bootstrap

      def form_link(path, name_or_hash, options = {})
        options.symbolize_keys!
        if name_or_hash.is_a?(Hash)
          name_or_hash.symbolize_keys!
          if name_or_hash[:anchor_text].present?
            anchor_text = name_or_hash[:anchor_text]
          elsif (key = name_or_hash[:translate]).present?
            params = name_or_hash.except(:translate, :anchor_text)
            anchor_text = translate(".link.anchor_text.#{key}", **params)
            options[:title] ||= translate(".link.title.#{key}", **params)
          end
        else
          anchor_text ||= translate(".link.anchor_text.#{name_or_hash}")
          options[:title] ||= translate(".link.title.#{name_or_hash}")
        end

        form_group { ActionController::Base.helpers.link_to(anchor_text, path, options) }
      end

      def alert_message(title, options = {})
        css = options[:class] || 'alert alert-danger'

        if object.respond_to?(:errors) && object.errors.full_messages.any?
          content_tag :div, class: css do
            concat content_tag :p, title
            concat error_summary unless options[:error_summary] == false
          end
        end
      end

      def error_summary
        content_tag :ul, class: 'rails-bootstrap-forms-error-summary' do
          object.errors.full_messages.each do |error|
            concat content_tag(:li, error)
          end
        end
      end

      def errors_on(name, options = {})
        if has_error?(name)
          hide_attribute_name = options[:hide_attribute_name] || false

          content_tag :div, class: "alert alert-danger" do
            if hide_attribute_name
              object.errors[name].join(", ")
            else
              object.errors.full_messages_for(name).join(", ")
            end
          end
        end
      end

      def static_control(*args, &block)
        options = args.extract_options!
        name = args.first

        html = if block_given?
          capture(&block)
        else
          object.send(name)
        end

        form_group_builder(name, options) do
          content_tag(:p, html, class: static_class)
        end
      end

      def custom_control(*args, &block)
        options = args.extract_options!
        name = args.first

        form_group_builder(name, options, &block)
      end

      def prepend_and_append_input(options, &block)
        options = options.extract!(:prepend, :append, :input_group_class, :skip_input_group)
        input_group_class = ['input-group', options[:input_group_class]].compact.join(' ')

        input = capture(&block)
        prepend = options[:prepend] || ''
        prepend = content_tag(:span, prepend, class: input_group_class(options[:prepend])) if options[:prepend] and not options[:skip_input_group]
        append = options[:append] || ''
        append = content_tag(:span, append, class: input_group_class(options[:append])) if options[:append] and not options[:skip_input_group]
        if prepend.present? or append.present?
          input = prepend + input + append
          input = content_tag(:div, input.html_safe, class: input_group_class) unless options[:skip_input_group]
        end

        input
      end

      def input_group_class(add_on_content)
        if add_on_content.match(/btn/)
          'input-group-btn'
        else
          'input-group-addon'
        end
      end

      def static_class
        'form-control-static'
      end
    end
  end
end
