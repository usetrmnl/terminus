# auto_register: false
# frozen_string_literal: true

require "dry/monads"
require "hanami/action"
require "initable"

module Terminus
  # The application base action.
  class Action < Hanami::Action
    handle_exception Dry::Types::SchemaError => :render_enum,
                     ROM::SQL::DatabaseError => :render_out_of_range,
                     ROM::SQL::ForeignKeyConstraintError => :render_foreign_key,
                     ROM::SQL::UniqueConstraintError => :render_duplicate

    include Dry::Monads[:result]

    before :authorize

    protected

    def authorize request, response
      rodauth = request.env["rodauth"]

      return unless rodauth

      rodauth_redirect(rodauth, response) { rodauth.require_account }

      response[:current_user_id] = rodauth.account_id
    end

    def render_duplicate request, response, error
      response.flash.now[:alert] = Aspects::Errors::Finesse.duplicate error.message
      render_errors request, response
    end

    def render_enum request, response, error
      response.flash.now[:alert] = Aspects::Errors::Finesse.enum error.message
      render_errors request, response
    end

    def render_foreign_key request, response, error
      response.flash.now[:alert] = Aspects::Errors::Finesse.foreign_key error.message
      render_errors request, response
    end

    def render_out_of_range request, response, error
      response.flash.now[:alert] = Aspects::Errors::Finesse.out_of_range error.message
      render_errors request, response
    end

    def render_errors(*)
      fail NoMethodError,
           "`#{self.class}##{__method__} #{method(__method__).parameters}` must be implemented."
    end

    private

    def rodauth_redirect rodauth, response
      halted = catch(:halt) { yield }

      return unless halted

      code, headers, body = *halted

      rodauth.flash.next.each { |key, value| response.flash[key] = value }
      response.redirect headers["Location"], code

      throw :halt, [code, body]
    end
  end
end
