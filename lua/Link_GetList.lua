ngx.req.read_body()
local data = ngx.req.get_body_data()

local decode_data = cjson.decode(data)


local status, apps = db_query.Link_get_list()

if status == true then
	local tab = {} 
	tab["result"] = apps 
	tab["error"] = error_table.get_error("ERROR_NONE") 
	ngx.say(cjson.encode(tab))
else
	local tab = {} 
	tab["result"] = apps 
	tab["error"] = 1
	ngx.say(cjson.encode(tab))
end

