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



local function modifyTableProjLinks(proj_code,proj_linksTab)
  if proj_linksTab ~= nil and proj_linksTab[1] ~= nil and  proj_linksTab[#proj_linksTab]["name"] == "竣工交尾"  then
    proj_linksTab[#proj_linksTab]["name"] = "竣工交维"
    local newLinksStr = cjson.encode(proj_linksTab)
    local sqlStr = string.format(" update tb_proj set proj_links = '%s' where proj_code ='%s' ",newLinksStr,proj_code)
    db_query.excute(sqlStr)
  else
    
  end
end

local status, apps,count,total = db_query.projectList_get(nil,nil,nil,nil,nil,nil,nil,nil,nil,true,10000000,0)
if status == true and apps ~= nil and apps[1] ~= nil then
  for k, v in pairs(apps) do
    modifyTableProjLinks(v["proj_code"],cjson.decode(v["proj_links"]))
  end
end
local tab= {}
tab["result"] = "OK" 
tab["error"] = error_table.get_error("ERROR_NONE") 
ngx.say(cjson.encode(tab))


