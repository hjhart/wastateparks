FROM ruby:2.7.3-alpine
LABEL author='James Hart hjhart@gmail.com'

WORKDIR /usr/src/app

RUN apk update && apk add --no-cache build-base sqlite-dev curl
# RUN mkdir -p /usr/local/bundle
# ENV GEM_HOME /usr/local/bundle
# ENV PATH /usr/local/bundle/bin:$PATH

COPY Gemfile* ./
RUN gem install bundler:${BUNDLER_VERSION:-2.2.22}
RUN bundle config without development
RUN bundle install --jobs 8 && rm -rf /usr/local/bundle/cache/*.gem

ENV RACK_ENV=production
COPY . .

CMD ["bundle", "exec", "ruby", "src/orchestrator.rb"]

