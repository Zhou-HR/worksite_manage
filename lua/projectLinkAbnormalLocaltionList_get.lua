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
local proj_code = decode_params["proj_code"]
local proj_name = decode_params["proj_name"]
local proj_link_name = decode_params["proj_link_name"]
local proj_module_name = decode_params["proj_module_name"]

local proj_link_status = decode_params["proj_link_status"]
local fuzzy_searche_key  = decode_params["fuzzy_searche_key"]
local proj_bu_code
local proj_company_code
local dev_request_type = comm_func.get_http_header("dev-request-type",ngx)
local limit = decode_params["limit"]
local offset = decode_params["offset"]
local time_begin = decode_params["start_time"]
local time_end = decode_params["end_time"]
local is_download = decode_params["is_download"]

if is_download ~= nil and is_download == true then
--  ngx.say("----zjq00000------------is_download=true")
else
  is_download = false
end

if type(time_begin) ~= "number" or type(time_end) ~= "number" then
  local tab = {}
  tab["result"]="time_begin、time_end必须为时间戳类型"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if time_end - time_begin > 2678400 then
  local tab = {}
  tab["result"]="查询时间跨度在30天内"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

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


if proj_link_status ~= nil and type(proj_link_status) ~= "number" then
  local tab = {}
  tab["result"]="proj_link_status必须为整形"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if proj_code ~= nil and type(proj_code) ~= "string" then
  local tab = {}
  tab["result"]="proj_code必须为字符串"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if proj_name ~= nil and type(proj_name) ~= "string" then
  local tab = {}
  tab["result"]="proj_name必须为字符串"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if proj_link_name ~= nil and type(proj_link_name) ~= "string" then
  local tab = {}
  tab["result"]="proj_link_name必须为字符串"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if proj_module_name ~= nil and type(proj_module_name) ~= "string" then
  local tab = {}
  tab["result"]="proj_module_name必须为字符串"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
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
    tab["result"]="fuzzy_searche_key的长度不小于3"
    tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
  end
end

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
  proj_bu_code = userApps[1]["user_bu_code"]
  proj_company_code = userApps[1]["user_company_code"]
  isAdmin =  db_query.userAdmin_is(userApps[1],user_id) 
  if isAdmin == true then
    proj_bu_code = nil
    proj_company_code = nil
  end
  if userApps[1]["user_role"] == 1 then
    proj_bu_code = string.sub(userApps[1]["user_bu_code"],1,2)
  else
    proj_bu_code = comm_func.buprovince_get(proj_bu_code)
  end
else
  local tab = {} 
  tab["result"] = apps 
  tab["error"] = error_table.get_error("ERROR_LINK_LIST_GET_FAILED") 
  ngx.say(cjson.encode(tab))
  return
end

local function parseStrToLatLon(str)
  local beforeStr = str
  if str ~= nil then
    str = comm_func.trim_string(str)

    local toNumber = tonumber(str)
    if toNumber ~= nil then
      return str
    end

    if string.find(str, "..") ~= nil then
      str =  string.gsub(str,"%..",".")
      local toNumber = tonumber(str)
      if toNumber ~= nil then
        return str
      end
    end

    if string.find(str, "°") ~= nil then
      str =  string.gsub(str,"°","")
      local toNumber = tonumber(str)
      if toNumber ~= nil then
        return str
      end
    end

    if string.find(str, "？") ~= nil then
      str =  string.gsub(str,"？","")
      local toNumber = tonumber(str)
      if toNumber ~= nil then
        return str
      end
    end

  end
  return str;

end

--赤道半径(单位m)
local EARTH_RADIUS = 6378137
local Math_PI = 3.141592653589793

local function rad( d)  
   return d * Math_PI / 180.0
end

local function LantitudeLongitudeDist( lon1,  lat1, lon2,  lat2)
    local radLat1 = rad(lat1);  
    local radLat2 = rad(lat2);  

    local radLon1 = rad(lon1);  
    local radLon2 = rad(lon2);  

    if (radLat1 < 0)  then
        radLat1 = Math_PI / 2 + math.abs(radLat1);-- south  
    end
    if (radLat1 > 0)  then
        radLat1 = Math_PI / 2 - math.abs(radLat1);-- north
    end  
    if (radLon1 < 0) then  
        radLon1 = Math_PI * 2 - math.abs(radLon1);-- west
    end  
    if (radLat2 < 0) then  
        radLat2 = Math_PI / 2 + math.abs(radLat2);-- south
    end  
    if (radLat2 > 0) then  
        radLat2 = Math_PI / 2 - math.abs(radLat2);-- north
    end  
    if (radLon2 < 0) then  
        radLon2 = Math_PI * 2 - math.abs(radLon2);-- west
    end  
    local x1 = EARTH_RADIUS * math.cos(radLon1) * math.sin(radLat1);  
    local y1 = EARTH_RADIUS * math.sin(radLon1) * math.sin(radLat1);  
    local z1 = EARTH_RADIUS * math.cos(radLat1);  

    local x2 = EARTH_RADIUS * math.cos(radLon2) * math.sin(radLat2);  
    local y2 = EARTH_RADIUS * math.sin(radLon2) * math.sin(radLat2);  
    local z2 = EARTH_RADIUS * math.cos(radLat2);  

    local d = math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)+ (z1 - z2) * (z1 - z2));  
    --余弦定理求夹角  
    local theta = math.acos((EARTH_RADIUS * EARTH_RADIUS + EARTH_RADIUS * EARTH_RADIUS - d * d) / (2 * EARTH_RADIUS * EARTH_RADIUS));  
    local dist = theta * EARTH_RADIUS;  
    return dist;  
end


