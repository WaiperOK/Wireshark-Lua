local ftp_req_cmd_f = Field.new("ftp.request.command")
local ftp_req_arg_f = Field.new("ftp.request.arg")
local ftp_resp_code_f = Field.new("ftp.response.code")
local ftp_resp_arg_f = Field.new("ftp.response.arg")

local tap = Listener.new("tcp", "tcp.port == 21")

function tap.packet(pinfo, tvb)
  local req_cmd_field = ftp_req_cmd_f()
  if req_cmd_field then
    local command = tostring(req_cmd_field)
    local argument = ""
    local req_arg_field = ftp_req_arg_f()
    if req_arg_field then
      argument = tostring(req_arg_field)
    end
    print("FTP Request: " .. command .. " " .. argument)
  end

  local resp_code_field = ftp_resp_code_f()
  if resp_code_field then
    local code = tostring(resp_code_field)
    local argument = ""
    local resp_arg_field = ftp_resp_arg_f()
    if resp_arg_field then
      argument = tostring(resp_arg_field)
    end
    print("FTP Response: " .. code .. " " .. argument)
  end
end

function tap.draw()
  print("FTP session analysis complete.")
end

function tap.reset()
end

return {}
