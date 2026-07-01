# auto_register: false
# frozen_string_literal: true

require "rodauth"

Rodauth::Feature.define :hanami do
  auth_value_method :hanami_view, nil

  def view(name, *)
    configuration = view_base.config
    layout_path = Pathname(configuration.layouts_dir).join configuration.layout
    scope = view_rendering.scope rodauth: self

    view_rendering.template(layout_path, scope) { render name }
  end

  def render name
    return super unless view_template? name

    view_rendering.template name, view_rendering.scope(rodauth: self)
  end

  private

  def view_template? name
    # rubocop:todo Style/SendWithLiteralMethodName
    view_rendering.renderer.__send__ :lookup, name, view_base.config.default_format
    # rubocop:enable Style/SendWithLiteralMethodName
  end

  def view_rendering
    @view_rendering ||= view_base.rendering format: view_base.config.default_format,
                                            context: view_context
  end

  def view_context
    @view_context ||= begin
                        action_request = Hanami::Action::Request.new(
                          env: request.env,
                          params: request.params,
                          session_enabled: true
                        )

                        view_base.config.default_context.class.new request: action_request
                      end
  end

  def view_base
    @view_base ||= hanami_view.call
  end
end
