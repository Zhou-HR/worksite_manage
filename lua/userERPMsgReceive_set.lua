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
local user_erp_msg_receive = decode_params["user_erp_msg_receive"]

local paramsRight = true
local paramsErrorMsg
if paramsRight and user_id ~= nil and type(user_id) ~= "number" then
    paramsErrorMsg = "user_id必须是整形"
    paramsRight = false
end

if paramsRight and user_erp_msg_receive ~= 0 and user_erp_msg_receive ~= 1 then
    paramsErrorMsg = "user_erp_msg_receive必须是0或1"
    paramsRight = false
end

if paramsRight == false then
    local tab = {}
    tab["result"] = paramsErrorMsg
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local userStatus, userApps = db_user.user_update(user_id, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, user_erp_msg_receive)

if userStatus == true then
    local tab = {}
    local innerTab = {}

    innerTab["user_id"] = user_id
    innerTab["user_erp_msg_receive"] = user_erp_msg_receive

    tab["result"] = innerTab
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    if user_erp_msg_receive == 0 then
        tab["result"] = "关闭ERP消息通知失败"
    else
        tab["result"] = "开启ERP消息通知失败"
    end
    tab["error"] = error_table.get_error("ERROR_USER_ERP_MSG_RECEIVE_SET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end