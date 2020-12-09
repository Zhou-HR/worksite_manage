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
local user_id = tonumber(user_idHeader)

local paramsRight = true
local paramsErrorMsg
if paramsRight and user_id ~= nil and type(user_id) ~= "number" then
    paramsErrorMsg = "user_id必须是整形"
    paramsRight = false
end

if paramsRight == false then
    local tab = {}
    tab["result"] = paramsErrorMsg
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local userStatus, userApps = db_query.userFromId_get(user_idHeader)

if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    local tab = {}
    local innerTab = {}

    innerTab["user_id"] = userApps[1]["user_id"]
    innerTab["user_name"] = userApps[1]["user_name"]
    innerTab["user_mail"] = userApps[1]["user_mail"]
    innerTab["user_phone"] = userApps[1]["user_phone"]

    innerTab["user_number"] = userApps[1]["user_number"]
    innerTab["user_bu_name"] = userApps[1]["user_bu_name"]
    innerTab["user_bu_code"] = userApps[1]["user_bu_code"]
    innerTab["user_job"] = userApps[1]["user_job"]
    innerTab["user_code"] = userApps[1]["user_code"]
    innerTab["user_entry_time"] = userApps[1]["user_entry_time"]
    innerTab["user_company"] = userApps[1]["user_company"]
    innerTab["user_company_code"] = userApps[1]["user_company_code"]
    innerTab["user_role"] = userApps[1]["user_role"]
    innerTab["user_erp_msg_receive"] = userApps[1]["user_erp_msg_receive"]

    tab["result"] = innerTab
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = "获取用户信息失败"
    tab["error"] = error_table.get_error("ERROR_USER_INFO_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end
