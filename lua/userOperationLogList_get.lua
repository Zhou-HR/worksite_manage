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

local user_idHeader = comm_func.get_http_header("user_id", ngx)

local decode_params = decode_data["params"]
local user_id = decode_params["user_id"]
local user_name = decode_params["user_name"]
local api_name = decode_params["api_name"]
local api = decode_params["api"]
local fuzzy_searche_key = decode_params["fuzzy_searche_key"]
local limit = decode_params["limit"]
local offset = decode_params["offset"]

local paramsRight = true
local paramsErrorMsg
if paramsRight and user_id ~= nil and type(user_id) ~= "number" then
    paramsErrorMsg = "user_id必须是整形"
    paramsRight = false
end

if paramsRight and user_name ~= nil and type(user_name) ~= "string" then
    paramsErrorMsg = "user_name必须是字符串"
    paramsRight = false
end

if paramsRight and user_mail ~= nil and type(user_mail) ~= "string" then
    paramsErrorMsg = "user_maile必须是字符串"
    paramsRight = false
end

if paramsRight and api_name ~= nil and type(api_name) ~= "string" then
    paramsErrorMsg = "api_name必须是字符串"
    paramsRight = false
end

if paramsRight and api ~= nil and type(api) ~= "string" then
    paramsErrorMsg = "api必须是字符串"
    paramsRight = false
end

if paramsRight and fuzzy_searche_key ~= nil and type(fuzzy_searche_key) ~= "string" then
    paramsErrorMsg = "fuzzy_searche_key必须为字符串"
    paramsRight = false
elseif paramsRight == true then
    fuzzy_searche_key = comm_func.trim_string(fuzzy_searche_key)
    if fuzzy_searche_key == "" then
        fuzzy_searche_key = nil
    end
    if fuzzy_searche_key ~= nil and string.len(fuzzy_searche_key) < conf_sys.fuzzy_searche_key_length_min then
        paramsErrorMsg = "fuzzy_searche_key的长度不小于" .. tostring(conf_sys.fuzzy_searche_key_length_min)
        paramsRight = false
    end
end

if paramsRight == false then
    local tab = {}
    tab["result"] = paramsErrorMsg
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if type(limit) ~= "number" or limit <= 0 then
    limit = 10
end

if type(offset) ~= "number" or offset <= 0 then
    offset = 0
end

local user_bu_codeLike
local proj_bu_code
local user_company_code

local isAdmin = false
local userStatus, userApps = db_query.userFromId_get(user_idHeader)

if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    proj_bu_code = userApps[1]["user_bu_code"]
    user_bu_codeLike = proj_bu_code
    isAdmin = db_query.userAdmin_is(userApps[1], user_idHeader)

    if string.sub(proj_bu_code, string.len(proj_bu_code) - 1, string.len(proj_bu_code)) == "00" then
        user_bu_codeLike = string.sub(proj_bu_code, 1, 2)
    end
    if isAdmin == false then
        user_company_code = userApps[1]["user_company_code"]
    end
else
    local tab = {}
    tab["result"] = userApps
    tab["error"] = error_table.get_error("ERROR_LOG_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps, count, total = db_query.userOperationLogList_get(isAdmin, user_id, user_name, api, api_name, fuzzy_searche_key, limit, offset)
if status == true then
    local tab = {}
    local otherTab = {}
    otherTab["total"] = total
    otherTab["limit"] = limit
    otherTab["offset"] = offset
    otherTab["count"] = count
    tab["other"] = otherTab
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
    return
else
    local tab = {}
    tab["result"] = "获取用户列表失败"
    tab["error"] = error_table.get_error("ERROR_LOG_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end