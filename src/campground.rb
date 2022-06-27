# frozen_string_literal: true

class Campground < Struct.new(:id, :resource_location_id, :name, keyword_init: true)
  include YamlModel

end
