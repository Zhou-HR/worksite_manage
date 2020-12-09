ngx.req.read_body()
local data = ngx.req.get_body_data()
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
local proj_type_value = decode_params["proj_type_value"]

if type(proj_code) ~= "string" or type(proj_type_value) ~= "number" then
  local tab = {}
  tab["result"]="参数错误"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

local status, apps = db_query.projectLink_get(proj_code)
if status == true and apps ~= nil and apps[1] ~= nil then
  local tab = {}
  tab["result"]="基站类型已确定无法修改"
  tab["error"]=error_table.get_error("ERROR_LINK_GEN_NOT_ALLOWED")
  ngx.say(cjson.encode(tab))
  return
end

status, apps = db_query.projectLink_gen(proj_code,proj_type_value)

if status == true then
	local tab = {} 
	tab["result"] = apps 
	tab["error"] = error_table.get_error("ERROR_NONE") 
	ngx.say(cjson.encode(tab))
else
	local tab = {} 
	tab["result"] = apps 
	tab["error"] = error_table.get_error("ERROR_LINK_GEN_FAILED") 
	ngx.say(cjson.encode(tab))
end

