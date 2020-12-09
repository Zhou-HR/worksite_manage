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
local newPasswd = decode_params["new_password"]
local oldPasswd = decode_params["old_password"]
local dev_request_type = comm_func.get_http_header("dev-request-type", ngx)

if type(newPasswd) ~= "string" or type(oldPasswd) ~= "string" or type(dev_request_type) ~= "string" then
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

if newPasswd == oldPasswd then
    local tab = {}
    tab["result"] = "新密码不能与旧密码相同"
    tab["error"] = error_table.get_error("ERROR_USER_PASSWORD_NEW_OLD_SAME")
    ngx.say(cjson.encode(tab))
    return
end

local userStatus, userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    if oldPasswd ~= userApps[1]["user_password"] then
        local tab = {}
        tab["result"] = "旧密码错误"
        tab["error"] = error_table.get_error("ERROR_USER_PASSWORD_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
else
    local tab = {}
    tab["result"] = "密码修改失败"
    tab["error"] = error_table.get_error("ERROR_USER_PASSWORD_CHANGE_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps = db_query.userPassword_update(user_id, oldPasswd, newPasswd)
if status == true then
    if apps[1] ~= nil and apps[1]["user_id"] ~= nil then
        --comm_func.delete_from_cache(user_id.."_token")
        local tokenStr = ngx.md5(tostring(ngx.now()) .. comm_func.generate_radom_str_cn(32))
        local tokenUpdateTime = math.ceil(ngx.now())
        local tokenExpiredTime = math.ceil(ngx.now()) + 2592000
        local innerTab = {}
        local devRequestType = nil
        if dev_request_type == "user_web" then
            db_query.userToken_update("user_web", tokenStr, tokenUpdateTime, tokenExpiredTime, apps[1]["user_id"])
            db_query.userToken_update("user_mobile", "", 0, 0, apps[1]["user_id"])
            innerTab["user_web_token"] = tokenStr
            devRequestType = "user_web"
        elseif dev_request_type == "user_mobile" or dev_request_type == "user_android" or dev_request_type == "user_ios" then
            db_query.userToken_update("user_web", "", 0, 0, apps[1]["user_id"])
            db_query.userToken_update("user_mobile", tokenStr, tokenUpdateTime, tokenExpiredTime, apps[1]["user_id"])
            innerTab["user_mobile_token"] = tokenStr
            devRequestType = "user_mobile"
        end
        --comm_func.update_http_token(devRequestType,apps[1]["user_id"],tokenStr,tokenExpiredTime,true)
        comm_func.update_http_token("user_web", apps[1]["user_id"], tokenStr, tokenExpiredTime, true)
        comm_func.update_http_token("user_mobile", apps[1]["user_id"], tokenStr, tokenExpiredTime, true)
        local tab = {}
        tab["result"] = innerTab
        tab["error"] = error_table.get_error("ERROR_NONE")
        ngx.say(cjson.encode(tab))
        return
    else
        local tab = {}
        tab["result"] = "密码错误"
        tab["error"] = error_table.get_error("ERROR_USER_PASSWORD_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
end

local tab = {}
tab["result"] = "密码修改失败"
tab["error"] = error_table.get_error("ERROR_USER_PASSWORD_CHANGE_FAILED")
ngx.say(cjson.encode(tab))
return
