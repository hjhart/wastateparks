# frozen_string_literal: true
class CampgroundSearchParameters < Struct.new(:campground_ids, :start_date, :end_date, :party_size, :subequipment_id, :minutes_interval, keyword_init: true)
  def campgrounds
    Campground.for_ids(campground_ids)
  end
end