local statusText = {}
statusText["0"] = "初始化，空，未提交"
statusText["1"] = "已提交未审核"
statusText["2"] = "审核不通过"
statusText["3"] = "审核通过"
statusText["4"] = "审核不通过并且留档"
statusText["5"] = "条件通过"
statusText["6"] = "该环节被禁用"

local sqlStr = string.format(" select c.o_name ,  b.proj_bu_name,  a.proj_bu_code,a.proj_code,a.proj_name,a.proj_module_name,a.proj_link_name, a.proj_link_status,a.proj_link_pic,a.proj_link_submit_time ,b.proj_lon,b.proj_lat from    tb_proj_link a,tb_proj b,tb_organization c where a.proj_link_submit_time > %d and  a.proj_link_submit_time <= %d and a.proj_code = b.proj_code and a.proj_company_code=c.o_code and (a.proj_code !='GDJZAAAAAAAAAAYD' and a.proj_code !='GDJZAAAAAAAAABYD' ) order by a.proj_company_code asc, a.proj_link_submit_time desc ",time_begin,time_end)

local status, apps =  db_project.excute(sqlStr)
local resultApps = {}
local resultAppsLength = 1

if status == true and apps ~= nil and apps[1] ~= nil then
  for k,v in pairs(apps) do
    local lonStr = v["proj_lon"]
    local latStr = v["proj_lat"]

    --comm_func.do_dump_value(latStr,0);
    lonStr = parseStrToLatLon(lonStr)
    latStr = parseStrToLatLon(latStr)
    --comm_func.do_dump_value(latStr,0);
    if tonumber(latStr) ~= nil and tonumber(lonStr) ~= nil then
      latStr,lonStr =  comm_func.wgs_to_bd_encrypt(latStr,lonStr)
      latStr = tostring(latStr)
      lonStr = tostring(lonStr)
      if string.len(latStr) > 10 then
        latStr = string.sub(latStr,1,10)
      end
      if string.len(lonStr) > 10 then
        lonStr = string.sub(lonStr,1,10)
      end
    end
    apps[k]["proj_bd_lon"] = lonStr
    apps[k]["proj_bd_lat"] = latStr
    
    local bdLon = tonumber(lonStr)
    local bdLat = tonumber(latStr)
    
    local bdPicLon = nil
    local bdPicLat = nil
    local picInfo = cjson.decode(v["proj_link_pic"])
    if picInfo ~= nil and picInfo[1] ~= nil then
      bdPicLon = picInfo[1]["location"]["lon"]
      bdPicLat = picInfo[1]["location"]["lat"]
      
      if bdPicLon ~= nil then
        bdPicLon = tonumber(bdPicLon)
      end
      if bdPicLat ~= nil then
        bdPicLat = tonumber(bdPicLat)
      end
    end
    
    if bdLon == nil or bdLat == nil or bdPicLon == nil or bdPicLat == nil then
        v["proj_link_pic"] = nil
        resultApps[resultAppsLength] = comm_func.table_clone(v)
        resultApps[resultAppsLength]["bdPicLon"] = picInfo[1]["location"]["lon"]
        resultApps[resultAppsLength]["bdPicLat"] = picInfo[1]["location"]["lat"]
        resultApps[resultAppsLength]["proj_link_status"] = statusText[tostring(v["proj_link_status"])]
        resultAppsLength = resultAppsLength + 1
    else
        local distanceM = LantitudeLongitudeDist(bdLon, bdLat,bdPicLon, bdPicLat)
        if distanceM > 200 then
          v["proj_link_pic"] = nil
          resultApps[resultAppsLength] = comm_func.table_clone(v)
          resultApps[resultAppsLength]["bdPicLon"] = picInfo[1]["location"]["lon"]
          resultApps[resultAppsLength]["bdPicLat"] = picInfo[1]["location"]["lat"]
          resultApps[resultAppsLength]["distanceM"] = distanceM
          resultApps[resultAppsLength]["proj_link_status"] = statusText[tostring(v["proj_link_status"])]
          resultAppsLength = resultAppsLength + 1
        end
    end
  end
end

local fileUrl
if is_download == true then
--    ngx.say("----zjq-111111111-----------is_download=true")
    local nowTime = ngx.now()
    local fileName = "Location_"..tostring(nowTime)..".xlsx"
    local filePath = conf_sys.project_fined_list_excel_file_dir..fileName

    local tab = {}
    tab["data"] = resultApps

    --local peroidTime =  os.date("%Y-%m-%d %H:%M:%S",start_time)..tostring("----")..os.date("%Y-%m-%d %H:%M:%S",end_time)
    --local fileCmd = string.format("/usr/bin/python /home/gqh_workspace/project/gd_worksite_manage/lua/py/project_link_abnormal_location_gen.py %s %s %s %s %s \"%s\" %s \"%s\"",conf_sys.sys_db["database_value"],conf_sys.sys_db["user_value"],conf_sys.sys_db["password_value"],conf_sys.sys_db["host_value"],conf_sys.sys_db["port_value"],sqlStr,filePath,peroidTime)
    local fileCmd = string.format("/usr/bin/python /home/gqh_workspace/project/gd_worksite_manage_trial/lua/py/project_link_abnormal_location_gen.py %s %s ",filePath,"'"..cjson.encode(tab).."'")
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
      tab["error"] = error_table.get_error("ERROR_PROJ_FINED_LIST_FILE_GEN_FAILED") 
      ngx.say(cjson.encode(tab))
      return 
    end
  else
  	comm_func.do_dump_value("-------zjq--------is_download=",is_download);
  	local tab = {}
	tab["result"] = resultApps
	tab["total"] = resultAppsLength - 1  
	tab["error"] = error_table.get_error("ERROR_NONE")
	ngx.say(cjson.encode(tab))
end

