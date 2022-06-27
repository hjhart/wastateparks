# Washington State Campground Finder

This repository will help you get those tough to find reservations for the washington state park system! Configure it correctly, and each time your search configuration finds a newly opened campground, you'll be notified via [Pushover](https://pushover.net) notification.

## Installation

Copy the `.env.example` to `.env` file and edit `.env` to provide the proper pushover notification settings.


```
bundle install
bundle exec ruby src/orchestrator.rb
```


#### Work pending

- [ ] Make things a little more configurable
- [ ] Allow to search multiple campgrounds per process
- [ ] Write up instructions on how to configure 
- [ ] Dockerize the process
- [ ] Clean up the storage class
