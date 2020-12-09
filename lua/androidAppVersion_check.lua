ngx.req.read_body()
local data = ngx.req.get_body_data()
local headers = ngx.req.get_headers()
local decode_data = cjson.decode(data)
if decode_data == nil then
  local tab = {}
  tab["result"]="参数必须是JSON格式"
  tab["error"]=error_table.get_error("ERROR_JSON_WRONG")
  ngx.say(cjson.encode(tab))
  return
end


local decode_params = decode_data["params"]
local proj_code = decode_params["proj_code"]


local dev_info  = headers["dev_info"]
local dev_model  = headers["dev_model"]
local dev_version  = headers["dev_version"]
local dev_app_version  = headers["dev_app_version"]

local status, apps = db_android_version.version_new_get(dev_app_version)

if status == true  then
	local tab = {} 
	tab["result"] = apps
	tab["error"] = error_table.get_error("ERROR_NONE") 
	ngx.say(cjson.encode(tab))
else
	local tab = {} 
	tab["result"] = apps 
	tab["error"] = error_table.get_error("ERROR_ANDROID_UPDATE_CHECK_FAILED") 
	ngx.say(cjson.encode(tab))
end

