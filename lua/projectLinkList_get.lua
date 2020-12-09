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
local proj_name = decode_params["proj_name"]
local proj_link_name = decode_params["proj_link_name"]
local proj_module_name = decode_params["proj_module_name"]

local proj_link_status = decode_params["proj_link_status"]
local fuzzy_searche_key = decode_params["fuzzy_searche_key"]
local proj_bu_code
local proj_company_code
local dev_request_type = comm_func.get_http_header("dev-request-type", ngx)
local limit = decode_params["limit"]
local offset = decode_params["offset"]

ngx.log(ngx.ERR, "proj_link_status: ", proj_link_status)
if type(limit) ~= "number" or limit <= 0 then
    limit = 10
end

if type(offset) ~= "number" or offset <= 0 then
    offset = 0
end

if type(dev_request_type) ~= "string" then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_link_status ~= nil and type(proj_link_status) ~= "number" then
    local tab = {}
    tab["result"] = "proj_link_status必须为整形"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_code ~= nil and type(proj_code) ~= "string" then
    local tab = {}
    tab["result"] = "proj_code必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_name ~= nil and type(proj_name) ~= "string" then
    local tab = {}
    tab["result"] = "proj_name必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_link_name ~= nil and type(proj_link_name) ~= "string" then
    local tab = {}
    tab["result"] = "proj_link_name必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_module_name ~= nil and type(proj_module_name) ~= "string" then
    local tab = {}
    tab["result"] = "proj_module_name必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end
if fuzzy_searche_key ~= nil and type(fuzzy_searche_key) ~= "string" then
    local tab = {}
    tab["result"] = "fuzzy_searche_key必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
else
    fuzzy_searche_key = comm_func.trim_string(fuzzy_searche_key)
    if fuzzy_searche_key == "" then
        fuzzy_searche_key = nil
    end
    if fuzzy_searche_key ~= nil and string.len(fuzzy_searche_key) < conf_sys.fuzzy_searche_key_length_min then
        local tab = {}
        tab["result"] = "fuzzy_searche_key的长度不小于" .. tostring(conf_sys.fuzzy_searche_key_length_min)
        tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
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
    proj_company_code = userApps[1]["user_company_code"]
    isAdmin = db_query.userAdmin_is(userApps[1], user_id)
    if isAdmin == true then
        proj_bu_code = nil
        proj_company_code = nil
    end
    if userApps[1]["user_role"] == 1 then
        proj_bu_code = string.sub(userApps[1]["user_bu_code"], 1, 2)
    else
        proj_bu_code = comm_func.buprovince_get(proj_bu_code)
    end
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_LINK_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps, count, total = db_query.projectLinkList_get(proj_code, proj_name, proj_bu_code, proj_company_code, proj_link_status, proj_link_name, proj_module_name, fuzzy_searche_key, isAdmin, limit, offset)

if status == true then
    local tab = {}
    local otherTab = {}
    for k, v in pairs(apps) do
        apps[k]["proj_link_pic"] = cjson.decode(apps[k]["proj_link_pic"])
    end

    local urlindex
    local newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
    for k, v in pairs(apps) do
        for m in pairs(apps[k]["proj_link_pic"]) do
            urlindex = string.find(apps[k]["proj_link_pic"][m]["pic"], "com", 1)
            newurl = newurl .. string.sub(apps[k]["proj_link_pic"][m]["pic"], urlindex, string.len(apps[k]["proj_link_pic"][m]["pic"]))
            apps[k]["proj_link_pic"][m]["pic"] = newurl
            newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
        end
    end
    otherTab["total"] = total
    otherTab["limit"] = limit
    otherTab["offset"] = offset
    otherTab["count"] = count
    tab["other"] = otherTab
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_LINK_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
end

