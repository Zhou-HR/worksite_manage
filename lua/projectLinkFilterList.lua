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

local proj_module_code = decode_params["proj_module_code"]



if proj_module_code ~= nil and type(proj_module_code) ~= "string" then
  local tab = {}
  tab["result"]="proj_module_code必须为字符串"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end


local status,apps=db_query.selectLinkFilter(proj_module_code);
if status == true then
  local tab = {}
  tab["result"] = apps
  tab["error"] = error_table.get_error("ERROR_NONE")
  ngx.say(cjson.encode(tab))
  return
else
  local tab = {}
  tab["result"] = "获取一级工序记录列表内容失败"
  tab["error"] = error_table.get_error("ERROR_LINK_REVIEW_STATUS_RESET_GET_FAILED")
  ngx.say(cjson.encode(tab))
  return
end
