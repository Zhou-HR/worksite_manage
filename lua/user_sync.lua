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



local  userOrig = " select * from tb_user_orig "
local  orgaData = "select * from tb_organization "


local userStatus,userApps = db_query.excute(userOrig)
local orgaStatus,orgaApps = db_query.excute(orgaData)

if userStatus == true  and  orgaStatus== true then
  for k, v in pairs(userApps) do
        local tempDepartInfo = {}
         for ok,ov in pairs(orgaApps) do
            if   ov["o_parent_name"] == v["u_company"] and ov["o_name"] == v["u_department"] then
              tempDepartInfo = comm_func.table_clone(ov)
              break;
            end
         end
         local user_name=v["u_name"]..v["u_job_number"]
         local user_password = ngx.md5(user_name)
         local user_role = 3
         if tempDepartInfo["o_code"] ~= nil and string.sub(tempDepartInfo["o_code"],string.len(tempDepartInfo["o_code"]) - 1,string.len(tempDepartInfo["o_code"])) == "00" then
            user_role = 1
         elseif string.find(v["u_job"],"经理") ~= nil  then
            user_role = 2
         end
         local user_number = v["u_job_number"]
         local user_bu_name = v["u_department"]
         local user_bu_code = ""
         if tempDepartInfo["o_code"] ~= nil then
            user_bu_code = tempDepartInfo["o_code"]
         end
         local user_job = v["u_job"]
         local user_code = v["u_code"]
         local user_entry_time = v["u_entry_time"]
         local user_company = "江苏国动"
         local user_company_code = "32"
         
         
         local userAddSql = " insert into tb_user(user_name,user_password,user_role,user_number,user_bu_name,user_bu_code,user_job,user_code,user_entry_time,user_company,user_company_code) values('%s','%s',%d,'%s','%s','%s','%s','%s','%s','%s','%s') "
         userAddSql  = string.format(userAddSql,user_name,user_password,user_role,user_number,user_bu_name,user_bu_code,user_job,user_code,user_entry_time,user_company,user_company_code)
         db_query.excute(userAddSql)
         
  end
  
end






local tab = {}
tab["result"] = "success"
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))
return
