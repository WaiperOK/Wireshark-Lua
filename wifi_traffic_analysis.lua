local ssid_f = Field.new("wlan.ssid")
local src_mac_f = Field.new("wlan.sa")
local dst_mac_f = Field.new("wlan.da")
local signal_f = Field.new("radiotap.dbm_antsignal")

local tap = Listener.new("wlan", "wlan")

local wifi_frames = {}

function tap.packet(pinfo, tvb)
    local ssid_field = ssid_f()
    local src_field = src_mac_f()
    local dst_field = dst_mac_f()
    local signal_field = signal_f()
    
    local ssid = ssid_field and tostring(ssid_field) or "N/A"
    local src_mac = src_field and tostring(src_field) or "N/A"
    local dst_mac = dst_field and tostring(dst_field) or "N/A"
    local signal = signal_field and tostring(signal_field) or "N/A"
    
    table.insert(wifi_frames, { ssid = ssid, src_mac = src_mac, dst_mac = dst_mac, signal = signal })
    print("Wi-Fi Frame: SSID: " .. ssid .. " | Src: " .. src_mac .. " | Dst: " .. dst_mac .. " | Signal: " .. signal)
end

function tap.draw()
    print("Total Wi-Fi frames processed: " .. #wifi_frames)
end

function tap.reset()
    wifi_frames = {}
end

return {}
