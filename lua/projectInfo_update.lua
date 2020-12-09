ngx.req.read_body()
local data = ngx.req.get_body_data()

local decode_data = cjson.decode(data)
if decode_data == nil then
    local tab = {}
    tab["result"] = "参数必须是JSON格式"
    tab["error"] = error_table.get_error("ERROR_JSON_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local user_id = comm_func.get_http_header("user_id", ngx)

local decode_params = decode_data["params"]
local proj_code = decode_params["proj_code"]
local proj_tujian_unit = decode_params["proj_tujian_unit"]
local proj_jiedian_unit = decode_params["proj_jiedian_unit"]

local proj_bu_code
local dev_request_type = comm_func.get_http_header("dev-request-type", ngx)

if type(dev_request_type) ~= "string" then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_code == nil or (proj_code ~= nil and type(proj_code) ~= "string") then
    local tab = {}
    tab["result"] = "proj_code必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_tujian_unit == nil and proj_jiedian_unit == nil then
    local tab = {}
    tab["result"] = "proj_tujian_unit和proj_jiedian_unit不能为空"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_tujian_unit ~= nil then
    proj_tujian_unit = comm_func.sql_singleQuotationMarks(proj_tujian_unit)
    proj_tujian_unit = comm_func.trim_string(proj_tujian_unit)
end

if proj_jiedian_unit ~= nil then
    proj_jiedian_unit = comm_func.sql_singleQuotationMarks(proj_jiedian_unit)
    proj_jiedian_unit = comm_func.trim_string(proj_jiedian_unit)
end

if (proj_tujian_unit ~= nil and string.len(proj_tujian_unit) < 0) or (proj_jiedian_unit ~= nil and string.len(proj_jiedian_unit) < 0) then
    local tab = {}
    tab["result"] = "proj_tujian_unit和proj_jiedian_unit不能为空"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local userIdValid = comm_func.do_check_user_id_valid(user_id)
if userIdValid == 0 then
    local tab = {}
    tab["result"] = "user_id不合法"
    tab["error"] = error_table.get_error("ERROR_USER_ID_INVALID")
    ngx.say(cjson.encode(tab))
    return
end

local isAdmin = false
local userStatus, userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    proj_bu_code = userApps[1]["user_bu_code"]
    isAdmin = db_query.userAdmin_is(userApps[1], user_id)
    if isAdmin == true then
        proj_bu_code = nil
    end
    if userApps[1]["user_role"] == 1 then
        proj_bu_code = string.sub(userApps[1]["user_bu_code"], 1, 2)
    else
        proj_bu_code = comm_func.buprovince_get(proj_bu_code)
    end

else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_PROJ_INFO_UPDATE_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps = db_project.projectInfo_update(proj_code, proj_bu_code, isAdmin, proj_tujian_unit, proj_jiedian_unit)
if status == true and apps ~= nil and apps[1] ~= nil then
    local tab = {}
    tab["result"] = "SUCCESS"
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_PROJ_INFO_UPDATE_FAILED")
    ngx.say(cjson.encode(tab))
end

