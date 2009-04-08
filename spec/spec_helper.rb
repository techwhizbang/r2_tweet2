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
  http.stub!(:set_form_data)
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
  
  case status
  when :success || 200
    response = Net::HTTPSuccess.new("1.1", 200, "OK")
  when :not_modified || 304
    response = Net::HTTPNotModified.new("1.1", 304, "Not Modified")
  when :bad_request || 400
    response = Net::HTTPBadRequest.new("1.1", 400, "Bad Request")
  when :not_authorized || 401
    response = Net::HTTPUnauthorized.new("1.1", 401, "Not Authorized")
  when :forbidden || 403
    response = Net::HTTPForbidden.new("1.1", 403, "Forbidden")
  when :not_found || 404
    response = Net::HTTPNotFound.new("1.1", 404, "File Not Found")
  when :server_error || 500
    response = Net::HTTPInternalServerError.new("1.1", 500, "Internal Server Error")
  when :bad_gateway || 502
    response = Net::HTTPBadGateway.new("1.1", 502, "Bad Gateway")
  when :service_unavailable || 503
    response = Net::HTTPServiceUnavailable.new("1.1", 503, "Service Unavailable")
  else
    response = Net::HTTPSuccess.new("1.1", 200, "OK")
  end

  response
end

private

def _create_http_response(mock_response, code, message)
  mock_response.stub!(:code).and_return(code)
  mock_response.stub!(:message).and_return(message)
  mock_response.stub!(:is_a?).and_return(true) if ["200", "201"].member?(code)
end
