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
local proj_code_src = decode_params["proj_code"]
local proj_code = string.sub(decode_params["proj_code"], 1, 14)
local module_id = tonumber(decode_params["module_id"])

ngx.log(ngx.ERR, "project_status_query proj_code: ", proj_code)
ngx.log(ngx.ERR, "project_status_query module_id: ", module_id)

if (proj_code == nil or type(proj_code) ~= "string") then
    tab["result"] = "params必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if (module_id == nil or type(module_id) ~= "number") then
    tab["result"] = "module_id 必须为整型"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local statusinfo = {}
statusinfo["status"] = 0
statusinfo["acquisition"] = 0
local status, apps = db_meter.acquisition_query(proj_code_src)
ngx.log(ngx.ERR, "projectList_get status: ", status)
if status == true then
    comm_func.do_dump_value(apps, 0)
    if apps ~= nil and apps[1] ~= nil and apps[1]["acquisition"] ~= nil then
        statusinfo["acquisition"] = apps[1]["acquisition"]
    end
end

status, apps = db_meter.project_status_query(proj_code, module_id)
if status == true then
    comm_func.do_dump_value(apps, 0)
    statusinfo["status"] = apps
    tab["result"] = statusinfo
    tab["error"] = error_table.get_error("ERROR_NONE")
    tab["description"] = "SUCCESS"

    ngx.say(cjson.encode(tab))
    return
end

tab["result"] = statusinfo
tab["error"] = error_table.get_error("ERROR_NONE")
tab["description"] = "ERROR_NONE"
ngx.say(cjson.encode(tab))
