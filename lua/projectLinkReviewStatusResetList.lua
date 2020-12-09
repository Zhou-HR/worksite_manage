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

local view_status = 0
ngx.log(ngx.ERR, "-----------proj_code: ", proj_code)

local user_id = comm_func.get_http_header("user_id", ngx)
local proj_bu_code
local user_name

if type(proj_code) ~= "string" then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if type(proj_link_id) ~= "number" then
    local tab = {}
    tab["result"] = "link id参数错误"
    tab["error"] = error_table.get_error("ERROR_LINK_ID_INVALID")
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

ngx.log(ngx.ERR, "----zjq------start get reset status list by proj_link_id: ", proj_link_id)
--Update tb_proj_link set proj_link_status = 1 where proj_code = 'GDJZAAAA201903YD' and proj_link_id = 598979
local status, apps = db_query.projectLink_review_reset_list_get(proj_link_id, proj_code)

if status == true then
    local tab = {}
    local appResult = {}
    appResult["proj_code"] = proj_code
    appResult["list"] = apps
    tab["result"] = appResult
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
    return
else
    local tab = {}
    tab["result"] = "获取重置状态记录列表内容失败"
    tab["error"] = error_table.get_error("ERROR_LINK_REVIEW_STATUS_RESET_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

