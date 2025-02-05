local handshakes = {}

local ip_src_f = Field.new("ip.src")
local ip_dst_f = Field.new("ip.dst")
local tcp_src_f = Field.new("tcp.srcport")
local tcp_dst_f = Field.new("tcp.dstport")
local tcp_flags_syn_f = Field.new("tcp.flags.syn")
local tcp_flags_ack_f = Field.new("tcp.flags.ack")

local tap = Listener.new("tcp", "tcp")

local function dump_table(tbl)
    for key, value in pairs(tbl) do
        print(key, value)
    end
end

function tap.packet(pinfo, tvb)
    local ip_src = tostring(ip_src_f())
    local ip_dst = tostring(ip_dst_f())
    local src_port = tostring(tcp_src_f())
    local dst_port = tostring(tcp_dst_f())
    
    local syn = tcp_flags_syn_f() and true or false
    local ack = tcp_flags_ack_f() and true or false

    if syn and not ack then
        local key = ip_src .. ":" .. src_port .. "->" .. ip_dst .. ":" .. dst_port
        handshakes[key] = { syn_time = pinfo.abs_ts }
    elseif syn and ack then
        local key = ip_dst .. ":" .. dst_port .. "->" .. ip_src .. ":" .. src_port
        if handshakes[key] then
            handshakes[key].syn_ack_time = pinfo.abs_ts
        end
    elseif ack and not syn then
        local key = ip_src .. ":" .. src_port .. "->" .. ip_dst .. ":" .. dst_port
        if handshakes[key] and handshakes[key].syn_ack_time then
            local handshake_time = pinfo.abs_ts - handshakes[key].syn_time
            print("TCP Handshake: " .. key .. " | Time: " .. handshake_time .. " sec")
            handshakes[key] = nil
        end
    end
end

function tap.draw()
    print("Remaining handshake records:")
    dump_table(handshakes)
end

function tap.reset()
    handshakes = {}
end

return {}
