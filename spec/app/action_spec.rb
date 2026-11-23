# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Action do
  subject(:action) { implementation.new }

  describe "#call" do
    let :errors do
      YAML.load_file SPEC_ROOT.join("support/fixtures/errors.yml"), symbolize_names: true
    end

    context "with duplicate error" do
      let :implementation do
        message = errors.fetch :duplicate

        Class.new described_class do
          protected

          define_method :handle do |*|
            fail ROM::SQL::UniqueConstraintError, StandardError.new(message)
          end

          def render_errors(*) = nil
        end
      end

      it "answers problem details" do
        response = action.call Hash.new
        expect(response.flash[:alert]).to include("must be unique")
      end
    end

    context "with enum error" do
      let :implementation do
        message = errors.fetch :enum

        Class.new described_class do
          protected

          define_method :handle do |*|
            fail Dry::Types::SchemaError.new(:mode, "other", message)
          end

          def render_errors(*) = nil
        end
      end

      it "answers problem details" do
        response = action.call Hash.new
        expect(response.flash[:alert]).to include("Invalid value for mode")
      end
    end

    context "with foreign key error" do
      let :implementation do
        message = errors.fetch :foreign_key

        Class.new described_class do
          protected

          define_method :handle do |*|
            fail ROM::SQL::ForeignKeyConstraintError, StandardError.new(message)
          end

          def render_errors(*) = nil
        end
      end

      it "answers problem details" do
        response = action.call Hash.new
        expect(response.flash[:alert]).to include("Invalid `playlist_id`")
      end
    end

    context "with numeric out of range error" do
      let :implementation do
        message = errors.fetch :out_of_range

        Class.new described_class do
          protected

          define_method :handle do |*|
            fail ROM::SQL::DatabaseError, StandardError.new(message)
          end

          def render_errors(*) = nil
        end
      end

      it "answers problem details" do
        response = action.call Hash.new
        expect(response.flash[:alert]).to include("Integer out of range")
      end
    end

    context "when rendering errors" do
      let :implementation do
        Class.new described_class do
          protected

          def handle(*) = render_errors(*)
        end
      end

      it "fails when not implemented" do
        expectation = proc { action.call Hash.new }
        expect(&expectation).to raise_error(NoMethodError, /must be implemented/)
      end
    end
  end
end
