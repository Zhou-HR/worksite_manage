ngx.req.read_body()
local data = ngx.req.get_body_data()

local decode_data = cjson.decode(data)
if decode_data == nil then
    local tab = {}
    tab["result"] = "content must be json str!"
    tab["error"] = error_table.get_error("ERROR_REQUEST_CONTENT_MUST_BE_JSON")
    ngx.say(cjson.encode(tab))
    return
end

local decode_params = decode_data["params"]
local user_id = decode_params["user_id"]
local user_idHeader = comm_func.get_http_header("user_id", ngx)

local userIdValid = comm_func.do_check_user_id_valid(user_id)
if userIdValid == 0 then
    local tab = {}
    tab["result"] = "user_id不合法"
    tab["error"] = error_table.get_error("ERROR_USER_ID_INVALID")
    ngx.say(cjson.encode(tab))
    return
end

local isAdmin = false
local userStatus, userApps = db_query.userFromId_get(user_idHeader)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    isAdmin = db_query.userAdmin_is(userApps[1], user_idHeader)
else
    local tab = {}
    tab["result"] = "只有管理员能重置密码"
    tab["error"] = error_table.get_error("ERROR_USER_PASSWORD_RESET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

if tostring(user_id) == tostring(user_idHeader) then
    local tab = {}
    tab["result"] = "不能重置自己的密码"
    tab["error"] = error_table.get_error("ERROR_USER_PASSWORD_RESET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

--comm_func.do_dump_value(sqlStr,0)
local newPassword = comm_func.generate_radom_str_cn(6)
local newPasswordMd5 = ngx.md5(newPassword)
newPasswordMd5 = string.lower(newPasswordMd5)
local status, apps = db_query.reset_password(user_id, newPasswordMd5)

if status == true and apps ~= nil and apps[1] ~= nil then
    db_query.userToken_update("user_web", "", 0, 0, user_id)
    db_query.userToken_update("user_mobile", "", 0, 0, user_id)
    comm_func.update_http_token("user_web", user_id, "", 0, true)
    comm_func.update_http_token("user_mobile", user_id, "", 0, true)

    local tab = {}
    local newPass = {}
    newPass["user_id"] = user_id
    newPass["password"] = newPassword
    tab["result"] = newPass
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
    return
end
local tab = {}
tab["result"] = "重置密码失败"
tab["error"] = error_table.get_error("ERROR_USER_PASSWORD_RESET_FAILED")
ngx.say(cjson.encode(tab))
return
