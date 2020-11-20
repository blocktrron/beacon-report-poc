#!/usr/bin/env lua

require "ubus"
require "uloop"

uloop.init()

local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

local sub = {
	notify = function( msg, name )
		print(msg["address"] .. name)
	end,
}

conn:subscribe("hostapd." .. arg[1], sub)

local disassoc = {
	addr = arg[2],
	duration = 1000,
	-- Add list of Neighbor report elements to this table
	neighbors = {"f09fc2f4ae2cef0900005109070603000900"},
	abridged = 1,
}

conn:call("hostapd." .. arg[1], "wnm_disassoc_imminent", disassoc)

uloop.run()
