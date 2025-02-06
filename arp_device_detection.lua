local arp_src_field = Field.new("arp.src.hw_mac")
local tap = Listener.new(nil, "arp")
local devices = {}

function tap.packet(pinfo, tvb)
  local src_mac_field = arp_src_field()
  if src_mac_field then
    local src_mac = tostring(src_mac_field)
    if not devices[src_mac] then
      devices[src_mac] = true
      print("Device detected: " .. src_mac)
    end
  end
end

function tap.draw()
  local count = 0
  for _ in pairs(devices) do
    count = count + 1
  end
  print("Total unique devices detected: " .. count)
end

return {}
