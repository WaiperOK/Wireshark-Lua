local ip_counts = {}

local ip_src_f = Field.new("ip.src")
local ip_dst_f = Field.new("ip.dst")

local tap = Listener.new("ip", "ip")

function tap.packet(pinfo, tvb)
    local src_field = ip_src_f()
    local dst_field = ip_dst_f()
    
    if src_field then
        local src = tostring(src_field)
        ip_counts[src] = (ip_counts[src] or 0) + 1
    end
    
    if dst_field then
        local dst = tostring(dst_field)
        ip_counts[dst] = (ip_counts[dst] or 0) + 1
    end
end

function tap.draw()
    print("=== IP address statistics ===")
    for ip, count in pairs(ip_counts) do
        print(ip .. ": " .. count .. "packages")
    end
end

function tap.reset()
    ip_counts = {}
end

return {}
