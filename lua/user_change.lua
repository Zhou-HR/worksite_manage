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
-----user selt to change
local user_mail = decode_params["user_mail"]
local user_phone = decode_params["user_phone"]
-----other to change
local user_role = decode_params["user_role"]
local user_number = decode_params["user_number"]
local user_bu_name = decode_params["user_bu_name"]
local user_bu_code = decode_params["user_bu_code"]
local user_job = decode_params["user_job"]
local user_code = decode_params["user_code"]
local user_entry_time = decode_params["user_entry_time"]
local user_company = decode_params["user_company"]
local user_company_code = decode_params["user_company_code"]

local updateKeyNumber = 0000000000
local paramsRight = true
local paramsErrorMsg
if paramsRight and user_id == nil or type(user_id) ~= "number" then
    paramsErrorMsg = "user_id必须是整形"
    paramsRight = false
end

if paramsRight and user_mail ~= nil then
    if type(user_mail) ~= "string" then
        paramsErrorMsg = "user_maile必须是字符串"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight and user_phone ~= nil then
    if type(user_phone) ~= "string" then
        paramsErrorMsg = "user_phone必须是字符串"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight and user_role ~= nil then
    if type(user_role) ~= "number" then
        paramsErrorMsg = "user_role必须是整形"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if user_number ~= nil then
    local tab = {}
    tab["result"] = "工号不能修改"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if paramsRight and user_number ~= nil then
    if type(user_number) ~= "string" then
        paramsErrorMsg = "user_number必须是字符串"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight and user_bu_name ~= nil then
    if type(user_bu_name) ~= "string" then
        paramsErrorMsg = "user_bu_name必须是字符串"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight and user_bu_code ~= nil then
    if type(user_bu_code) ~= "string" then
        paramsErrorMsg = "user_bu_code必须是字符串"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight and user_job ~= nil then
    if type(user_job) ~= "string" then
        paramsErrorMsg = "user_job必须是字符串"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight and user_code ~= nil then
    if type(user_code) ~= "string" then
        paramsErrorMsg = "user_code必须是字符串"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight and user_entry_time ~= nil then
    if type(user_entry_time) ~= "string" then
        paramsErrorMsg = "user_entry_time必须是字符串"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight and user_company ~= nil then
    if type(user_company) ~= "string" then
        paramsErrorMsg = "user_company必须是字符串"
        paramsRight = false
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight and user_company_code ~= nil then
    if type(user_company_code) ~= "string" then
        paramsErrorMsg = "user_company_code必须是字符串"
        paramsRight = false
    else
        local result, apps = db_user.organization_get(user_company_code)
        comm_func.do_dump_value(apps, 0)
        if result == true and apps ~= nil and apps[1] ~= nil then
            user_company = apps[1]["o_name"]
        end
    end
    updateKeyNumber = updateKeyNumber + 1
end

if paramsRight == false then
    local tab = {}
    tab["result"] = paramsErrorMsg
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if updateKeyNumber == 0 then
    local tab = {}
    tab["result"] = "无修改内容"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local user_bu_codeLike
local proj_bu_code

local isAdmin = false
local userStatus, userApps = db_query.userFromId_get(user_idHeader)
local userBodyStatus, userBodyApps = db_query.userFromId_get(user_id)

if userBodyStatus == true and userBodyApps ~= nil and userBodyApps[1] ~= nil then
    local checkOk = true
    local errorMsg
    isAdmin = db_query.userAdmin_is(userApps[1], user_id)
    if isAdmin == true then
        checkOk = true
    else
        if userBodyApps[1]["user_company_code"] ~= userApps[1]["user_company_code"] then
            checkOk = false
            errorMsg = "该用户与您不在同一个省公司无法修改"
        end

        if checkOk == true then
            if userApps[1]["user_role"] > userBodyApps[1]["user_role"] and userApps[1]["user_id"] ~= userBodyApps[1]["user_id"] then
                checkOk = false
                errorMsg = "无权限修改"
            end
            local userBuCode = userApps[1]["user_bu_code"]
            if checkOk == true and userApps[1]["user_role"] == 1 then
                if user_bu_code ~= nil and string.sub(userBuCode, 1, 2) ~= string.sub(user_bu_code, 1, 2) then
                    checkOk = false
                    errorMsg = "只能修改为本公司中的部门"
                end
            end

            if checkOk == true and userApps[1]["user_role"] == 2 then
                if user_bu_code ~= nil and userBuCode ~= user_bu_code then
                    checkOk = false
                    errorMsg = "只能修改为本部门"
                end
            end

            if checkOk == true and userApps[1]["user_role"] == 3 then
                if userApps[1]["user_id"] ~= userBodyApps[1]["user_id"] then
                    checkOk = false
                    errorMsg = "只能修改自己的信息"
                end
            end
            local newUser_role = db_query.userRoleValue_get(user_role)
            local newUserAppsRole = db_query.userRoleValue_get(userApps[1]["user_role"])
            if checkOk == true and user_role ~= nil and ((user_role < userApps[1]["user_role"]) or (userApps[1]["user_role"] == 1 and user_role > 1000 and user_role < 1100)) then
                --if checkOk == true and user_role ~= nil and user_role < userApps[1]["user_role"] then
                checkOk = false
                errorMsg = "只能修改为权限等于或低于自己"
            end

            if checkOk == true and userApps[1]["user_id"] ~= userBodyApps[1]["user_id"] then
                if user_mail ~= nil or user_phone ~= nil then
                    checkOk = false
                    errorMsg = "不能修改电话和邮箱"
                end
            end

            if checkOk == true and userApps[1]["user_id"] == userBodyApps[1]["user_id"] then
                local user_role = decode_params["user_role"]
                local user_number = decode_params["user_number"]
                local user_bu_name = decode_params["user_bu_name"]
                local user_bu_code = decode_params["user_bu_code"]
                local user_job = decode_params["user_job"]
                local user_code = decode_params["user_code"]
                local user_entry_time = decode_params["user_entry_time"]
                local user_company = decode_params["user_company"]
                local user_company_code = decode_params["user_company_code"]

                if user_role ~= nil or user_number ~= nil or user_bu_name ~= nil or user_bu_code ~= nil or user_job ~= nil or user_code ~= nil or user_entry_time ~= nil or user_company ~= nil or user_company_code ~= nil then
                    checkOk = false
                    errorMsg = "不能修改自己的人事信息"
                end
            end

        end
    end
    if checkOk == false then
        local tab = {}
        tab["result"] = errorMsg
        tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
else
    local tab = {}
    tab["result"] = "user_id不存在"
    tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps = db_query.user_update(user_id, user_mail, user_phone, user_role, user_number, user_bu_name, user_bu_code, user_job, user_code, user_entry_time, user_company, user_company_code)
if status == true then
    local tab = {}
    tab["result"] = user_id
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
    return
else
    local tab = {}
    tab["result"] = "修改用户失败"
    tab["error"] = error_table.get_error("ERROR_USER_UPDATE_FAILED")
    ngx.say(cjson.encode(tab))
    return
end
