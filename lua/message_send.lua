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
local user_ids = decode_params["user_ids"]
local title = decode_params["title"]
local content = decode_params["content"]
local content_type = decode_params["content_type"]

title = comm_func.trim_string(title)
if string.len(title) < 1 then
    local tab = {}
    tab["result"] = "title长度必须大于0"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if content_type ~= "text" and content_type ~= "multi" then
    local tab = {}
    tab["result"] = "content_type不合法"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

content["msg"] = comm_func.trim_string(content["msg"])
if string.len(content["msg"]) < 1 then
    local tab = {}
    tab["result"] = "content长度必须大于0"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if content_type == "multi" then
    local fileOk = false
    if content["files"] ~= nil and content["files"][1] ~= nil then
        for appsk, appsv in pairs(content["files"]) do
            if appsv["url"] ~= nil and string.len(appsv["url"]) > 0 then
                fileOk = true
            else
                fileOk = false
                break
            end
            if appsv["file_name"] ~= nil and string.len(appsv["file_name"]) > 0 then
                fileOk = true
            else
                fileOk = false
                break
            end
        end
    end
    if fileOk == false then
        local tab = {}
        tab["result"] = "附件参数不合法"
        tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
end

local status, apps, count, total = db_push_msg.usermsgDb_push(user_id, user_ids, title, content, content_type)

if status == true then
    local red = redis:new()
    red:set(conf_sys.sys_user_token["isHaveUnsendMsg"], "true")
    --comm_func.do_dump_value(red:get(conf_sys.sys_user_token["isHaveUnsendMsg"]),0)
    local tab = {}
    tab["result"] = "success"
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = "发送失败"
    tab["error"] = error_table.get_error("ERROR_MESSAGE_SEND_FAILED")
    ngx.say(cjson.encode(tab))
end

