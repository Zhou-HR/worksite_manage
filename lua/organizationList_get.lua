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
local o_name = decode_params["o_name"]
local o_code = decode_params["o_code"]
local o_parent_code = decode_params["o_parent_code"]
local o_parent_name = decode_params["o_parent_name"]

local dev_request_type = comm_func.get_http_header("dev-request-type", ngx)
local limit = decode_params["limit"]
local offset = decode_params["offset"]
local user_bu_code
local user_company_code

if type(limit) ~= "number" or limit <= 0 then
    limit = 10
end

if type(offset) ~= "number" or offset <= 0 then
    offset = 0
end

local paramsRight = true
local paramsErrorMsg
if paramsRight and o_name ~= nil and type(o_name) ~= "string" then
    paramsErrorMsg = "o_name必须是字符串"
    paramsRight = false
end

if paramsRight and o_code ~= nil and type(o_code) ~= "string" then
    paramsErrorMsg = "o_code必须是字符串"
    paramsRight = false
end

if paramsRight and o_parent_code ~= nil and type(o_parent_code) ~= "string" then
    paramsErrorMsg = "o_parent_code必须是字符串"
    paramsRight = false
end

if paramsRight and o_parent_name ~= nil and type(o_parent_name) ~= "string" then
    paramsErrorMsg = "o_parent_name必须是字符串"
    paramsRight = false
end

if paramsRight == false then
    local tab = {}
    tab["result"] = paramsErrorMsg
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if type(dev_request_type) ~= "string" then
    local tab = {}
    tab["result"] = "参数错误"
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
    user_bu_code = userApps[1]["user_bu_code"]
    user_company_code = userApps[1]["user_company_code"]
    if userApps[1]["user_role"] == 1 then
        user_bu_code = user_company_code
    end
    isAdmin = db_query.userAdmin_is(userApps[1], user_id)
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_ORGA_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps, count, total = db_query.organizationList_get(isAdmin, user_company_code, user_bu_code, o_name, o_code, o_parent_code, o_parent_name, limit, offset)

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
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_ORGA_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
end

