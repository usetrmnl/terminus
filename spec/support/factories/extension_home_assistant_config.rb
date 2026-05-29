# frozen_string_literal: true

Factory.define :extension_home_assistant_config,
               relation: :extension_home_assistant_config do |factory|
  factory.association :extension
  factory.source_mode "entity"
  factory.entity_ids ["media_player.sonos_roam"]
  factory.endpoint_path nil
  factory.attribute_map Hash.new
  factory.normalize_urls true
end
