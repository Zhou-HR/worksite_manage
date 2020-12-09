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

local decode_params = decode_data["params"]

local proj_code = decode_params["proj_code"]

local proj_link_id = decode_params["proj_link_id"]

local user_id = comm_func.get_http_header("user_id", ngx)

if proj_code ~= nil and type(proj_code) ~= "string" then
    local tab = {}
    tab["result"] = "proj_code必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_link_id ~= nil and type(proj_link_id) ~= "number" then
    local tab = {}
    tab["result"] = "proj_link_id必须是整形"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local userStatus, userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
else
    local tab = {}
    tab["result"] = "用户不存在"
    tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps, count, total
if proj_code ~= nil then
    status, apps, count, total = db_query.projectList_get(proj_code, nil, nil, nil, nil, nil, nil, nil, nil, false, 1, 0)
end
if status == true and count == 1 then
else
    local tab = {}
    tab["result"] = "项目不存在"
    tab["error"] = error_table.get_error("ERROR_PROJ_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

status, apps = db_query.projectLink_get(proj_code)
if status == true and #apps > 0 then
else
    local tab = {}
    tab["result"] = "工序不存在"
    tab["error"] = error_table.get_error("ERROR_LINK_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

-- 调用查询方法
local status, apps = db_query.link_reset_list(proj_code, proj_link_id)
if status == true then
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = "获取状态记录列表内容失败"
    tab["error"] = error_table.get_error("ERROR_LINK_REVIEW_STATUS_RESET_GET_FAILED")
    ngx.say(cjson.encode(tab))
end

