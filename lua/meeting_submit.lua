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
local meeting_info = decode_params["meeting_info"]
local request_time = decode_params["request_time"]
local user_id = comm_func.get_http_header("user_id", ngx)
local meeting_bu_code

local meetIdTab = {}
local meetIdTabIndex = 1

local isRight, msg = db_query.meetInfo_check(meeting_info) --检验数据是否类型符合
if isRight == false then
    local tab = {}
    tab["result"] = msg
    tab["error"] = error_table.get_error("ERROR_MEET_INFO")
    ngx.say(cjson.encode(tab))
    return
end
if type(request_time) == "number" then
    local status, res = db_query.meetingRequestTime_get(user_id, request_time)
    if status == true and res ~= nil and res[1] ~= nil then
        local tab = {}
        tab["result"] = "本会议已经提交过"
        tab["error"] = error_table.get_error("ERROR_MEET_INFO_ALREADY_EXISTS")
        ngx.say(cjson.encode(tab))
        return
    end
else
    request_time = nil
end

for m in pairs(meeting_info["meeting_pic"]) do
    local file_url = meeting_info["meeting_pic"][m]["pic"]
    local newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
    local urlindex = string.find(file_url, "com", 1)
    local file_url_chk = string.sub(file_url, 0, urlindex - 1)
    if newurl ~= file_url_chk then
        local tab = {}
        tab["result"] = "上传失败,请更新当前版本"
        tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
end

local userStatus, userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    --  if userApps[1]["user_role"] ~= 2 then
    --    local tab = {}
    --   tab["result"] = "该账号无权限提交"
    --    tab["error"] = error_table.get_error("ERROR_USER_PERMISSION_REFUSE")
    --    ngx.say(cjson.encode(tab))
    --    return
    --  end
    meeting_bu_code = userApps[1]["user_bu_code"]
    meeting_bu_code = comm_func.buprovince_get(meeting_bu_code)
else
    local tab = {}
    tab["result"] = "用户不存在"
    tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps = db_query.meeting_submit(meeting_info, request_time)
if status == true and apps ~= nil then
    local tab = {}
    local result = { {} }
    result[1]["meeting_links_update"] = "true"
    result[1]["request_time"] = request_time
    tab["result"] = result
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
end
