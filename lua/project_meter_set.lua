ngx.req.read_body()
local data = ngx.req.get_body_data()

local tab = {}
local decode_data = cjson.decode(data)
if decode_data == nil then
    tab["result"] = "参数必须是JSON格式"
    tab["error"] = error_table.get_error("ERROR_JSON_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local decode_params = decode_data["params"]
local proj_code = decode_params["proj_code"]
local old_meter_number = decode_params["old_meter_number"]
local old_meter_value = tonumber(decode_params["old_meter_value"])
local new_meter_number = decode_params["new_meter_number"]
local new_meter_value = tonumber(decode_params["new_meter_value"])
local if_receive_msg = tonumber(decode_params["if_receive_msg"])
local if_use_new_box = tonumber(decode_params["if_use_new_box"])
local if_state_grid = tonumber(decode_params["if_state_grid"])
local user_id = comm_func.get_http_header("user_id", ngx)
if (user_id == nil) then
    user_id = 1
end

if (proj_code == nil or type(proj_code) ~= "string") or
        (old_meter_number == nil or type(old_meter_number) ~= "string") or
        (new_meter_number == nil or type(new_meter_number) ~= "string") then
    local tab = {}
    tab["result"] = "params必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if (if_receive_msg == nil or type(if_receive_msg) ~= "number") or
        (old_meter_value == nil or type(old_meter_value) ~= "number") or
        (new_meter_value == nil or type(new_meter_value) ~= "number") or
        (if_use_new_box == nil or type(if_use_new_box) ~= "number") or
        (if_state_grid == nil or type(if_state_grid) ~= "number") then
    tab["result"] = "if_receive_msg 必须为整型"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if string.len(old_meter_number) ~= 12 or
        string.len(new_meter_number) ~= 12 then
    local tab = {}
    tab["result"] = "电表长度错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local checkstatus = db_meter.check_meter_number_if_used(proj_code, new_meter_number)
if checkstatus == true then
    local tab = {}
    tab["result"] = "电表已经正在使用，请使用新表。"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps = db_meter.meter_update_erp(proj_code, old_meter_number, old_meter_value, new_meter_number, new_meter_value, if_receive_msg, if_use_new_box, if_state_grid, user_id)
if status ~= true then
    comm_func.do_dump_value(apps, 0)
end

status, apps = db_meter.meter_update(proj_code, old_meter_number, old_meter_value, new_meter_number, new_meter_value, if_receive_msg, if_use_new_box, if_state_grid, user_id)
if status == true then
    comm_func.do_dump_value(apps, 0)
    if apps ~= nil and apps[1] ~= nil and apps[1]["returnvalue"] ~= nil then
        local returnvalue = apps[1]["returnvalue"]
        tab["result"] = returnvalue

        if returnvalue == 0 then
            tab["error"] = error_table.get_error("ERROR_NONE")
            tab["description"] = "SUCCESS"
            ngx.say(cjson.encode(tab))
            return
        end
    end
end

tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
tab["description"] = "ERROR_PARAMS_WRONG"
ngx.say(cjson.encode(tab))
