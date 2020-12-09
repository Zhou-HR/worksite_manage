local uri_args = ngx.req.get_uri_args()
 
local appEUI = uri_args["appEUI"]
local token = uri_args["token"]
local time_s = uri_args["time_s"]
--connectFlag
--1:to connect
--0:disconnect
local connectFlag = uri_args["connectFlag"]
connectFlag = tonumber(connectFlag)

local userSec = uri_args["userSec"]
local accessKey = uri_args["accessKey"]
if userSec == nil  or  string.len(userSec) ~= 32 then
	local result = {}
	result["error"] = error_table.get_error("ERROR_USERSEC_INVALID")
	result["result"]= "userSec must set!"
	ngx.say(cjson.encode(result))
	ngx.eof()
	return
end

if accessKey == nil  or  string.len(accessKey) ~= 32 then
	local result = {}
	result["error"] = error_table.get_error("ERROR_ACCESS_KEY_INVALID")
	result["result"]= "accessKey must set!"
	ngx.say(cjson.encode(result))
	ngx.eof()
	return
end

--local WEBSOCKET_URL="ws://114.215.192.141:92/webs?"
local WEBSOCKET_URL="ws://115.29.186.49:92/webs?"
local nowTimeGen = 0.0
local LIST_LORA_UP = "hate_mid_rx_"
local LIST_LORA_DOWN = "hate_mid_tx_"
local MID_LATEST_TMST = "hate_mid_tmst_"
local MID_USER_CMD = "hate_mid_cmd_"
local MID_USER_USERCEC = "hate_mid_usersec_"
local MID_RECONNECT_PARAMWTER = "hate_mid_param_"
local MID_ACCESS_KEY = "hate_mid_access_key_"
local MID_CMD_START = "start"
local MID_CMD_STOP = "stop"

local DATA_KEY = "hate_mid_data_view"
local IS_DEBUG = false

if connectFlag == 0 then
	local red = redis:new()
	red:set(MID_USER_CMD..appEUI,MID_CMD_STOP)
	ngx.shared.token_cache:delete(appEUI)
	local result = {}
	result["error"] = error_table.get_error("ERROR_NONE")
	result["result"]= "websocket will disconnected"
	ngx.say(cjson.encode(result))
	ngx.eof()
	return
end

if comm_func.get_from_cache(appEUI)~= nil then
	ngx.log(ngx.ERR, "appEUI already in listen: ", appEUI)
	
	local tab = {} 
	tab["result"]="Instance already exists!"
	tab["error"]=error_table.get_error("ERROR_INSTANCE_APPEUI_ALREADY_EXISTS")
	ngx.say(cjson.encode(tab))
	ngx.eof()
	return 
end
ngx.log(ngx.ERR, "appEUI connecting: ", appEUI)

--create connection
local wb, err = client:new()
 
local uri = WEBSOCKET_URL.."appEUI="..appEUI.."&token="..token.."&time_s="..time_s
wb:set_timeout(5000)
local ok, err = wb:connect(uri)
	
--create success
if not ok then
	ngx.log(ngx.ERR, "failed to new websocket: ", err)
	
	local tab = {} 
	tab["result"]="Instance start fail!"
	tab["error"]=error_table.get_error("ERROR_INSTANCE_STARTUP_FAIL")
	ngx.say(cjson.encode(tab))
	ngx.eof()
	return
end

comm_func.set_to_cache(appEUI, token)

LIST_LORA_UP = LIST_LORA_UP..appEUI
LIST_LORA_DOWN = LIST_LORA_DOWN..appEUI
MID_LATEST_TMST = MID_LATEST_TMST..appEUI
MID_USER_CMD = MID_USER_CMD..appEUI
MID_RECONNECT_PARAMWTER = MID_RECONNECT_PARAMWTER..appEUI
MID_ACCESS_KEY = MID_ACCESS_KEY..appEUI
if true then
	MID_USER_USERCEC = MID_USER_USERCEC..appEUI
	local red = redis:new()
	--red:set(MID_USER_USERCEC,"65363030e5f402b0fc1f850bed68a05d")
	red:set(MID_USER_USERCEC,userSec)
	red:set(MID_USER_CMD,MID_CMD_START)
	red:set(MID_ACCESS_KEY,accessKey)
	red:set(MID_RECONNECT_PARAMWTER,"appEUI="..appEUI.."&token="..token.."&time_s="..time_s.."&connectFlag=1&userSec="..userSec.."&accessKey="..accessKey)
