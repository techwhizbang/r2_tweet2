require 'rubygems'
require 'spec'
gem 'activerecord'
require 'active_record'

RAILS_ENV = 'test'
RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../../../../'))

require File.expand_path(File.dirname(__FILE__) + "/../lib/r2_tweet2")

def net_http_stub(response, obj_stubs = {}, host = 'twitter.com', port = 80)
  http = Net::HTTP.new(host, port)
  Net::HTTP.stub!(:new).and_return(http)
  http.stub!(:request).and_return(response)
  http
end

def net_http_block_stub(response, obj_stubs = {})
  http = mock(Net::HTTP, obj_stubs)
  Net::HTTP.stub!(:new).and_return(http)
  http.stub!(:request).and_return(response)
  http.stub!(:start).and_yield(http)
  http.stub!(:use_ssl=)
  http.stub!(:verify_mode=)
  http
end

def net_http_get_stub(obj_stubs = {})
  request = Spec::Mocks::Mock.new(Net::HTTP::Get)
  Net::HTTP::Get.stub!(:new).and_return(request)
  obj_stubs.each do |method, value|
    request.stub!(method).and_return(value)
  end
  request
end

def net_http_post_stub(obj_stubs = {})
  request = Spec::Mocks::Mock.new(Net::HTTP::Post)
  Net::HTTP::Post.stub!(:new).and_return(request)
  obj_stubs.each do |method, value|
    request.stub!(method).and_return(value)
  end
  request
end


def net_http_response_stub(status = :success, body = '')
  response = Spec::Mocks::Mock.new(Net::HTTPResponse)
  response.stub!(:body).and_return(body)
  case status
  when :success || 200
    _create_http_response(response, "200", "OK")
  when :created || 201
    _create_http_response(response, "201", "Created")
  when :redirect || 301
    _create_http_response(response, "301", "Redirect")
  when :not_authorized || 401
    _create_http_response(response, "401", "Not Authorized")
  when :forbidden || 403
    _create_http_response(response, "403", "Forbidden")
  when :file_not_found || 404
    _create_http_response(response, "404", "File Not Found")
  when :server_error || 500
    _create_http_response(response, "500", "Server Error")
  end
  response
end

private

def _create_http_response(mock_response, code, message)
  mock_response.stub!(:code).and_return(code)
  mock_response.stub!(:message).and_return(message)
  mock_response.stub!(:is_a?).and_return(true) if ["200", "201"].member?(code)
end
