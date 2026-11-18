# auto_register: false
# frozen_string_literal: true

module Terminus
  module Schemas
    module Models
      # Defines import schema.
      Import = Dry::Schema.Params do
        required(:version).filled Types::Version
        required(:label).filled :string
        required(:name).filled :string
        optional(:description).maybe :string
        optional(:kind).filled :string
        optional(:mime_type).filled :string
        optional(:colors).filled :integer
        optional(:bit_depth).filled :integer
        optional(:rotation).filled :integer
        optional(:offset_x).filled :integer
        optional(:offset_y).filled :integer
        optional(:scale_factor).filled :float
        optional(:width).filled :integer
        optional(:height).filled :integer
        optional(:css).maybe :hash
        optional(:default_palette_name).maybe :string
      end
    end
  end
end
