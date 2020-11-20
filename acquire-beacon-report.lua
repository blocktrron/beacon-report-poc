#!/usr/bin/env lua

local function usage()
	print("Usage: " .. arg[0] .. " <instance> <sta-mac> <mode> <op-class> <channel>")
end

if #arg < 5 then
	usage()
	return
end

local ubus = require "ubus"
local uloop = require "uloop"

uloop.init()

local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

local sub = {
	notify = function( msg, name )
		if name ~= "beacon-report" then return end
		print("Report from " .. msg["address"])
		print("    OP-Class:", msg["op-class"])
		print("     Channel:", msg["channel"])
		print("  Start-Time:", msg["start-time"])
		print("    Duration:", msg["duration"])
		print(" Report-Info:", msg["report-info"])
		print("        RCPI:", msg["rcpi"])
		print("        RSNI:", msg["rsni"])
		print("       BSSID:", msg["bssid"])
		print("  Antenna-ID:", msg["antenna-id"])
		print("  Parent-TSF:", msg["parent-tsf"])
	end,
}

conn:subscribe("hostapd." .. arg[1], sub)

local beacon_req = {
	addr = arg[2],
	mode = tonumber(arg[3]),
	op_class = tonumber(arg[4]),
	channel = tonumber(arg[5]),
	duration = 500,
	bssid = "ff:ff:ff:ff:ff:ff",
}

conn:call("hostapd." .. arg[1], "rrm_beacon_req", beacon_req)

uloop.run()
