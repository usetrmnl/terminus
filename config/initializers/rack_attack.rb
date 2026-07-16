# frozen_string_literal: true

require "ipaddr"
require "rack/attack"

allowed_subnets = [
  IPAddr.new("10.0.0.0/8"),
  IPAddr.new("172.16.0.0/12"),
  IPAddr.new("192.168.0.0/16"),
  IPAddr.new("127.0.0.1"),
  IPAddr.new("::1"),
  *ENV.fetch("RACK_ATTACK_ALLOWED_SUBNETS", "").split(",").map { IPAddr.new it }
]

Rack::Attack.safelist "allow subnets" do |request|
  allowed_subnets.any? { |subnet| subnet.include? request.ip }
end
