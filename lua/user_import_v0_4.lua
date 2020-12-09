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
local function syncOrganization()
  local status,appps =  db_query.excute(" select * from  tb_organization  where LENGTH(o_code) = 4 and o_parent_code = ''   order by o_code asc  ")
  local parentStatus,parentAppps =  db_query.excute(" select * from  tb_organization  where LENGTH(o_code) = 2 order by o_code asc  ")
  
  local parentTab = {}
  for k,v in pairs(parentAppps) do
      parentTab[v["o_code"]] =  v["o_name"]
  end 
  
  
  if status == true and appps ~= nil then
    for k,v in pairs(appps) do
      local parentCode = string.sub(v["o_code"],1,2)
      if parentTab[parentCode] ~= nil then
        local sqlUpdate = string.format(" update tb_organization set o_parent_code='%s',o_parent_name='%s'  where o_code='%s' ",parentCode,parentTab[parentCode],v["o_code"])
        db_query.excute(sqlUpdate)
      end
    end 
  end
end
if decode_params["user_company"] ~= nil and string.len(decode_params["user_company"]) > 1  then
  local user_company_length = string.len(decode_params["user_company"])
  if string.sub(decode_params["user_company"],user_company_length , user_company_length) == "," then
    decode_params["user_company"] = string.sub(decode_params["user_company"],1,user_company_length - 1)
  end
end
if decode_params["user_company_code"] ~= nil and string.len(decode_params["user_company_code"]) > 1  then
  local user_company_length = string.len(decode_params["user_company_code"])
  if string.sub(decode_params["user_company_code"],user_company_length , user_company_length) == "," then
    decode_params["user_company_code"] = string.sub(decode_params["user_company_code"],1,user_company_length - 1)
  end
end

local companyNameTab = decode_params["user_company"]
local compantCodeTab = decode_params["user_company_code"]
companyNameTab = comm_func.split_string(companyNameTab,",")
compantCodeTab = comm_func.split_string(compantCodeTab,",")

local firstCode = nil
for k,v in pairs(compantCodeTab) do
  local company = {}
  company["user_company"] = companyNameTab[k]
  company["user_company_code"] = compantCodeTab[k]
  if firstCode == nil then
    firstCode = string.sub(compantCodeTab[k],1,2)
  end
  if  firstCode ~= string.sub(compantCodeTab[k],1,2) then
 
    local tab = {} 
    tab["result"] = "该人员部门跨省"
    tab["error"] = error_table.get_error("ERROR_USER_IMPORT_FAILED") 
    ngx.say(cjson.encode(tab))
    return
    
    --[==[
    decode_params["user_company_code"] = "01"
    local status,apps = db_user.organization_get(decode_params["user_company_code"])
    if status == true and apps ~= nil and apps[1] ~= nil then
      decode_params["user_company"] = apps[1]["o_name"]
    end
    break
    ]==]--
    
  end
  db_user.organization_import_v0_4(company)
end

syncOrganization()

local user_bu_name = decode_params["user_company"]
local user_bu_code = decode_params["user_company_code"]
user_bu_code = comm_func.buprovince_get(user_bu_code)
if string.len(user_bu_code) == 2 and  user_bu_code ~= decode_params["user_company_code"]  then
  decode_params["user_company_code"] = user_bu_code
  local status,apps = db_user.organization_get(user_bu_code)
  if status == true and apps ~= nil and apps[1] ~= nil then
    decode_params["user_company"] = apps[1]["o_name"]
  end
end

local status, apps = db_user.user_import_v0_4(decode_params)
if status == true  and apps ~= nil and apps[1] ~= nil then 
  local tab = {} 
  tab["result"] = decode_params
  tab["error"] = error_table.get_error("ERROR_NONE") 
  ngx.say(cjson.encode(tab))
  return
end

local tab = {} 
tab["result"] = "导入用户数据失败"
tab["error"] = error_table.get_error("ERROR_USER_IMPORT_FAILED") 
ngx.say(cjson.encode(tab))
