ngx.req.read_body()
local data = ngx.req.get_body_data()

local decode_data = cjson.decode(data)

local csvConstroctor={
  "user_company","user_company_code","user_name","user_number","user_change_time","user_status"
}
local userResult ={}

local lineNum = 1

local function removeQuotes(Str)
   --comm_func.do_dump_value(Str,0)
  local resultStr = Str
  if string.len(Str) > 1 then
  if string.sub(Str,1,1) == "\"" then
    resultStr = string.sub(Str,2,string.len(Str))
  else
    resultStr = Str
  end
  if string.len(resultStr) > 1 then
    if string.sub(resultStr,string.len(resultStr),string.len(resultStr)) == "\"" then
                  resultStr = string.sub(resultStr,1,string.len(resultStr)-1)
          else
                  
          end
  elseif resultStr == "\"" then
    resultStr =""
  end
  end
  return resultStr
end


local function requestUserImportAPI(userTab)
  local  ipAddr = conf_sys.erp_sync_request_api["ipAddr"]
  local  port = conf_sys.erp_sync_request_api["port"]
  local apiStr = "api/user_import_v0_4"
  local header = {}
  header["Content-Type"] = "application/json"
  header["Authorization"] = "sdfsRDfwefw123WEe2ERGr3=r-34t03ERGERt353+t3E6++dfge=-GER34kt3WE4-o3-4-0i1iGD-kkbmjkd22fl"
  header["user-agent"] = "self"
  header["dev-request-type"] = "user_web"
  header["user-id"] = db_query.userId_get("admin")
  if header["user-id"] == nil then
    header["user-id"] = 1
  end
  
  local requestBody = {}
  requestBody["params"] = userTab
  
  local status , body = comm_func.postHttpRequestDo(ipAddr,port,apiStr,header,cjson.encode(requestBody))
  if status == true and body["error"] == 0 then
    db_sync_erp.userSynced_update(userTab)
    return true
  end
  return false
end 


local organizationResultTab = {}
local userResultTab = {}

local file = io.open("/home/gqh_workspace/project/gd_worksite_manage_beta/renyuan1017_1105.csv","r")
local line = file:read()
while line ~= nil do
  local dataTemp = comm_func.split_string(line,"WS")
  local data = {}
  for k,v in pairs(dataTemp) do
    data[k] = removeQuotes(v)
    data[k] = comm_func.trim_string(data[k])
  end

  if lineNum == 1 then
    if data[1] ~= csvConstroctor[1] or data[2] ~= csvConstroctor[2] or data[3] ~= csvConstroctor[3] or data[4] ~= csvConstroctor[4] or data[5] ~= csvConstroctor[5] or data[6] ~= csvConstroctor[6]  then
      local tab = {}
      tab["result"] = "文档格式不匹配"
      tab["error"] = error_table.get_error("ERROR_NONE")
      ngx.say(cjson.encode(tab))
      file:close()
      return 
    end   
   lineNum = lineNum + 1
  else
    local userTab = {}
    userTab["user_company"] = data[1]
    userTab["user_company_code"] = data[2]
    userTab["user_name"] = data[3]
    userTab["user_number"] = data[4]
    userTab["user_change_time"] = data[5]
    userTab["user_status"] = data[6]
    if false then
      comm_func.do_dump_value(data,0)
      comm_func.do_dump_value(userTab,0)
      return
    end
    local status = requestUserImportAPI(userTab)
    if status == true then 
      table.insert(userResultTab, data[3]) 
    end
  end
  line = file:read()
end 
file:close()



local tab = {} 
tab["result"] = {}
tab["result"]["user"] = userResultTab
tab["error"] = error_table.get_error("ERROR_NONE") 
ngx.say(cjson.encode(tab))
