require 'thin'
require 'sinatra'
require 'redis'

set :bind, '0.0.0.0'
set :port, 8080

get '/' do
  begin
    redis = Redis.new
    redis.ping
  rescue => err
    "error: #{err}"
  ensure
    redis.close unless redis.nil?
  end
end
