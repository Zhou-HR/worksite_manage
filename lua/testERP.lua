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
local msg_sender_number = decode_params["msg_sender_number"]
local msg_receiver_number = decode_params["msg_receiver_number"]
local msg_send_time_text = decode_params["msg_send_time_text"]
local msg_title = decode_params["msg_title"]
local msg_content = decode_params["msg_content"]

local status2, app = db_query.msg_erp_test(msg_sender_number, msg_receiver_number, msg_send_time_text, msg_title, msg_content)

--local status1,apps = db_query.msg_erp_test_back(msg_sender_number)

if status2 then
    local tab = {}
    tab["result"] = "发送成功"
    --apps[1]["content"] = cjson.decode(apps[1]["content"])
    --apps[1]["extras"] = cjson.decode(apps[1]["extras"])
    --apps[1]["receivers"] = cjson.decode(apps[1]["receivers"])
    --tab["发送者"] = apps[1]["sender_name"]
    --tab["发送者ID"] = apps[1]["sender_id"]
    --tab["发送者Num"] = apps[1]["sender_number"]
    --local receiver = apps[1]["receivers"]
    --tab["接收者"] = receiver[1]["user_name"]
    --tab["接收者ID"] = receiver[1]["user_id"]
    --tab["接收者Num"] = receiver[1]["user_number"]
    --local msg = apps[1]["content"]
    --tab["发送信息标题"] = apps[1]["title"]
    --tab["信息内容"] = msg["msg"]
    --local curtime = os.date("%Y-%m-%d %H:%M:%S", apps[1]["send_time"])
    --tab["发送时间"] = curtime
    ngx.say(cjson.encode(tab))
end
