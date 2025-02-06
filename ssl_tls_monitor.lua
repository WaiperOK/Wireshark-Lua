local function safeField(fieldName)
  local status, field = pcall(Field.new, fieldName)
  if status then
    return field
  else
    return nil
  end
end

local handshake_version_f = safeField("ssl.handshake.version") or safeField("tls.handshake.version")
local ciphersuite_f = safeField("ssl.handshake.ciphersuite") or safeField("tls.handshake.ciphersuite")
local alert_f = safeField("ssl.alert_message") or safeField("tls.alert_message")
local cert_f = safeField("ssl.handshake.certificate") or safeField("tls.handshake.certificate")

local tap = Listener.new("tcp", "tcp.port == 443")

function tap.packet(pinfo, tvb)
    local handshake_ver_field = handshake_version_f and handshake_version_f()
    local cipher_field = ciphersuite_f and ciphersuite_f()
    local alert_field = alert_f and alert_f()
    local cert_field = cert_f and cert_f()

    if handshake_ver_field or cipher_field then
        local handshake_version = handshake_ver_field and tostring(handshake_ver_field) or "N/A"
        local cipher = cipher_field and tostring(cipher_field) or "N/A"
        print("SSL/TLS Handshake Detected: Version: " .. handshake_version .. ", Cipher Suite: " .. cipher)
    end

    if alert_field then
        local alert = tostring(alert_field)
        print("SSL/TLS Alert: " .. alert)
    end

    if cert_field then
        local cert = tostring(cert_field)
        print("Certificate Info: " .. cert)
    end
end

function tap.draw()
    print("SSL/TLS analysis complete.")
end

function tap.reset()
end

return {}
