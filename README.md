HEADLESS=false bundle exec kimurai console --engine selenium_chrome --url "https://washington.goingtocamp.com/create-booking/results?mapId=-2147483346&searchTabGroupId=0&bookingCategoryId=0&startDate=2020-08-01T00:00:00.000Z&endDate=2020-08-02T00:00:00.000Z&nights=1&isReserving=true&equipmentId=-32768&subEquipmentId=-32768&partySize=2&searchTime=Mon%20Jul%2027%202020%2017:36:28%20GMT-0700%20(Pacific%20Daylight%20Time)&resourceLocationId=-2147483538"

HEADLESS=false ruby src/campground.rb

ruby src/campground.rb

whenever --update-crontab --load-file config/schedule.rb

```
bundle install
```