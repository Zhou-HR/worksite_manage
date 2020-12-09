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

if view_status == nil then
    view_status = 0
end

ngx.log(ngx.ERR, "projectList_get proj_code: ", proj_code)
if (proj_code == nil or type(proj_code) ~= "string") then
    tab["result"] = "params必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps = db_meter.meter_query_info(proj_code)
if status == true then
    comm_func.do_dump_value(apps, 0)
    if apps ~= nil and apps[1] ~= nil and apps[1]["proj_code"] ~= nil then
        tab["result"] = apps
        tab["error"] = error_table.get_error("ERROR_NONE")
        tab["description"] = "SUCCESS"

        ngx.say(cjson.encode(tab))
        return
    end
end

tab["result"] = {}
tab["error"] = error_table.get_error("ERROR_NONE")
tab["description"] = "ERROR_NONE"
ngx.say(cjson.encode(tab))
