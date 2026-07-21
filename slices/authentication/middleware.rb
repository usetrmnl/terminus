# auto_register: false
# frozen_string_literal: true

require "roda"
require "rodauth"
require "omniauth"
require "omniauth_openid_connect"

require_relative "feature"

module Authentication
  # Specialized Roda middleware for authentication.
  # simplecov:disable
  class Middleware < Roda
    UNVERIFIED_ID = 1
    VERIFIED_ID = 2

    plugin :middleware

    plugin :rodauth, json: true do
      settings = Hanami.app[:settings]
      oidc_enabled = %w[oidc hybrid].include?(settings.auth_mode)
      oidc_only = settings.auth_mode == "oidc"

      # :login (and password auth) stays enabled in EVERY mode: the break-glass admin
      # and the /api JSON-login -> JWT management flow both depend on it. :create_account
      # is dropped only in pure "oidc" mode (self-registration off, route absent).
      # :omniauth is added only when OIDC is enabled.
      features = %i[
        active_sessions
        audit_logging
        change_login
        change_password
        disallow_common_passwords
        hanami
        jwt_refresh
        login
        logout
        remember
        recovery_codes
      ]
      features << :create_account unless oidc_only
      features << :omniauth if oidc_enabled

      enable(*features)

      enable :session_expiration if settings.session_expiration_enabled

      db Authentication::Slice["db.gateway"].connection

      # Feature (automatic): base
      accounts_table :user
      after_login { remember_login }
      already_logged_in { redirect "/" }
      flash_error_key :alert
      hmac_secret Hanami.app[:settings].app_secret
      login_label "Email"
      password_hash_table :user_password_hash
      require_login_error_flash "Please log in to continue."
      template_opts layout: nil
      unverified_account_message "Unverified user, please verify before logging in."

      after_login do
        unless account[:status_id] == VERIFIED_ID
          logout
          set_redirect_error_flash "Your account requires verification before proceeding. " \
                                   "Please contact administration for access."
          redirect "/login"
        end
      end

      # Feature (automatic): login_password_requirements_base
      require_password_confirmation? false

      # Feature: active_sessions
      active_sessions_account_id_column :user_id
      active_sessions_table :user_active_session_key

      # Feature: audit_logging
      audit_logging_table :user_authentication_audit_log
      audit_logging_account_id_column :user_id

      # Feature: change_login
      change_login_route "me/login"
      change_login_view { view "login_update", nil }

      # Feature: change_password
      change_password_route "me/password"
      change_password_view { view "password_update", nil }
      change_password_button "Save"

      # Feature: create_account (config methods exist only while :create_account is
      # enabled, i.e. every mode except "oidc").
      unless oidc_only
        create_account_button "Create"
        create_account_link_text "Register."
        create_account_route "register"
        create_account_view { view "register", nil }
      end
      change_login_button "Save"

      # Single provisioning path shared by native (after_create_account) and OIDC
      # (after_omniauth_create_account) account creation, so the two cannot diverge.
      # Sets the user's name + verification status, upserts the "default" account, and
      # inserts the membership. Removing this body breaks BOTH creation paths.
      auth_class_eval do
        def provision_account(user_id:, name:, verified:)
          status_id = verified ? VERIFIED_ID : UNVERIFIED_ID
          account_id = db[:account].insert_conflict(target: :name, update: {name: "default"})
                                   .insert(name: "default", label: "Default")

          db[:user].where(id: user_id).update(name:, status_id:)
          db[:membership].insert(user_id:, account_id:)

          status_id
        end
      end

      # Native account creation hook exists only while :create_account is enabled.
      unless oidc_only
        after_create_account do
          status_id = provision_account(user_id: account[:id], name: param("name"), verified: db[:user].one?)

          unless status_id == VERIFIED_ID
            logout
            set_redirect_error_flash "Your account requires verification before proceeding. " \
                                     "Please contact administration for access."
            redirect "/login"
          end
        end
      end

      if oidc_enabled
        omniauth_provider :openid_connect,
                          name: :openid_connect,
                          issuer: settings.oidc_issuer,
                          discovery: true,
                          pkce: true,
                          scope: settings.oidc_scopes.split,
                          client_options: {
                            identifier: settings.oidc_client_id,
                            secret: settings.oidc_client_secret,
                            redirect_uri: "#{settings.app_origin}/auth/openid_connect/callback"
                          }

        # Bind identities to (provider, uid=sub) in the user_identity table.
        omniauth_identities_table :user_identity
        omniauth_identities_account_id_column :user_id

        # Never resolve an existing account by the OIDC email: accounts are matched by
        # the user_identity row ONLY. Email-based linking is account takeover (a verified
        # OIDC email must not be able to adopt a local account). In rodauth-omniauth 0.6.2
        # this empty block redefines the underscore impl `_account_from_omniauth` to return
        # nil, so `account_from_omniauth` sets @account = nil and the callback falls through
        # to identity-only resolution/creation (never `_account_from_login(email)`).
        account_from_omniauth {}

        before_omniauth_callback_route do
          info = omniauth_info || {}

          if omniauth_email
            # Require a provider-verified email whenever the email claim is used.
            email_verified = info["email_verified"]
            unless email_verified == true || email_verified == "true"
              set_redirect_error_flash "Your identity provider has not verified your email address."
              redirect omniauth_login_failure_redirect
            end

            # Belt-and-suspenders on top of account_from_omniauth: the break-glass local
            # admin is never auto-provisioned or linked through OIDC.
            break_glass = settings.oidc_break_glass_email
            if !break_glass.empty? && omniauth_email.casecmp?(break_glass)
              set_redirect_error_flash "This account must sign in with a password."
              redirect omniauth_login_failure_redirect
            end
          end
        end

        # OIDC users are Verified by policy: the identity provider has already
        # authenticated them and enforced its access policy for this client, so it is the
        # access authority. The native `db[:user].one?` first-user rule does NOT apply (the
        # break-glass user already exists, so an OIDC user would otherwise land Unverified).
        after_omniauth_create_account do
          provision_account(user_id: account[:id], name: omniauth_name, verified: true)
        end
      end

      # Feature (custom): hanami
      hanami_view(proc { View.new })

      # Feature: jwt
      jwt_secret Hanami.app[:settings].app_secret
      jwt_refresh_route "api/jwt"

      # Feature: jwt_refresh
      period = if Hanami.app[:settings].session_expiration_enabled
                 Hanami.app[:settings].api_access_token_period
               else
                 3_155_760_000 # 100 years in seconds.
               end

      jwt_access_token_period period
      jwt_refresh_token_account_id_column :user_id
      jwt_refresh_token_table :user_jwt_refresh_key

      # Feature: login
      login_error_flash "There was an error signing in."
      login_form_footer_links_heading { nil }
      login_notice_flash "You have been logged in."
      login_return_to_requested_location? true
      multi_phase_login_view { view "login_multi_phase", nil }

      # Feature: logout
      logout_notice_flash "You have been logged out."
      logout_redirect "/"

      # Feature: remember
      remember_button "Save"
      remember_table :user_remember_key
      remember_route "me/remember"

      # Feature: recovery_codes
      recovery_codes_table :user_recovery_code

      # Feature: session_expiration
      if Hanami.app[:settings].session_expiration_enabled
        session_inactivity_timeout Hanami.app[:settings].session_inactivity_limit
        max_session_lifetime Hanami.app[:settings].session_lifetime_limit
      else
        Hanami.app[:logger].warn { "Rodauth session expiration is disabled." }
      end
    end

    route do |request|
      rodauth.check_session_expiration if Hanami.app[:settings].session_expiration_enabled
      env["rodauth"] = rodauth
      request.rodauth
    end
  end
  # simplecov:enable
end
