ngx.req.read_body()
local data = ngx.req.get_body_data()
local headers = ngx.req.get_headers()
comm_func.do_dump_value(headers,0)	

local tab = {}
local decode_data = cjson.decode(data)
if decode_data == nil then
  tab["result"]="参数必须是JSON格式"
  tab["error"]=error_table.get_error("ERROR_JSON_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

local decode_params = decode_data["params"]
local proj_code        = decode_params["proj_code"]
local user_id = headers["user_id"]

ngx.log(ngx.ERR, "project_status_set proj_code: ", proj_code)
ngx.log(ngx.ERR, "project_status_set user_id: ", user_id)

if (proj_code         == nil or type(proj_code        ) ~= "string" ) then
  tab["result"]="params必须为字符串"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if (user_id   == nil or type(user_id ) ~= "number" ) then
  tab["result"]="user_id 必须为整型"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if (user_id   ~= nil or type(user_id ) ~= "number" ) then
  tab["result"]="user_id 必须为整型"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

local statusinfo = {}
statusinfo["status"] = 0 
local status, apps = db_meter.project_status_set(proj_code)
if status == true then
	comm_func.do_dump_value(apps,0)	
	statusinfo["status"] = apps 
	tab["result"] = statusinfo 
	tab["error"]=error_table.get_error("ERROR_NONE")
	tab["description"]="SUCCESS"
	
	ngx.say(cjson.encode(tab))
	return
end

tab["result"] = statusinfo 
tab["error"]=error_table.get_error("ERROR_NONE")
tab["description"]="ERROR_NONE"
ngx.say(cjson.encode(tab))
