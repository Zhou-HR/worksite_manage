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

local decode_params = decode_data["params"]
local fuzzy_searche_key = decode_params["fuzzy_searche_key"]
local meeting_title = decode_params["meeting_title"]
local meeting_submit_time = decode_params["meeting_submit_time"]
local meeting_bu_code = decode_params["meeting_bu_code"]
local meeting_company_code = decode_params["meeting_company_code"]
local limit = decode_params["limit"]
local offset = decode_params["offset"]
local is_download = decode_params["is_download"]

if is_download ~= nil and is_download == true then
--  ngx.say("----zjq00000------------is_download=true")
else
  is_download = false
end

local paramsRight = true
local paramsErrorMsg

if paramsRight and meeting_title ~= nil and type(meeting_title) ~= "string" then
  paramsErrorMsg = "meeting_title必须是字符串" 
  paramsRight = false
end
if paramsRight and meeting_company_code ~= nil and type(meeting_company_code) ~= "string" then
  paramsErrorMsg = "meeting_company_code必须是字符串" 
  paramsRight = false
end
if paramsRight and meeting_bu_code ~= nil and type(meeting_bu_code) ~= "string" then
  paramsErrorMsg = "meeting_bu_code必须是字符串" 
  paramsRight = false
end
if paramsRight and meeting_submit_time ~= nil and type(meeting_submit_time) ~= "number" then
  paramsErrorMsg = "meeting_submit_time必须是整型" 
  paramsRight = false
end

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


if paramsRight == false then
  local tab = {} 
  tab["result"] = paramsErrorMsg
  tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG") 
  ngx.say(cjson.encode(tab))
  return
end

if type(limit) ~= "number" or limit <= 0 then
  limit = 10
end

if type(offset) ~= "number" or offset < 10 then
  offset = 0
end

---部门筛选管理员
local isAdmin  = false
local user_bu_code = nil
local userStatus,userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil  then  
    user_bu_code = userApps[1]["user_bu_code"]
  isAdmin =  db_query.userAdmin_is(userApps[1],user_id) 
  if isAdmin == true then
    user_bu_code = nil
  end
  if userApps[1]["user_role"] == 1 then
    user_bu_code = string.sub(userApps[1]["user_bu_code"],1,2)
  else
    user_bu_code = comm_func.buprovince_get(user_bu_code)
  end
else
  local tab = {} 
  tab["result"] = apps 
  tab["error"] = error_table.get_error("ERROR_PROJ_LIST_GET_FAILED") 
  ngx.say(cjson.encode(tab))
  return
end
---


local status,apps,count,total,sqlStr1,sqlStr2,sqlStr = db_query.meetingList_get(nil,meeting_title,meeting_company_code,meeting_bu_code,meeting_submit_time,fuzzy_searche_key,isAdmin,limit,offset,user_bu_code,is_download)
comm_func.do_dump_value(sqlStr,0)
local fileUrl
if is_download == true then
  local nowTime = ngx.now()
  local fileName = "Meeting_"..tostring(nowTime)..".xlsx"
  local filePath = conf_sys.project_fined_list_excel_file_dir..fileName
  local peroidTime =  os.date("%Y-%m-%d %H:%M:%S",start_time)..tostring("----")..os.date("%Y-%m-%d %H:%M:%S",end_time)
  local fileCmd = string.format("/usr/bin/python /home/gqh_workspace/project/gd_worksite_manage_beta/lua/py/meeting_manage_gen.py %s %s %s %s %s \"%s\" %s \"%s\"",conf_sys.sys_db["database_value"],conf_sys.sys_db["user_value"],conf_sys.sys_db["password_value"],conf_sys.sys_db["host_value"],conf_sys.sys_db["port_value"],sqlStr,filePath,peroidTime)
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
    otherTab["total"] = total
    otherTab["limit"] = limit
    otherTab["offset"] = offset
    otherTab["count"] = count
    tab["other"] = otherTab
    for i = 1,count,1 do
      apps[i]["meeting_pic"] = cjson.decode(apps[i]["meeting_pic"])
    end
    local urlindex
    local newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
    for k, v in pairs(apps) do
      for m in pairs(apps[k]["meeting_pic"]) do
        urlindex = string.find(apps[k]["meeting_pic"][m]["pic"], "com", 1)
        newurl = newurl..string.sub(apps[k]["meeting_pic"][m]["pic"],urlindex,string.len(apps[k]["meeting_pic"][m]["pic"]))
        apps[k]["meeting_pic"][m]["pic"] = newurl
        newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
      end
    end

    -- apps[1]["meeting_pic"] = cjson.decode(apps[1]["meeting_pic"])
    tab["result"] = apps -- apps[1]
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
    return
  else
    local tab = {}
    tab["result"] = "获取会议列表失败"
    tab["error"] = error_table.get_error("ERROR_MEET_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
  end
end
