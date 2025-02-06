local mqtt_proto = Proto("mqtt_custom", "MQTT Custom Dissector")

local f_mqtt_type = ProtoField.uint8("mqtt_custom.type", "Message Type", base.DEC)
local f_mqtt_qos = ProtoField.uint8("mqtt_custom.qos", "QoS Level", base.DEC, nil, 0x06)
local f_mqtt_topic = ProtoField.string("mqtt_custom.topic", "Topic")
local f_mqtt_payload = ProtoField.string("mqtt_custom.payload", "Payload")

mqtt_proto.fields = { f_mqtt_type, f_mqtt_qos, f_mqtt_topic, f_mqtt_payload }

function mqtt_proto.dissector(tvb, pinfo, tree)
    pinfo.cols.protocol = "MQTT_CUSTOM"
    
    local offset = 0
    if tvb:len() < 2 then return end

 
    local header = tvb(offset, 1):uint()
    local message_type = bit.rshift(header, 4)
    local qos = bit.band(header, 0x06) / 2
    local subtree = tree:add(mqtt_proto, tvb(), "MQTT Custom Protocol Data")
    subtree:add(f_mqtt_type, tvb(offset, 1)):append_text(" (" .. message_type .. ")")
    subtree:add(f_mqtt_qos, tvb(offset, 1)):append_text(" (" .. qos .. ")")
    offset = offset + 1

    
    local multiplier = 1
    local remaining_length = 0
    local encodedByte = 0
    repeat
        encodedByte = tvb(offset, 1):uint()
        remaining_length = remaining_length + bit.band(encodedByte, 0x7F) * multiplier
        multiplier = multiplier * 128
        offset = offset + 1
    until (bit.band(encodedByte, 0x80) == 0) or (offset > tvb:len())

    
    if message_type == 3 then
        if tvb:len() < offset + 2 then return end
        local topic_length = tvb(offset, 2):uint()
        subtree:add("Topic Length", tvb(offset, 2), topic_length)
        offset = offset + 2

        if tvb:len() < offset + topic_length then return end
        local topic = tvb(offset, topic_length):string()
        subtree:add(f_mqtt_topic, tvb(offset, topic_length), topic)
        offset = offset + topic_length

        if qos > 0 then
            if tvb:len() < offset + 2 then return end
            local packet_id = tvb(offset, 2):uint()
            subtree:add("Packet Identifier", tvb(offset, 2), packet_id)
            offset = offset + 2
        end

        if tvb:len() > offset then
            local payload_length = tvb:len() - offset
            local payload = tvb(offset, payload_length):string()
            subtree:add(f_mqtt_payload, tvb(offset, payload_length), payload)
        end
    else
        subtree:append_text(" (Non-PUBLISH Message)")
    end
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(1883, mqtt_proto)

return mqtt_proto
