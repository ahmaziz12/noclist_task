#!/usr/bin/env ruby

require 'digest'
require 'http'

def custom_retry(request_url, checksum = nil)
  count = 0
  loop do
    @response = checksum.nil? ? HTTP.get(request_url) : HTTP.headers('X-Request-Checksum' => checksum).get(request_url)
    exit(1) if count >= 2
    if @response.status.success? || count > 2
      break
    else
      STDERR.puts @response if !@response.status.success?
    end
    count += 1
  end
end

custom_retry 'http://0.0.0.0:8888/auth'
badsec_token = @response.headers['Badsec-Authentication-Token']
badsec_token.concat('/users')

checksum = Digest::SHA256.hexdigest(badsec_token)
custom_retry 'http://0.0.0.0:8888/users', checksum
STDOUT.puts @response.body.to_s.split("\n").inspect
