# frozen_string_literal: true

module BootstrapForm
  module Inputs
    module Select
      extend ActiveSupport::Concern
      include Base

      included do
        def select_with_bootstrap(method, choices=nil, options={}, html_options={}, &block)
          form_group_builder(method, options, html_options) do
            prepend_and_append_input(method, options) do
              html_options = translated_options_from_i18n_scope(method, options, html_options)
              # special use case for placeholders in select
              if (placeholder = html_options.delete(:placeholder)).present?
                choices.unshift([placeholder, nil]) if choices.respond_to?(:unshift)
              end
              select_without_bootstrap(method, choices, options, html_options, &block)
            end
          end
        end

        bootstrap_alias :select
      end
    end
  end
end
