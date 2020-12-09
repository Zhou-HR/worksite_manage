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
local limit = decode_params["limit"]
local offset = decode_params["offset"]
local proj_company_code = decode_params["proj_company_code"]
local proj_link_status = decode_params["proj_link_status"]
local proj_module_code = decode_params["proj_module_code"]
local proj_link_type = decode_params["proj_link_type"]
local fuzzy_searche_key  = decode_params["fuzzy_searche_key"]
local submit_start_time = decode_params["submit_start_time"]
local submit_end_time = decode_params["submit_end_time"]
local examine_start_time = decode_params["examine_start_time"]
local examine_end_time = decode_params["examine_end_time"]
local user_id = comm_func.get_http_header("user_id",ngx)
local is_download = decode_params["is_download"]
local proj_bu_code

if is_download ~= nil and is_download == true then

else
  is_download = false
end

local dev_request_type = comm_func.get_http_header("dev-request-type",ngx)
if type(limit) ~= "number" or limit <= 0 then
  limit = 10
end

if type(offset) ~= "number" or offset <= 0 then
  offset = 0
end
if  type(dev_request_type)  ~= "string" then
  local tab = {}
  tab["result"]="参数错误"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

local isAdmin  = false
local userStatus,userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil  then 
  if userApps[1]["user_role"] == 0 or userApps[1]["user_role"] == 1045 then
    isAdmin = true
    proj_bu_code = nil
  else
    proj_bu_code = userApps[1]["user_bu_code"]
  --  comm_func.do_dump_value("------------zjq---------------proj_bu_code:"..proj_bu_code,0)
    proj_bu_code = comm_func.buprovince_get(proj_bu_code)
    comm_func.do_dump_value("------------zjq---------------proj_bu_code:"..proj_bu_code,0)
  end
else
  local tab = {}
  tab["result"] = "用户不存在"
  tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS")
  ngx.say(cjson.encode(tab))
  return
end

if fuzzy_searche_key ~= nil and type(fuzzy_searche_key) ~= "string" then
  local tab = {}
  tab["result"]="fuzzy_searche_key必须为字符串"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
else
  fuzzy_searche_key = comm_func.trim_string(fuzzy_searche_key)
  if fuzzy_searche_key == "" then
    fuzzy_searche_key = nil
  end
  if fuzzy_searche_key  ~= nil and string.len(fuzzy_searche_key) < conf_sys.fuzzy_searche_key_length_min then
    local tab = {}
    tab["result"]="fuzzy_searche_key的长度不小于"..tostring(conf_sys.fuzzy_searche_key_length_min)
    tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
  end
end

if proj_company_code ~= nil and type(proj_company_code) ~= "string" then
  local tab = {}
  tab["result"]="proj_company_code必须为字符串"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if proj_module_code ~= nil and type(proj_module_code) ~= "string" then
  local tab = {}
  tab["result"]="proj_module_code必须为字符串"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if proj_link_status ~=nil and type(proj_link_status)~="number" then
local tab = {}
tab["result"] = "proj_link_status必须是整形"
 tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if proj_link_type ~=nil and proj_link_type ~="" and type(proj_link_status)~="number" then
  local tab = {}
  tab["result"] = "proj_link_type必须是整形"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if submit_start_time ~=nil and type(submit_start_time)~="number" then
local tab = {}
tab["result"] = "submit_start_time必须为长整型"
 tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if submit_end_time ~=nil and type(submit_end_time)~="number" then
local tab = {}
tab["result"] = "submit_end_time必须为长整型"
 tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if examine_start_time ~=nil and type(examine_start_time)~="number" then
local tab = {}
 tab["result"] = "examine_start_time必须为长整型"
 tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if examine_end_time ~=nil and type(examine_end_time)~="number" then
local tab = {}
 tab["result"] = "examine_end_time必须为长整型"
 tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

local status, apps,count,total,sql1,sql2,sql=db_query.selectLinkList_get(examine_start_time,examine_end_time,submit_start_time,submit_end_time,fuzzy_searche_key,proj_link_type,proj_module_code,proj_company_code,proj_link_status,proj_bu_code,limit,offset);

local fileUrl
  if is_download == true then
     local nowTime = ngx.now()
     local fileName = "Process_"..tostring(nowTime)..".xlsx"
     local filePath = conf_sys.project_fined_list_excel_file_dir..fileName
     local peroidTime =  os.date("%Y-%m-%d %H:%M:%S",start_time)..tostring("----")..os.date("%Y-%m-%d %H:%M:%S",end_time)
     local fileCmd = string.format("/usr/bin/python /home/gqh_workspace/project/gd_worksite_manage_beta/lua/py/project_link_work_report_gen.py %s %s %s %s %s \"%s\" %s \"%s\"",conf_sys.sys_db["database_value"],conf_sys.sys_db["user_value"],conf_sys.sys_db["password_value"],conf_sys.sys_db["host_value"],conf_sys.sys_db["port_value"],sql,filePath,peroidTime)
     os.execute(fileCmd)
     if comm_func.file_exists(filePath) == true then
         fileUrl = conf_sys.project_fined_list_excel_file_url_path..fileName
         local tab = {}
         tab["result"] = fileUrl
         tab["error"] = error_table.get_error("ERROR_NONE")
          ngx.say(cjson.encode(tab))
     else
      local tab = {}
      tab["result"] = "生成报表失败"
      tab["error"] = error_table.get_error("ERROR_PROVINCE_FINED_LIST_FILE_GEN_FAILED")
      ngx.say(cjson.encode(tab))
     return
     end
  else
    if status == true then
        local tab = {}
        local otherTab = {}
        local appsResult= {}
        otherTab["total"] = total
        otherTab["limit"] = limit
        otherTab["offset"] = offset
        otherTab["count"] = total
        tab["other"] = otherTab
        tab["result"] = apps
        tab["error"] = error_table.get_error("ERROR_NONE")
        ngx.say(cjson.encode(tab))
    else
	    local tab = {}
	    tab["result"] = "获取列表内容失败"
	    tab["error"] = error_table.get_error("ERROR_LINK_REVIEW_STATUS_RESET_GET_FAILED")
        ngx.say(cjson.encode(tab))
    end
end