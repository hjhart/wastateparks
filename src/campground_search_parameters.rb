# frozen_string_literal: true

CampgroundSearchParameters = Struct.new(:campground, :start_date, :end_date, :party_size, :subequipment_id,
                                        :minutes_interval)
