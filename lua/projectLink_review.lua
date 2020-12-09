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
local links = decode_params["links"]
local fines = decode_params["fines"]

local view_status = 0
ngx.log(ngx.ERR, "links: ",1111111111111)
comm_func.do_dump_value(links,0)
ngx.log(ngx.ERR, "fines: ",1111111111111)
comm_func.do_dump_value(fines,0)

local user_id = comm_func.get_http_header("user_id",ngx)
local proj_bu_code

if type(proj_code) ~= "string"  or type(links) ~= "table" or #links < 1 then
  local tab = {}
  tab["result"]="参数错误"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

local linkIdTab = {} 
local linkIdTabIndex = 1
for k, v in pairs(links) do
     if type(v["proj_link_id"]) ~= "number" then
        local tab = {}
        tab["result"]="link id参数错误"
        tab["error"]=error_table.get_error("ERROR_LINK_ID_INVALID")
        ngx.say(cjson.encode(tab))
        return
     else
        for idk, idv in pairs(linkIdTab) do
            if idv == v["proj_link_id"] then
              local tab = {}
              tab["result"]="link id重复"
              tab["error"]=error_table.get_error("ERROR_LINK_ID_DUPLICATE")
              ngx.say(cjson.encode(tab))
              return
            end
        end
        local isRight,msg = db_query.linkReview_check(v)
        if isRight == false then
          local tab = {}
          tab["result"]=msg
          tab["error"]=error_table.get_error("ERROR_LINK_INFO")
          ngx.say(cjson.encode(tab))
          return
        end
        
        view_status = v["proj_link_status"]
        ngx.log(ngx.ERR, "view_status: ",view_status)
        linkIdTab[linkIdTabIndex] = v["proj_link_id"]
        linkIdTabIndex = linkIdTabIndex + 1
     end
end

local isAdmin = false
local userStatus,userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil  then
  proj_bu_code = userApps[1]["user_bu_code"]
  if db_query.permission_check_project_review(userApps[1]["user_role"]) == false then
    local tab = {} 
    tab["result"] = "该账号无权限审核" 
    tab["error"] = error_table.get_error("ERROR_USER_PERMISSION_REFUSE")
    ngx.say(cjson.encode(tab))
    return
  else
    if userApps[1]["user_role"] == 0  or  db_query.user_is_group_jianli(userApps[1]["user_role"])  then
      isAdmin = true
    else
      proj_bu_code = string.sub(userApps[1]["user_bu_code"],1,2)
      proj_bu_code = comm_func.buprovince_get(proj_bu_code)
    end
  end
else
  local tab = {} 
  tab["result"] = "用户不存在" 
  tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS") 
  ngx.say(cjson.encode(tab))
  return
end

local status, apps,count,total
if isAdmin == true then
status, apps, count, total = db_query.projectList_get(proj_code,nil,nil,nil,nil,nil,nil,nil,nil,false,1,0)
else 
status, apps, count, total = db_query.projectList_get(proj_code,nil,nil,nil,nil,nil,nil,proj_bu_code,nil,false,1,0)
end
if status == true and count == 1 then
else
  local tab = {} 
  tab["result"] = "项目不存在" 
  tab["error"] = error_table.get_error("ERROR_PROJ_NO_EXISTS") 
  ngx.say(cjson.encode(tab))
  return
end



