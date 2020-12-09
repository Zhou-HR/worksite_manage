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
local user_mail = decode_params["user_mail"]
local user_phone = decode_params["user_phone"]
local user_role = decode_params["user_role"]
local user_number = decode_params["user_number"]
local user_bu_name = decode_params["user_bu_name"]
local user_bu_code = decode_params["user_bu_code"]
local user_job = decode_params["user_job"]
local user_code = decode_params["user_code"]
local user_entry_time = decode_params["user_entry_time"]
local user_company = decode_params["user_company"]
local user_company_code = decode_params["user_company_code"]
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

if paramsRight and user_phone ~= nil and type(user_phone) ~= "string" then
    paramsErrorMsg = "user_phone必须是字符串"
    paramsRight = false
end

if paramsRight and user_role ~= nil and type(user_role) ~= "number" then
    paramsErrorMsg = "user_role必须是整形"
    paramsRight = false
end

if paramsRight and user_number ~= nil and type(user_number) ~= "string" then
    paramsErrorMsg = "user_number必须是字符串"
    paramsRight = false
end

if paramsRight and user_bu_name ~= nil and type(user_bu_name) ~= "string" then
    paramsErrorMsg = "user_bu_name必须是字符串"
    paramsRight = false
end

if paramsRight and user_bu_code ~= nil and type(user_bu_code) ~= "string" then
    paramsErrorMsg = "user_bu_code必须是字符串"
    paramsRight = false
end

if paramsRight and user_job ~= nil and type(user_job) ~= "string" then
    paramsErrorMsg = "user_job必须是字符串"
    paramsRight = false
end

if paramsRight and user_code ~= nil and type(user_code) ~= "string" then
    paramsErrorMsg = "user_code必须是字符串"
    paramsRight = false
end

if paramsRight and user_entry_time ~= nil and type(user_entry_time) ~= "string" then
    paramsErrorMsg = "user_entry_time必须是字符串"
    paramsRight = false
end

if paramsRight and user_company ~= nil and type(user_company) ~= "string" then
    paramsErrorMsg = "user_company必须是字符串"
    paramsRight = false
end

if paramsRight and user_company_code ~= nil and type(user_company_code) ~= "string" then
    paramsErrorMsg = "user_company_code必须是字符串"
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

local isAdmin = false
local userStatus, userApps = db_query.userFromId_get(user_idHeader)

if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    proj_bu_code = userApps[1]["user_bu_code"]
    user_bu_codeLike = proj_bu_code
    user_bu_codeLike = comm_func.buprovince_get(proj_bu_code)
    isAdmin = db_query.userAdmin_is(userApps[1], user_idHeader)

    if string.sub(proj_bu_code, string.len(proj_bu_code) - 1, string.len(proj_bu_code)) == "00" then
        user_bu_codeLike = string.sub(proj_bu_code, 1, 2)
    end
    if isAdmin == false then
        user_company_code = userApps[1]["user_company_code"]
    end
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_USER_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps, count, total = db_query.userList_get(isAdmin, user_bu_codeLike, user_id, user_name, user_mail, user_phone, user_role, user_number, user_bu_name, user_bu_code, user_job, user_code, user_entry_time, user_company, user_company_code, fuzzy_searche_key, limit, offset)
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
    tab["error"] = error_table.get_error("ERROR_USER_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end