FROM ruby:2.6-alpine

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc \
    && apk --update add --virtual build-dependencies build-base gcc postgresql-dev \
      linux-headers libxml2 libxml2-dev libxml2-utils libxslt libxslt-dev mariadb-dev sqlite sqlite-dev \
    && apk --update add libpq bash nodejs zlib tzdata git imagemagick \
    && gem install bundler

# RUN git clone --depth 2 https://github.com/Shelvak/merchants /merchants

WORKDIR /merchants
ADD . .

# RUN bundle config build.nokogiri --use-system-libraries && \
RUN   bundle install --deployment --jobs 8 && \
    apk del build-dependencies

# ENV SOCKETIO => así se compila todo acá

RUN mkdir -p /merchants/tmp

# RUN cp config/secrets.example.yml config/secrets.yml \
#     && mkdir -p /merchants/tmp \
#     && bundle exec rake assets:precompile

CMD /merchants/start.sh
