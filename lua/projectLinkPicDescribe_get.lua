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

local user_idHeader = comm_func.get_http_header("user_id",ngx)

local decode_params = decode_data["params"]
local user_id = tonumber( user_idHeader)



local userStatus,userApps = db_project.linkDescribe_get()

if userStatus == true and userApps ~= nil and userApps[1] ~= nil  then
    local tab = {} 
    
    tab["result"]=userApps[1]
    tab["error"]=error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
  local tab = {}
  tab["result"] = "获取工序拍照要点说明失败"
  tab["error"] = error_table.get_error("ERROR_PROJ_LINK_PIC_DESCRIBE_GET_FAILED")
  ngx.say(cjson.encode(tab))
  return
end