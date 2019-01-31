FROM ruby:alpine
ADD ./ruby /
WORKDIR /
RUN apk --no-cache add g++ musl-dev make
RUN bundle install
ENV REDIS_URL 'redis://redis:6379/1'
CMD ["ruby", "server.rb"]
