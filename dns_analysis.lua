local dns_query_field = Field.new("dns.qry.name")
local dns_response_flag = Field.new("dns.flags.response")

local tap = Listener.new("dns", "dns")

local dns_stats = { queries = {}, responses = {} }

function tap.packet(pinfo, tvb)
  local query_field = dns_query_field()
  if query_field then
    local domain = tostring(query_field)
    local is_response = false
    local response_flag = dns_response_flag()
    if response_flag and response_flag.value == 1 then
      is_response = true
    end

    if is_response then
      dns_stats.responses[domain] = (dns_stats.responses[domain] or 0) + 1
      print("DNS Response: " .. domain)
    else
      dns_stats.queries[domain] = (dns_stats.queries[domain] or 0) + 1
      print("DNS Query: " .. domain)
    end
  end
end

function tap.draw()
  print("=== DNS Query Statistics ===")
  for domain, count in pairs(dns_stats.queries) do
    print(domain .. ": " .. count)
  end
  print("=== DNS Response Statistics ===")
  for domain, count in pairs(dns_stats.responses) do
    print(domain .. ": " .. count)
  end
end

function tap.reset()
  dns_stats = { queries = {}, responses = {} }
end

return {}
