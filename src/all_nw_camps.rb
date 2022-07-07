require_relative './application'
require 'rack'

campgrounds = Campground.all

campgrounds.each { |camp| 
  query = Rack::Utils.build_query({saddr: "1911 18th ave s 98144", daddr: camp.name})
  directions_url = URI::HTTPS.build(host: "maps.google.com", path: "/maps", query: query)
  puts directions_url
}

# Alta Lake Campground 0:24
# Anderson Lake 1:59
# Griffiths Praday 2:59
# Lake Sammamish,            0:18
# Saltwater,                 0:27
# Dash Point,                0:35
# Flaming Geyser,            0:53
# Nolte                     0:53
# Federation forest          1:13
# Belfair                1:18 minutes
# Bay View                1:26
# Scenic Beach              1:33 minutes
# Twanoh                    1:33
# Schafer                   1:53
# Birch Bay                 1:58
# Fort Townsend               2:01
# Jarrel Cove               2:25
# Blake Island               Only by boat.
# Peace Arch                2:02
# Dosewallups               2:21
# Deception Pass            1:33



