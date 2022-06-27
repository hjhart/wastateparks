require 'kimurai'  
campgrounds = ["Bogachiel​
  Fort Townsend​", "Jarrell Cove​", "Saltwater​", "Schafer​", "Blake Island​", "Federation Forest​", "Flaming Geyser​", "Lake Sammamish​", "Nolte​", "Peace Arch​", "Twanoh​", "Bay View​", "Birch Bay​", "Dash Point​", "Dosewallips​", "Deception Pass​
  Fort Casey​
  Fort Ebey​
  Fort Flagler​
  Fort Worden​
  Illahee​
  Kanaskat-Palmer​
  Kitsap Memorial​
  Lake Easton​
  Lake Wenatchee​
  Larrabee​
  Manchester​
  Ocean City​
  Pacific Beach​
  Penrose Point​
  Rasar​
  Scenic Beach​
  Sequim Bay​
  South Whidbey​
  Spencer Spit​
  Wallace Falls​
  Potlatch​
  Belfair​
  Moran​
  Sucia Island​
  Rockport​
  Tolmie​
  Griffiths-Priday​
  Posey Island​
  Jones Island​
  Saint Edward​
  Camano Island​
  Retreat Center - Fort Flagler​
  Retreat Center - Ramblewood​
  Retreat Center - Cornet Bay​
  Retreat Center - Camp Moran​
  Cama Beach"]

campgrounds.each { |camp| 
  directions_url = URI::HTTPS.build(host, "maps.google.com", path: "/maps", query: {saddr: "1911 18th ave s 98144", daddr: "#{camp} state park"}.to_query)
  puts directions_url
}

Lake Sammamish,            0:18
Saltwater,                 0:27
Dash Point,                0:35
Flaming Geyser,            0:53
Nolte                     0:53
Federation forest          1:13
Belfair                1:18 minutes
Bay View                1:26
Scenic Beach              1:33 minutes
Twanoh                    1:33
Schafer                   1:53
Birch Bay                 1:58
Fort Townsend               2:01
Jarrel Cove               2:25
Blake Island               Only by boat.
Peace Arch                2:02
Dosewallups               2:21
Deception Pass            1:33




["Camano Island​", "Kitsap Memorial​", "Larrabee​", "South Whidbey​", "Twanoh", "Deception Pass", "Retreat Center - Cornet Bay​", "Potlatch​", "Rasar​", "Fort Ebey​", "Schafer", "Rockport​", "Birch Bay", "Fort Townsend", "Lake Wenatchee​", "Peace Arch", "Sequim Bay​", "Retreat Center - Ramblewood​", "Fort Casey​", "Fort Worden​", "Dosewallups", "Fort Flagler​", "Ocean City​", "Retreat Center - Fort Flagler​", "Jarrel Cove", "Pacific Beach​", "Spencer Spit​", "Griffiths-Priday​", "Jones Island​", "Moran​", "Retreat Center - Camp Moran​", "Bogachiel", "Sucia Island​", "Posey Island​", "Blake Island"]