require "ostruct"

module Uploadcare
  module Rails
    class Settings < OpenStruct
      include ActiveModel::Validations

      # note that i did not include pub and private key even for demo
      # point here to store them in one place and one place only

      # settings validation (hey, why not? we already have all rails stack loaded :)
      # so just use the godnes of rails magic and praise the lord!
      validates :public_key, :presence => true
      validates :private_key, :presence => true

      def initialize config
        # extract envaroments settings
        settings = config["#{::Rails.env}"]
        raise ArgumentError.new "config is empty or not given at all" unless settings.present?

        # build settings object (basicly openstruct)
        # merge defaults with actual settings

        # strip defaults suplied by uploadcare-ruby gem from private/pub key
        uc_defaults = Uploadcare::DEFAULT_SETTINGS.except!(:public_key, :private_key)
        defaults = Uploadcare::Rails::DEFAULT_SETTINGS.merge!(uc_defaults)
        settings = defaults.merge!(settings)
        super settings

        # validates settings atributes.
        unless valid?
          raise ArgumentError.new "Private or public key options was not provaided"
        end
      end

      def api_settings
        @api_settings ||= build_api_settings
      end

      def widget_settings
        @widget_settings ||= build_widget_settings
      end

      def build_widget_settings
      end

      def build_api_settings
        marshal_dump
      end

      def api
        @api ||= build_api
      end

      def build_api
        Uploadcare::Api.new @api_settings
      end
    end
  end
end