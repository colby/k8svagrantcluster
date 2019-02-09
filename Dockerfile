FROM ruby:alpine
ADD ./ruby /
WORKDIR /
RUN apk --no-cache add --virtual build-deps g++ musl-dev make
RUN bundle install --no-cache
ENV REDIS_URL 'redis://redis.default.svc.cluster.local:6379/1'
CMD ["ruby", "server.rb"]
