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

local user_id = comm_func.get_http_header("user_id",ngx)

local userIdValid = comm_func.do_check_user_id_valid(user_id)
if userIdValid == 0 then
  local tab = {}
  tab["result"]="user_id不合法"
  tab["error"]=error_table.get_error("ERROR_USER_ID_INVALID")
  ngx.say(cjson.encode(tab))
  return
end
local isAdmin  = false
local userStatus,userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil  then
  isAdmin =  db_query.userAdmin_is(userApps[1],user_id) 
  if isAdmin == false then
    local tab = {} 
    tab["result"] = "您无权限" 
    tab["error"] = error_table.get_error("ERROR_USER_PERMISSION_REFUSE") 
    ngx.say(cjson.encode(tab))
    return
  end
end
local status, apps = db_project.projectGlobalConf_get()
if status == true then
	local tab = {} 
	local confTab = {}
	confTab["proj_link_max_distan"] = 200
	confTab["proj_link_max_distan"] = 5
  confTab["proj_link_pic_max_num"] = apps[1]["proj_link_pic_max_num"]
	if apps ~= nil and apps[1] ~= nil then
	  confTab["proj_link_max_distan"] = apps[1]["proj_link_max_distan"]
	  confTab["proj_link_pic_max_num"] = apps[1]["proj_link_pic_max_num"]
	end
	tab["result"] = confTab 
	tab["error"] = error_table.get_error("ERROR_NONE") 
	ngx.say(cjson.encode(tab))
else
	local tab = {} 
	tab["result"] = apps 
	tab["error"] = error_table.get_error("ERROR_PROJ_GLOBAL_CONFIG_GET_FAILED") 
	ngx.say(cjson.encode(tab))
end

