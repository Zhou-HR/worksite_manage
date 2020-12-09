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
local proj_link_pic_add_number = decode_params["proj_link_pic_add_number"]

local user_id = comm_func.get_http_header("user_id", ngx)
local proj_bu_code

if type(proj_code) ~= "string" then
    local tab = {}
    tab["result"] = "proj_code参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end
if type(proj_link_id) ~= "number" then
    local tab = {}
    tab["result"] = "proj_link_id参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local proj_link_pic_max_num = 5
local ConfStatus, ConfApps = db_project.projectGlobalConf_get()
if ConfStatus == true then
    if ConfApps ~= nil and ConfApps[1] ~= nil then
        proj_link_pic_max_num = ConfApps[1]["proj_link_pic_max_num"]
    end
end
if proj_link_pic_add_number < 0 or proj_link_pic_add_number > proj_link_pic_max_num then
    local tab = {}
    tab["result"] = "proj_link_pic_add_number必须在0到" .. tostring(proj_link_pic_max_num) .. "之间"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local isAdmin = false
local userStatus, userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    proj_bu_code = userApps[1]["user_bu_code"]
    --if db_query.permission_check_project_review(userApps[1]["user_role"]) == false then
    if db_query.user_is_group_jianli(userApps[1]["user_role"]) == false and db_query.user_is_group_admin(userApps[1]["user_role"]) == false then
        local tab = {}
        tab["result"] = "该账号无权限修改"
        tab["error"] = error_table.get_error("ERROR_USER_PERMISSION_REFUSE")
        ngx.say(cjson.encode(tab))
        return
    else
        if userApps[1]["user_role"] == 0 or db_query.user_is_group_jianli(userApps[1]["user_role"]) then
            isAdmin = true
        else
            proj_bu_code = string.sub(userApps[1]["user_bu_code"], 1, 2)
            proj_bu_code = comm_func.buprovince_get(proj_bu_code)
        end
    end
else
    local tab = {}
    tab["result"] = "用户不存在"
    tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps, count, total
if isAdmin == true then
    status, apps, count, total = db_query.projectList_get(proj_code, nil, nil, nil, nil, nil, nil, nil, nil, false, 1, 0)
else
    status, apps, count, total = db_query.projectList_get(proj_code, nil, nil, nil, nil, nil, nil, proj_bu_code, nil, false, 1, 0)
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
local linkTab = nil
if status == true and #apps > 0 then
    local isThisProj = false
    for appsk, appsv in pairs(apps) do
        if proj_link_id == appsv["proj_link_id"] then
            if appsv["proj_link_status"] == 2 or appsv["proj_link_status"] == 3 or appsv["proj_link_status"] == 4 or appsv["proj_link_status"] == 5 or appsv["proj_link_status"] == 7 or appsv["proj_link_status"] == 8 then
                --if appsv["proj_link_status"] == 3 or appsv["proj_link_status"] == 4 or appsv["proj_link_status"] == 5 or appsv["proj_link_status"] == 7 or appsv["proj_link_status"] == 8 then
            else
                local tab = {}
                tab["result"] = "此工序不能追加照片"
                tab["error"] = error_table.get_error("ERROR_LINK_NO_EXISTS")
                ngx.say(cjson.encode(tab))
                return
            end
            isThisProj = true
            linkTab = appsv
            break
        end
    end
    if isThisProj == false then
        local tab = {}
        tab["result"] = "工序不存在:" .. tostring(v)
        tab["error"] = error_table.get_error("ERROR_LINK_NO_EXISTS")
        ngx.say(cjson.encode(tab))
        return
    end
else
    local tab = {}
    tab["result"] = "工序不存在"
    tab["error"] = error_table.get_error("ERROR_LINK_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps = db_project.projectLinkPicAddFlag_set(proj_link_id, proj_link_pic_add_number)

if status == true then
    --更新扣款记录里的reviewer_role
    --db_project.linkFine_bkup_update(proj_code,proj_link_id,1299)

    local linksTab = {}
    linksTab[1] = linkTab
    db_push_msg.projectLinkPicAddFlag_changed(user_id, proj_code, linksTab, proj_link_pic_add_number)
    local red = redis:new()
    red:set(conf_sys.sys_user_token["isHaveUnsendMsg"], "true")
    local tab = {}
    tab["result"] = "设置成功"
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = "修改状态失败"
    tab["error"] = error_table.get_error("ERROR_PROJ_PIC_ADD_FLAG_SET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end


