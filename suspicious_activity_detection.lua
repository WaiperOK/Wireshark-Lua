local ip_src_f = Field.new("ip.src")
local tcp_dst_f = Field.new("tcp.dstport")
local tcp_syn_f = Field.new("tcp.flags.syn")

local tap = Listener.new("tcp", "tcp")

local suspicious = {}

local port_scan_threshold = 10   -- unique ports threshold for port scanning
local ddos_threshold = 100         -- packet count threshold for DDoS
local time_window = 10             -- time window in seconds

function tap.packet(pinfo, tvb)
  local ip_src_field = ip_src_f()
  if not ip_src_field then return end
  local src_ip = tostring(ip_src_field)
  local current_time = pinfo.abs_ts

  if not suspicious[src_ip] then
    suspicious[src_ip] = { ports = {}, count = 0, first_seen = current_time, reported = false }
  end

  local record = suspicious[src_ip]

  if current_time - record.first_seen > time_window then
    record.ports = {}
    record.count = 0
    record.first_seen = current_time
    record.reported = false
  end

  record.count = record.count + 1

  local syn_field = tcp_syn_f()
  if syn_field then
    local syn = syn_field.value
    if syn ~= 0 then
      local dst_field = tcp_dst_f()
      if dst_field then
        local dst_port = tostring(dst_field)
        record.ports[dst_port] = true
      end
    end
  end

  local unique_ports = 0
  for _ in pairs(record.ports) do
    unique_ports = unique_ports + 1
  end

  if not record.reported then
    if unique_ports > port_scan_threshold then
      print("Potential port scanning detected from " .. src_ip .. ". Unique ports: " .. unique_ports)
      record.reported = true
    elseif record.count > ddos_threshold then
      print("Potential DDoS attack detected from " .. src_ip .. ". Packet count: " .. record.count)
      record.reported = true
    end
  end
end

function tap.draw()
  print("Suspicious activity detection complete.")
end

function tap.reset()
  suspicious = {}
end

return {}
