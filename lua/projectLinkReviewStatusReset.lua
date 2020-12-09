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
local links = decode_params["links"]
local fines = decode_params["fines"]
local reset_reason = decode_params["reset_reason"]

local view_status = 0
local link_id = 0
ngx.log(ngx.ERR, "links: ", 1111111111111)
comm_func.do_dump_value(links, 0)
ngx.log(ngx.ERR, "fines: ", 1111111111111)
comm_func.do_dump_value(fines, 0)

local user_id = comm_func.get_http_header("user_id", ngx)
local proj_bu_code
local user_name

if type(proj_code) ~= "string" or type(links) ~= "table" or #links < 1 then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local linkIdTab = {}
local linkIdTabIndex = 1
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
        local isRight, msg = db_query.linkReview_check(v)
        if isRight == false then
            local tab = {}
            tab["result"] = msg
            tab["error"] = error_table.get_error("ERROR_LINK_INFO")
            ngx.say(cjson.encode(tab))
            return
        end

        view_status = v["proj_link_status"]
        link_id = v["proj_link_id"]
        ngx.log(ngx.ERR, "view_status: ", view_status)
        ngx.log(ngx.ERR, "proj_link_id: ", link_id)
        linkIdTab[linkIdTabIndex] = v["proj_link_id"]
        linkIdTabIndex = linkIdTabIndex + 1
    end
end

local userStatus, userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    --add by zhangjieqiong at 20200805 for reset list
    user_name = userApps[1]["user_name"]
    ngx.log(ngx.ERR, "----zjq------start insert to reset list user_name: ", user_name)
    if userApps[1]["user_role"] ~= 1045 then
        local tab = {}
        tab["result"] = "该账号无权限重置审核"
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

local status, apps, count, total
if proj_code ~= nil then
    --status, apps, count, total = db_query.projectList_get(proj_code,nil,nil,nil,nil,nil,nil,proj_bu_code,nil,false,1,0)
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
    for k, v in pairs(linkIdTab) do
        local isThisProj = false
        for appsk, appsv in pairs(apps) do
            if v == appsv["proj_link_id"] then
                if appsv["proj_link_status"] == 0 then
                    local tab = {}
                    tab["result"] = "工序:" .. tostring(v) .. ",尚未提交，不需要重置"
                    tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED")
                    ngx.say(cjson.encode(tab))
                    return
                elseif appsv["proj_link_status"] == 1 then
                    local tab = {}
                    tab["result"] = "工序:" .. tostring(v) .. "未审核，不需重置"
                    tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED")
                    ngx.say(cjson.encode(tab))
                    return
                end
                isThisProj = true
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
    end
else
    local tab = {}
    tab["result"] = "工序不存在"
    tab["error"] = error_table.get_error("ERROR_LINK_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

ngx.log(ngx.ERR, "----zjq------start reset status proj_link_id: ", link_id)
--Update tb_proj_link set proj_link_status = 1 where proj_code = 'GDJZAAAA201903YD' and proj_link_id = 598979
local status, apps = db_query.projectLink_review_reset(link_id, proj_code, user_id, user_name, reset_reason)

if status == true then
    local tab = {}
    tab["result"] = "重置审核状态成功"
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
    return
else
    local tab = {}
    tab["result"] = "重置审核状态失败"
    tab["error"] = error_table.get_error("ERROR_LINK_REVIEW_STATUS_RESET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

