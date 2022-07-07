# Washington State Campground Finder

This repository will help you get those tough to find reservations for the washington state park system! Configure it correctly, and each time your search configuration finds a newly opened campground, you'll be notified via [Pushover](https://pushover.net) notification.

## Installation

Copy the `.env.example` to `.env` file and edit `.env` to provide the proper pushover notification settings.

Modify the search.yml file to match the configuration you'd like to use!

Example search.yml file:

```
campground_ids: 
  - dash_point # (see campgrounds.yml for a list of all campground ids)
  - saltwater
  - belfair
  - alta_lake
start_date: '2022-07-08'
end_date: '2022-07-09'
party_size: 2 
subequipment_id: 
 - -32768 # one tent (see subequipment.rb for full list)
minutes_interval: 10
```

```
bundle install
bundle exec ruby src/orchestrator.rb
```


#### Work pending

- [x] Make things a little more configurable
- [x] Allow to search multiple campgrounds per process
- [x] Write up instructions on how to configure 
- [ ] Dockerize the process
- [ ] Clean up the storage class