status, apps = db_query.projectLink_get(proj_code)
if status == true and #apps > 0 then
  for k, v in pairs(linkIdTab) do
      local isThisProj = false
      for appsk,appsv in pairs(apps) do
        if v == appsv["proj_link_id"] then
          if appsv["proj_link_status"] == 0  then
              local tab = {} 
              tab["result"] = "工序:"..tostring(v)..",尚未提交" 
              tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED") 
              ngx.say(cjson.encode(tab))
              return
          elseif appsv["proj_link_status"] == 2  then
              local tab = {} 
              tab["result"] = "工序:"..tostring(v)..",已被审核不通过，无法再次审核" 
              tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED") 
              ngx.say(cjson.encode(tab))
              return
          elseif appsv["proj_link_status"] == 3  then
              local tab = {} 
              tab["result"] = "工序:"..tostring(v)..",已被审核不通过，无法再次审核" 
              tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED") 
              ngx.say(cjson.encode(tab))
              return
	 elseif appsv["proj_link_status"] == 5  then
              local tab = {} 
              tab["result"] = "工序:"..tostring(v)..",已被审核条件通过，无法再次审核" 
              tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED") 
              ngx.say(cjson.encode(tab))
              return
	 elseif appsv["proj_link_status"] == 6  then
              local tab = {} 
              tab["result"] = "工序:"..tostring(v)..",已被禁用，无法次审核" 
              tab["error"] = error_table.get_error("ERROR_LINK_CHANGE_NOT_ALLOWED") 
              ngx.say(cjson.encode(tab))
              return
          end
          isThisProj = true
          break
        end
      end
      if isThisProj == false then
          local tab = {} 
          tab["result"] = "工序不存在:"..tostring(v) 
          tab["error"] = error_table.get_error("ERROR_LINK_NO_EXISTS") 
          ngx.say(cjson.encode(tab))
          return
      end
  end
else
  local tab = {} 
  tab["result"] = "工序不存在" 
  tab["error"] = error_table.get_error("ERROR_LINK_NO_EXISTS") 
  ngx.say(cjson.encode(tab))
  return
end

--扣款 start
local finesflag = false

--if proj_link_review_charge ~= nil and proj_link_review_charge == "true" then
--  links[1]["proj_link_status"] = 7
--end

if links[1]["proj_link_review_charge"] ~= nil then
  if links[1]["proj_link_status"] == 2 and links[1]["proj_link_review_charge"] == 1 then
    local tab = {}
    tab["result"] = "审核失败,审核不通过时不能有扣款"
    tab["error"] = error_table.get_error("ERROR_LINK_REVIEW_FAILED")
    ngx.say(cjson.encode(tab))
    return
  end
else
  if links[1]["proj_link_status"] == 2 and fines ~= nil then
    local tab = {}
    tab["result"] = "审核失败,审核不通过时不能有扣款"
    tab["error"] = error_table.get_error("ERROR_LINK_REVIEW_FAILED")
    ngx.say(cjson.encode(tab))
    return
  end
end

local status, apps = db_query.projectLink_review(links,proj_code)

if status == true then
  db_push_msg.projectProgressUpdateMsgDb_notify(user_id,proj_code,links,nil)
  local red = redis:new()
        red:set(conf_sys.sys_user_token["isHaveUnsendMsg"],"true")

  if fines ~= nil then
    local  ipAddr = conf_sys.erp_sync_request_api["ipAddr"]
    local  port = conf_sys.erp_sync_request_api["port"]
    local apiStr = "api/linkFine_set"
    local header = {}
    header["Content-Type"] = "application/json"
    header["Authorization"] = "sdfsRDfwefw123WEe2ERGr3=r-34t03ERGERt353+t3E6++dfge=-GER34kt3WE4-o3-4-0i1iGD-kkbmjkd22fl"
    header["user-agent"] = "self"
    header["dev-request-type"] = "user_web"
    header["user-id"] = user_id
    if header["user-id"] == nil then
      header["user-id"] = 1
    end

    local requestBody = {}
    fines["fine_from_review"] = 1
    requestBody["params"] = fines

    local finestatus , body = comm_func.postHttpRequestDo(ipAddr,port,apiStr,header,cjson.encode(requestBody))

    if finestatus == true and body["error"] == 0 then
    else
      local tab = {}
      tab = body
      ngx.say(cjson.encode(tab))
      return
    end
  end
  
  db_meter.update_view_status(proj_code,view_status)
  
  local tab = {} 
  tab["result"] = apps
  tab["error"] = error_table.get_error("ERROR_NONE") 
  ngx.say(cjson.encode(tab))
else
  local tab = {} 
  tab["result"] = "审核失败"
  tab["error"] = error_table.get_error("ERROR_LINK_REVIEW_FAILED") 
  ngx.say(cjson.encode(tab))
  return
end

