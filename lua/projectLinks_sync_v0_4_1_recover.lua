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
    local isHaveNewModule = false
    local proj_links_before = cjson.encode(proj_linksTab)
    if proj_linksTab ~= nil and proj_linksTab[1] ~= nil then
      if proj_linksTab[1]["proj_module_code"] == "1"  then
        if proj_linksTab[1]["sub"][1]["proj_link_type"] == 25 then
          isHaveNewModule = true
          table.remove(proj_linksTab[1]["sub"],1)
        end                          
      elseif proj_linksTab[2]["proj_module_code"] == "1"  then
        if proj_linksTab[2]["sub"][1]["sub"][1]["proj_link_type"] == 25 then
          isHaveNewModule = true
          table.remove(proj_linksTab[2]["sub"][1]["sub"],1)
        end
        if proj_linksTab[2]["sub"][2]["sub"][1]["proj_link_type"] == 25 then
          isHaveNewModule = true
          table.remove(proj_linksTab[2]["sub"][2]["sub"],1)
        end
      else
        isHaveNewModule = true
      end
      
      if isHaveNewModule == true then
        local proj_links = cjson.encode(proj_linksTab)
	--comm_func.do_dump_value(proj_links,0)
	db_project.excute(string.format(" update tb_proj set proj_links='%s' where proj_code='%s' ",proj_links,proj_code))
      end
    end
    
end
local projTab = {}
local status, apps,count,total = db_query.projectList_get(nil,nil,nil,nil,nil,nil,nil,nil,nil,true,10000000,0)
if status == true and apps ~= nil and apps[1] ~= nil then
  for k, v in pairs(apps) do
    if v["proj_code"] ~= nil and cjson.decode(v["proj_links"]) ~= nil then
      modifyTableProjLinks(v["proj_code"],cjson.decode(v["proj_links"]))
      table.insert(projTab,v["proj_code"])
    end
    --break
  end
end
local tab= {}
tab["result"] = projTab 
tab["error"] = error_table.get_error("ERROR_NONE") 
ngx.say(cjson.encode(tab))


