ngx.req.read_body()
local data = ngx.req.get_body_data()

local decode_data = cjson.decode(data)

local csvConstroctor={
  "公司编码","公司名称","用户编码","用户名","姓名","是否锁定","变更时间"
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

local organizationResultTab = {}
local userResultTab = {}

local file = io.open("/home/gqh_workspace/project/gd_worksite_manage/test_user_import.csv","r")
local line = file:read()
while line ~= nil do
--line="公司编码","公司名称","用户编码","用户名","姓名","是否锁定","变更时间"
--comm_func.do_dump_value(line,0)
  local dataTemp = comm_func.split_string(line,",")
  local data = {}
        --comm_func.do_dump_value(dataTemp,0)
  for k,v in pairs(dataTemp) do
    data[k] = removeQuotes(v)
    data[k] = comm_func.trim_string(data[k])
  end
 --comm_func.do_dump_value(data,0)
--comm_func.do_dump_value(data[12],0)
--comm_func.do_dump_value(tostring(data[13]),0) 
  if lineNum == 1 then
    --if data[13] == nil then
      --  data[13] = "公司代码"
    --end
    if data[1] ~= csvConstroctor[1] or data[2] ~= csvConstroctor[2] or data[3] ~= csvConstroctor[3] or data[4] ~= csvConstroctor[4] or data[5] ~= csvConstroctor[5] or data[6] ~= csvConstroctor[6] or data[7] ~= csvConstroctor[7]  then
      local tab = {}
      tab["result"] = "文档格式不匹配"
      tab["error"] = error_table.get_error("ERROR_NONE")
      ngx.say(cjson.encode(tab))
      file:close()
      return 
    end   
   lineNum = lineNum + 1
  else
    --comm_func.do_dump_value(data,0) 
    local status, apps = db_user.organization_import(data)
    if status == true then 
      table.insert(organizationResultTab, data[1]) 
    end
  end
  line = file:read()
end 
file:close()


file = io.open("/home/gqh_workspace/project/gd_worksite_manage/test_user_import.csv","r")
lineNum = 1
local line = file:read()
while line ~= nil do
--line="公司编码","公司名称","用户编码","用户名","姓名","是否锁定","变更时间"
--comm_func.do_dump_value(line,0)
  local dataTemp = comm_func.split_string(line,",")
  local data = {}
        --comm_func.do_dump_value(dataTemp,0)
  for k,v in pairs(dataTemp) do
    data[k] = removeQuotes(v)
    data[k] = comm_func.trim_string(data[k])
  end
 --comm_func.do_dump_value(data,0)
--comm_func.do_dump_value(data[12],0)
--comm_func.do_dump_value(tostring(data[13]),0) 
  if lineNum == 1 then
    --if data[13] == nil then
      --  data[13] = "公司代码"
    --end
    if data[1] ~= csvConstroctor[1] or data[2] ~= csvConstroctor[2] or data[3] ~= csvConstroctor[3] or data[4] ~= csvConstroctor[4] or data[5] ~= csvConstroctor[5] or data[6] ~= csvConstroctor[6] or data[7] ~= csvConstroctor[7]  then
      local tab = {}
      tab["result"] = "文档格式不匹配"
      tab["error"] = error_table.get_error("ERROR_NONE")
      ngx.say(cjson.encode(tab))
      file:close()
      return 
    end   
   lineNum = lineNum + 1
  else
    --comm_func.do_dump_value(data,0) 
    local status, apps = db_user.user_import(data)
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
tab["result"]["organization"] = organizationResultTab
tab["error"] = error_table.get_error("ERROR_NONE") 
ngx.say(cjson.encode(tab))