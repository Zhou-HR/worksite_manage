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
--comm_func.do_dump_value(decode_data,0)
local decode_params = decode_data["params"]
local proj_code = decode_params["proj_code"]
local links = decode_params["links"]
local user_id = comm_func.get_http_header("user_id", ngx)
local proj_bu_code

if type(proj_code) ~= "string" or type(links) ~= "table" or #links < 1 then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local linkIdTab = {}
local linkIdTabIndex = 1
local linkIdsTab = {}
for k, v in pairs(links) do
    if type(v["proj_link_id"]) ~= "number" then
        local tab = {}
        tab["result"] = "link id参数错误"
        tab["error"] = error_table.get_error("ERROR_LINK_ID_INVALID")
        ngx.say(cjson.encode(tab))
        return
    else
        for idk, idv in pairs(linkIdTab) do
            if idv == v["proj_link_id"] then
                local tab = {}
                tab["result"] = "link id重复"
                tab["error"] = error_table.get_error("ERROR_LINK_ID_DUPLICATE")
                ngx.say(cjson.encode(tab))
                return
            end
        end
        local isRight, msg = db_query.link_check(v)
        if isRight == false then
            local tab = {}
            tab["result"] = msg
            tab["error"] = error_table.get_error("ERROR_LINK_INFO")
            ngx.say(cjson.encode(tab))
            return
        end
        local tabLink = {}
        local proj_link_picTab = v["proj_link_pic"]
        tabLink["proj_link_id"] = v["proj_link_id"]
        tabLink["pic_num"] = #proj_link_picTab
        linkIdsTab[linkIdTabIndex] = v["proj_link_id"]
        linkIdTab[linkIdTabIndex] = tabLink
        linkIdTabIndex = linkIdTabIndex + 1
    end
end

local userStatus, userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    if userApps[1]["user_role"] ~= 2 then
        local tab = {}
        tab["result"] = "该账号无权限提交"
        tab["error"] = error_table.get_error("ERROR_USER_PERMISSION_REFUSE")
        ngx.say(cjson.encode(tab))
        return
    end
    proj_bu_code = userApps[1]["user_bu_code"]
    proj_bu_code = comm_func.buprovince_get(proj_bu_code)
else
    local tab = {}
    tab["result"] = "用户不存在"
    tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps, count, total = db_query.projectList_get(proj_code, nil, nil, nil, nil, nil, nil, proj_bu_code, nil, false, 1, 0)
if status == true and count == 1 then
else
    local tab = {}
    tab["result"] = "项目不存在"
    tab["error"] = error_table.get_error("ERROR_PROJ_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end
local linksTab = {}
status, apps = db_query.projectLink_get(proj_code)
if status == true and #apps > 0 then
    for k, v in pairs(linkIdTab) do
        local isThisProj = false
        for appsk, appsv in pairs(apps) do
            if v["proj_link_id"] == appsv["proj_link_id"] then
                if appsv["proj_link_pic_add_number"] <= 0 then
                    local tab = {}
                    tab["result"] = "工序:" .. tostring(v["proj_link_id"]) .. ",不能追加照片"
                    tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED")
                    ngx.say(cjson.encode(tab))
                    return
                end
                if appsv["proj_link_status"] == 2 or appsv["proj_link_status"] == 3 or appsv["proj_link_status"] == 4 or appsv["proj_link_status"] == 5 or appsv["proj_link_status"] == 7 or appsv["proj_link_status"] == 8 then
                else
                    local tab = {}
                    tab["result"] = "工序:" .. tostring(v["proj_link_id"]) .. ",状态错误，无法次提交"
                    tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED")
                    ngx.say(cjson.encode(tab))
                    return
                end
                if v["pic_num"] > appsv["proj_link_pic_max_num"] then
                    local tab = {}
                    tab["result"] = "工序:" .. tostring(v["proj_link_id"]) .. ",照片数量超过最大限制"
                    tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED")
                    ngx.say(cjson.encode(tab))
                    return
                end
                isThisProj = true
                linksTab[tostring(v["proj_link_id"])] = { proj_link_name = appsv["proj_link_name"], proj_module_name = appsv["proj_module_name"], proj_link_status = appsv["proj_link_status"], proj_link_pic_add_number = appsv["proj_link_pic_add_number"], proj_link_pic = cjson.decode(appsv["proj_link_pic"]) }
                break
            end
        end
        if isThisProj == false then
            local tab = {}
            tab["result"] = "工序不存在:" .. tostring(v["proj_link_id"])
            tab["error"] = error_table.get_error("ERROR_LINK_NO_EXISTS")
            ngx.say(cjson.encode(tab))
            return
        end
    end
else
    local tab = {}
    tab["result"] = "工序不存在"
    tab["error"] = error_table.get_error("ERROR_LINK_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps = db_query.projectLink_submit(links, proj_code, linksTab)

if status == true then
    local linkIds = table.concat(linkIdsTab, ",")
    db_project.linkFine_reviewer_role_update(proj_code, linkIds, 1299)
    db_push_msg.projectProgressUpdateMsgDb_notify(user_id, proj_code, linksTab, 1)
    local red = redis:new()
    red:set(conf_sys.sys_user_token["isHaveUnsendMsg"], "true")
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_LINK_SUBMIT_FAIL")
    ngx.say(cjson.encode(tab))
end

