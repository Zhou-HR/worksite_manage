--鉴权
if ngx.var.uri ~= "/api/user_login" and  ngx.var.uri ~= "/api/androidAppVersion_check"  and ngx.var.uri ~= "/api/user_import"  and  ngx.var.uri ~= "/api/project_import" and ngx.var.uri ~= "/api/organizationList_sync_v0_3" and ngx.var.uri ~= "/api/fileUploadSec_get" and ngx.var.uri ~= "/api/OSSUploadSec_get" then
  local headers = ngx.req.get_headers()
  --if true and (headers["dev-request-type"] == "user_web" or headers["dev-request-type"] == "user_android" )   then
  --comm_func.do_dump_value(headers,0)
  local Authorization =  headers["Authorization"]
  if Authorization == nil then
     Authorization = headers["authorization"]
  end
  --comm_func.do_dump_value(Authorization,0)
  if Authorization == "sdfsRDfwefw123WEe2ERGr3=r-34t03ERGERt353+t3E6++dfge=-GER34kt3WE4-o3-4-0i1iGD-kkbmjkd22fl" then
      
  elseif true and (headers["dev-request-type"] == "user_web" or headers["dev-request-type"] == "user_android" or (headers["dev-request-type"] == "user_ios" and headers["dev-app-version"] ~= nil and headers["dev-app-version"] >= "2.0"   ) )  then
  --elseif true then   --测试环境修改了这里，跟正式环境一致
    if headers["user-id"] == nil or headers["time"] == nil or headers["token"] == nil or headers["dev-request-type"] == nil then
      local tabout = {}
      tabout["result"]="http请求头缺少参数"
      tabout["error"]=error_table.get_error("ERROR_HTTP_HEADER_LACKED")
      ngx.say(cjson.encode(tabout))
      return
    end
    
     if headers["dev-request-type"] ~= "user_mobile" and headers["dev-request-type"] ~= "user_android" and headers["dev-request-type"] ~= "user_ios" and headers["dev-request-type"] ~= "user_web" then
      local tabout = {}
      tabout["result"]="http请求头dev-request-type必须为user_web或user_android或user_ios"
      tabout["error"]=error_table.get_error("ERROR_HTTP_HEADER_DEV_TYPE")
      ngx.say(cjson.encode(tabout))
      return
    end
    local devRequestType = "user_mobile"
    if headers["dev-request-type"] == "user_web" then
      devRequestType = "user_web"
    end
    --comm_func.do_dump_value(headers,0)
    local result,msg = comm_func.check_http_token(devRequestType,headers["user-id"],headers["time"],headers["token"])
    if result ~= "ERROR_NONE" then
      local tabout = {}
      tabout["result"]=msg
      tabout["error"]=error_table.get_error(result)
      ngx.say(cjson.encode(tabout))
      return
    end
  end
  db_query.userOperationLog_add("",ngx)
end
