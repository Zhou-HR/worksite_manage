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
local meeting_id = decode_params["meeting_id"]
local file_url = decode_params["url"]
local file_name = decode_params["file_name"]
local annex_delete_id = decode_params["annex_delete_id"]

if meeting_id == nil then
  local tab = {}
  tab["result"]="缺少meeting_id参数"
  tab["error"]=error_table.get_error("ERROR_JSON_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if annex_delete_id == nil then
  if file_name ~= nil and string.len(file_name) < 1 then
    local tab = {}
    tab["result"]="file_name长度必须大于0"
    tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
  end

  local fileOk = false
  if  file_url ~= nil and string.len(file_url) > 0 then
    fileOk = true
    local newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
    local urlindex = string.find(file_url, "com", 1)
    local file_url_chk = string.sub(file_url,0,urlindex-1)
    if newurl ~= file_url_chk then
      local tab = {}
      tab["result"]="附件URL参数不合法"
      tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
      ngx.say(cjson.encode(tab))
      return
    end
  else
    fileOk = false
  end
  if  file_name ~= nil and string.len(file_name) > 0 then
    fileOk = true
  else
    fileOk = false
  end
  if fileOk == false then
    local tab = {}
    tab["result"]="附件参数不合法"
    tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
  end
end

local userStatus,userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil  then
  local meetStatus,meetApps = db_query.meetingList_get(meeting_id,nil,nil,nil,nil,nil,nil,10,0,nil)
  --comm_func.do_dump_value(meetApps[1],0)
  --comm_func.do_dump_value(userApps[1],0)
  if meetStatus == true and meetApps ~= nil and meetApps[1] ~= nil  then
    local isUserRight = false
    if userApps[1]["user_bu_code"] ~= nil then
      local buArr = comm_func.split_string(userApps[1]["user_bu_code"],",")
      if buArr ~= nil then
        for k,v in pairs(buArr) do
          if v == meetApps[1]["meeting_bu_code"] then
            isUserRight = true
            break
          end
        end
      end
    end
    
    if isUserRight == false then
      local tab = {} 
      if annex_delete_id == nil then
        tab["result"] = "该账号无权限提交"
      else
        tab["result"] = "该账号无权限删除"
      end
      tab["error"] = error_table.get_error("ERROR_USER_PERMISSION_REFUSE") 
      ngx.say(cjson.encode(tab))
      return
    end
  else
    local tab = {} 
    tab["result"] = "该会议不存在" 
    tab["error"] = error_table.get_error("ERROR_MEET_GET_FAILED") 
    ngx.say(cjson.encode(tab))
    return
  end
else
  local tab = {} 
  tab["result"] = "用户不存在" 
  tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS") 
  ngx.say(cjson.encode(tab))
  return
end

local meetAnnexTab = {}
if annex_delete_id == nil then
  meetAnnexTab["meeting_id"] = meeting_id
  meetAnnexTab["meeting_annex_name"] = file_name
  meetAnnexTab["meeting_annex_url"] = file_url
  meetAnnexTab["meeting_submit_userid"] = userApps[1]["user_id"]
  meetAnnexTab["meeting_submit_username"] = userApps[1]["user_name"]
  meetAnnexTab["meeting_company_code"] = userApps[1]["user_company_code"]
  meetAnnexTab["meeting_company_name"] = userApps[1]["user_company"]
  meetAnnexTab["meeting_bu_code"] = userApps[1]["user_bu_code"]
  meetAnnexTab["meeting_bu_name"] = userApps[1]["user_bu_name"]
else
  meetAnnexTab["annex_delete_id"] = annex_delete_id
end
local status,apps = db_query.meetingAnnex_submit(meetAnnexTab)
if status == true and apps ~= nil then
  local tab = {}
  if annex_delete_id == nil then
    tab["result"] = "附件提交成功"
  else
    tab["result"] = "附件删除成功"
  end
  tab["error"] = error_table.get_error("ERROR_NONE")
  ngx.say(cjson.encode(tab))
end
