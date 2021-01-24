# frozen_string_literal: true

module BootstrapForm
  module FormGroupBuilder
    extend ActiveSupport::Concern

    private

    def form_group_builder(method, options, html_options=nil)
      no_wrapper = options[:wrapper] == false

      options = form_group_builder_options(options, method)
      form_group_options = form_group_opts(options, method, form_group_css_options(method, html_options.try(:symbolize_keys!), options))
      options.except!(
        :help, :icon, :label_col, :control_col, :add_control_col_class, :layout, :skip_label, :label, :label_class,
        :hide_label, :skip_required, :label_as_placeholder, :wrapper_class, :wrapper, :label_scope
      )
      if no_wrapper
        yield
      else
        form_group(method, form_group_options) { yield }
      end
    end

    def form_group_builder_options(options, method)
      options.symbolize_keys!
      options = convert_form_tag_options(method, options) if acts_like_form_tag
      unless options[:skip_label]
        options[:required] = form_group_required(options) if options.key?(:skip_required)
      end
      options
    end

    def convert_form_tag_options(method, options={})
      unless @options[:skip_default_ids]
        options[:name] ||= method
        options[:id] ||= method
      end
      options
    end

    def form_group_opts(options, method, css_options)
      wrapper_options = options[:wrapper]
      form_group_options = {
        id: options[:id], help: options[:help], icon: options[:icon],
        label_col: options[:label_col], control_col: options[:control_col],
        add_control_col_class: options[:add_control_col_class],
        layout: get_group_layout(options[:layout]), class: options[:wrapper_class]
      }

      form_group_options.merge!(wrapper_options) if wrapper_options.is_a?(Hash)
      form_group_options[:label] = form_group_label(options, method, css_options) unless options[:skip_label]
      form_group_options
    end

    def form_group_label(options, method, css_options)
      hash = {
        text: form_group_label_text(options[:label], method, options[:label_scope]),
        class: form_group_label_class(options),
        required: options[:required]
      }.merge(css_options[:id].present? ? { for: css_options[:id] } : {})
      hash
    end

    def form_group_label_text(label, method, label_scope)
      text = label[:text] if label.is_a?(Hash)
      text ||= label if label.is_a?(String)
      text ||= I18n.translate(method, scope: label_scope) if label_scope.present?
      text
    end

    def form_group_label_class(options)
      return hide_class if options[:hide_label] || options[:label_as_placeholder]

      classes = options[:label][:class] if options[:label].is_a?(Hash)
      classes ||= options[:label_class]
      classes
    end

    def form_group_required(options)
      return unless options.key?(:skip_required)

      warn "`:skip_required` is deprecated, use `:required: false` instead"
      options[:skip_required] ? false : :default
    end

    def form_group_css_options(method, html_options, options)
      css_options = html_options || options
      # Add control_class; allow it to be overridden by :control_class option
      control_classes = css_options.delete(:control_class) { control_class }
      # Add class values from options and html_options
      classes = [control_classes]
      classes << html_options[:class] if html_options
      classes << options[:class] if options
      classes << 'is-invalid' if error?(method)
      css_options[:class] = classes.compact.join(" ")
      css_options[:placeholder] = form_group_placeholder(options, method) if options[:label_as_placeholder]
      css_options
    end

    def form_group_placeholder(options, method)
      form_group_label_text(options[:label]) || object.class.human_attribute_name(method)
    end
  end
end
