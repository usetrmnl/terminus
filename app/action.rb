# auto_register: false
# frozen_string_literal: true

require "dry/monads"
require "hanami/action"
require "initable"

module Terminus
  # The application base action.
  class Action < Hanami::Action
    include Dry::Monads[:result]

    before :authorize

    protected

    def authorize request, response
      rodauth = request.env["rodauth"]

      return unless rodauth

      handle_rodauth_redirect(rodauth, response) { rodauth.require_account }

      response[:current_user_id] = rodauth.account_id
    end

    private

    def handle_rodauth_redirect rodauth, response
      halted = catch(:halt) { yield }

      return unless halted

      code, headers, body = *halted

      rodauth.flash.next.each { |key, value| response.flash[key] = value }
      response.redirect headers["Location"], code

      throw :halt, [code, body]
    end
  end
end
