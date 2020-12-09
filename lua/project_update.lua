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
local proj_link_pic_max_num = decode_params["proj_link_pic_max_num"]
local proj_link_max_distan = decode_params["proj_link_max_distan"]
local proj_bu_code
local dev_request_type = comm_func.get_http_header("dev-request-type", ngx)

if type(dev_request_type) ~= "string" then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_link_pic_max_num ~= nil and type(proj_link_pic_max_num) ~= "number" then
    local tab = {}
    tab["result"] = "proj_link_pic_max_num必须为整形"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_link_max_distan ~= nil and type(proj_link_max_distan) ~= "number" then
    local tab = {}
    tab["result"] = "proj_link_max_distan必须为整形"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_link_pic_max_num == nil and proj_link_max_distan == nil then
    local tab = {}
    tab["result"] = "proj_link_pic_max_num与proj_link_max_distan至少有一个"
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
    elseif userApps[1]["user_role"] ~= 1 and userApps[1]["user_role"] ~= 0 then
        local tab = {}
        tab["result"] = "您无权限修改"
        tab["error"] = error_table.get_error("ERROR_USER_PERMISSION_REFUSE")
        ngx.say(cjson.encode(tab))
        return
    end
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_PROJ_UPDATE_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

if isAdmin == false then
    if proj_code == nil or (proj_code ~= nil and type(proj_code) ~= "string") then
        local tab = {}
        tab["result"] = "proj_code必须为字符串"
        tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
end

if proj_code ~= nil then
    local status, apps, count, total = db_query.projectList_get(proj_code, nil, nil, nil, nil, nil, nil, proj_bu_code, nil, false, 1, 0)
    if status == true and count == 1 then
    else
        local tab = {}
        tab["result"] = "项目不存在"
        tab["error"] = error_table.get_error("ERROR_PROJ_NO_EXISTS")
        ngx.say(cjson.encode(tab))
        return
    end
end

local status, apps
if proj_code == nil and isAdmin == true then
    status, apps = db_project.allProjectPicTakeControl_update(proj_link_pic_max_num, proj_link_max_distan)
    if status == true then
        db_project.projectGlobalConf_update(proj_link_pic_max_num, proj_link_max_distan)
    end
else
    status, apps = db_query.projectPicTakeControl_update(proj_code, proj_bu_code, isAdmin, proj_link_pic_max_num, proj_link_max_distan)
end
if status == true then
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_PROJ_UPDATE_FAILED")
    ngx.say(cjson.encode(tab))
end

