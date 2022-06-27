# frozen_string_literal: true

class Campground
  CampgroundWithName = Struct.new(:id, :name)

  def self.alta_lake
    CampgroundWithName.new(-2_147_483_396, 'Alta Lake')
  end
end
