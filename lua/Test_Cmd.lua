ngx.req.read_body()
local data = ngx.req.get_body_data()

local decode_data = cjson.decode(data)
if decode_data == nil then
	local tab = {} 
	tab["result"]="content must be json str!"
	tab["error"]=error_table.get_error("ERROR_TEST_CMD_INVALID")
	ngx.say(cjson.encode(tab))
	return
end

local red = redis:new()
local cmdData = red:rpush("hate_mid_test_cmds",data)

local tab = {} 
tab["result"]="OK"
tab["error"]=error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))
return

