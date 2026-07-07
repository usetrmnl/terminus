# auto_register: false
# frozen_string_literal: true

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          # Defines import schema.
          Schema = Dry::Schema.Params do
            optional(:custom_fields).array(:hash)
            required(:dark_mode).filled :bool
            required(:id).filled :integer
            required(:name).filled :string
            optional(:oauth_auth_params).maybe :string
            optional(:oauth_authorization_method).maybe :string
            optional(:oauth_authorize_url).maybe :string
            optional(:oauth_body_format).maybe :string
            optional(:oauth_enabled).filled :bool
            optional(:oauth_expiry_field_name).maybe :string
            optional(:oauth_expiry_strategy).maybe :string
            optional(:oauth_fixed_expiry_ms).maybe :integer
            optional(:oauth_pkce_enabled).filled :bool
            optional(:oauth_refresh_params).maybe :string
            optional(:oauth_refresh_url).maybe :string
            optional(:oauth_scope_separator).maybe :string
            optional(:oauth_scopes).maybe :string
            optional(:oauth_token_field_name).maybe :string
            optional(:oauth_token_headers).maybe :string
            optional(:oauth_token_params).maybe :string
            optional(:oauth_token_request_auth_method).maybe :string
            optional(:oauth_token_response_metadata).maybe :string
            optional(:oauth_token_site).maybe :string
            optional(:oauth_token_url).maybe :string
            required(:polling_body).maybe :hash
            required(:polling_headers).maybe :hash
            required(:polling_url).maybe :string
            required(:polling_verb).filled :string
            required(:refresh_interval).filled :integer
            required(:serverless_language).maybe :string
            required(:static_data).maybe :hash
            required(:strategy).filled :string

            after(:value_coercer, &Schemas::Coercers::JSONToHash.curry[:polling_body])
            after(:value_coercer, &Schemas::Coercers::URIQueryToHash.curry[:polling_headers])
            after(:value_coercer, &Schemas::Coercers::JSONToHash.curry[:static_data])
          end
        end
      end
    end
  end
end
