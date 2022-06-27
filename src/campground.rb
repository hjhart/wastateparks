class Campground
  class CampgroundWithName < Struct.new(:id, :name)
  end

  def self.alta_lake
    CampgroundWithName.new(-2147483396, 'Alta Lake')
  end
end
