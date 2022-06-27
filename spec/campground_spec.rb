# frozen_string_literal: true

require_relative '../src/application'
require 'rspec'

RSpec.describe Campground do
  describe 'find' do
    it 'retrieves a campground' do
      dash_point = Campground.find("dash_point")
      expect(dash_point.name).to eq("Dash Point State Park")
      expect(dash_point.id).to eq(:dash_point)
      expect(dash_point.resource_location_id).to eq(-2147483625)
    end
  end
end