end

local push = function()
    -- --create redis
    local red = redis:new()
	local isRunning = true
    while isRunning do
		local connectedFlag =  red:get(MID_USER_CMD)
		if connectedFlag == MID_CMD_STOP then
			ngx.log(ngx.ERR, "will disconnected:", connectedFlag)
			ngx.shared.token_cache:delete(appEUI)
			isRunning = false
		else
			local rxdata, err = red:blpop(LIST_LORA_DOWN,1)
			while not err and rxdata ~= nil do
				--comm_func.do_dump_value(rxdata[2],0)
				local bytes, err = wb:send_text(rxdata[2])
				comm_func.do_dump_value("sending text",0)
				comm_func.do_dump_value(rxdata,0)
				if not bytes then
					ngx.log(ngx.ERR, "failed to send text: ", err)
					ngx.shared.token_cache:delete(appEUI)
					isRunning = false
					if IS_DEBUG then
						red:rpush(DATA_KEY,"TX:Fail!")
					end
				else
					if IS_DEBUG then
						red:rpush(DATA_KEY,"TX:"..rxdata[2])
					end
				end
				rxdata, err = red:blpop(LIST_LORA_DOWN,1)
			end
		end
    end
end
 
local co = ngx.thread.spawn(push)
local redMain = redis:new()

local tab = {}
tab["result"]="OK"
tab["error"]=error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))
ngx.eof()

local isRunning = true
while isRunning do
	local connectedFlag =  redMain:get(MID_USER_CMD)
	if connectedFlag == MID_CMD_STOP then
		ngx.log(ngx.ERR, "will do disconnected:", connectedFlag)
		ngx.shared.token_cache:delete(appEUI)
		isRunning = false
	else
		local data, typ, err0 = wb:recv_frame()
		--comm_func.do_dump_value(data,0)
		--comm_func.do_dump_value(typ,0)
		--comm_func.do_dump_value(data,0)
		if wb.fatal then
			ngx.log(ngx.ERR, "failed to receive frame: ", err)
			ngx.log(ngx.ERR, "deleting appEUI",appEUI)
			ngx.shared.token_cache:delete(appEUI)
			ngx.log(ngx.ERR, "deleting appEUI success",appEUI)
			isRunning = false
		end

		if not data then
			local bytes, err = wb:send_ping()
			if not bytes then
			  ngx.log(ngx.ERR, "failed to send ping: ", err)
			  ngx.shared.token_cache:delete(appEUI)
			  isRunning = false
			end
			--ngx.log(ngx.ERR, "send ping: ", data)
		elseif typ == "close" then
			ngx.log(ngx.ERR, "client send close")
			ngx.shared.token_cache:delete(appEUI)
			isRunning = false
		elseif typ == "ping" then
			comm_func.set_to_cache(appEUI, token, ngx.now() + 8)
			local bytes, err = wb:send_pong()
			if not bytes then
				ngx.log(ngx.ERR, "failed to send pong: ", err)
				ngx.shared.token_cache:delete(appEUI)
				isRunning = false
			end
			local nowTMST = ngx.now()
			redMain:set(MID_LATEST_TMST,tostring(nowTMST))
		elseif typ == "pong" then
			--ngx.log(ngx.ERR, "client ponged")
			local nowTMST = ngx.now()
			redMain:set(MID_LATEST_TMST,tostring(nowTMST))
		elseif typ == "text" then
			redMain:rpush(LIST_LORA_UP,data)
			if IS_DEBUG then
				redMain:rpush(DATA_KEY,"RX:"..data)
			end
		end
	end
end
 
wb:send_close()
ngx.shared.token_cache:delete(appEUI)

ngx.thread.wait(co)
