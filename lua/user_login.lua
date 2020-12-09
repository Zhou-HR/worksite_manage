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
local user_name = decode_params["user_name"]
local user_number = decode_params["user_number"]
local user_password = decode_params["user_password"]
local dev_request_type = comm_func.get_http_header("dev-request-type", ngx)
if user_number == "worker" or user_number == "manager" or user_number == "admin" then
    user_name = user_number
end

if user_name ~= nil then
    user_name = comm_func.trim_string(user_name)
    if type(user_name) ~= "string" then
        local tab = {}
        tab["result"] = "参数错误"
        tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
end

if user_number ~= nil then
    user_number = comm_func.trim_string(user_number)
    if type(user_number) ~= "string" then
        local tab = {}
        tab["result"] = "参数错误"
        tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
end

if user_name == nil and user_number == nil then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if type(user_password) ~= "string" or type(dev_request_type) ~= "string" then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end
local isRecodLog = false
if user_name ~= nil then
    db_query.userOperationLog_add(user_name, ngx)
    isRecodLog = true
end

user_password = string.lower(user_password)
local status, apps = db_query.user_get(user_name, user_number)

if status == true then
    if isRecodLog == false then
        db_query.userOperationLog_add(apps[1]["user_name"], ngx)
        isRecodLog = true
    end
    if apps[1]["user_password"] == user_password then
        local tab = {}
        local innerTab = {}

        local tokenStr = ngx.md5(tostring(ngx.now()) .. comm_func.generate_radom_str_cn(32))
        local tokenUpdateTime = math.ceil(ngx.now())
        local tokenExpiredTime = math.ceil(ngx.now())
        if dev_request_type == "user_web" then
            tokenExpiredTime = tokenExpiredTime + 7200
        else
            tokenExpiredTime = tokenExpiredTime + 2592000
        end

        innerTab["user_id"] = apps[1]["user_id"]
        innerTab["user_name"] = apps[1]["user_name"]
        innerTab["user_mail"] = apps[1]["user_mail"]
        innerTab["user_phone"] = apps[1]["user_phone"]

        innerTab["user_number"] = apps[1]["user_number"]
        innerTab["user_bu_name"] = apps[1]["user_bu_name"]
        innerTab["user_bu_code"] = apps[1]["user_bu_code"]
        innerTab["user_job"] = apps[1]["user_job"]
        innerTab["user_code"] = apps[1]["user_code"]
        innerTab["user_entry_time"] = apps[1]["user_entry_time"]
        innerTab["user_company"] = apps[1]["user_company"]
        innerTab["user_company_code"] = apps[1]["user_company_code"]

        local requestType = nil
        local isClearBefore = false
        if dev_request_type == "user_web" then
            db_query.userToken_update("user_web", tokenStr, tokenUpdateTime, tokenExpiredTime, apps[1]["user_id"])
            innerTab["user_web_token"] = tokenStr
            requestType = "user_web"
            isClearBefore = false
        elseif dev_request_type == "user_mobile" or dev_request_type == "user_android" or dev_request_type == "user_ios" then
            db_query.userToken_update("user_mobile", tokenStr, tokenUpdateTime, tokenExpiredTime, apps[1]["user_id"])
            innerTab["user_mobile_token"] = tokenStr
            requestType = "user_mobile"
            isClearBefore = true
        end

        comm_func.update_http_token(requestType, apps[1]["user_id"], tokenStr, tokenExpiredTime, isClearBefore)
        innerTab["user_role"] = apps[1]["user_role"]

        tab["result"] = innerTab
        tab["error"] = error_table.get_error("ERROR_NONE")
        ngx.say(cjson.encode(tab))
        return
    else
        local tab = {}
        tab["result"] = "账号或密码错误"
        tab["error"] = error_table.get_error("ERROR_USER_NAME_OR_PASSWORD_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end


else
    if isRecodLog == false then
        db_query.userOperationLog_add(user_number, ngx)
        isRecodLog = true
    end

    local tab = {}
    tab["result"] = "账号不存在"
    tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS")
    ngx.say(cjson.encode(tab))
end

