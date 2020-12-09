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
  local statusT, appsT = db_project.projectLinkType_get(proj_code,24)
  if statusT == true and appsT[1] ~= nil  then
  else
    local isHaveNewModule = false
    for plk, plv in pairs(proj_linksTab) do
      if plv["proj_module_code"] == "5" or plv["proj_module_code"] == 5 then
        for plsubk, plsubv in pairs(plv["sub"]) do
          if plsubv["proj_link_type"] == "24" or plv["proj_link_type"] == 24 then
            isHaveNewModule  = true
            break
          end
        end 
      end
      if isHaveNewModule == true then
        break
      end
    end 
    if isHaveNewModule == false then
      local newProj_linksTab = comm_func.table_clone(proj_linksTab)
      local newProj_linksTabLength = #newProj_linksTab
      local newModuleTab = {}
      local newLinkTab = {}
      newModuleTab["proj_module_code"] = "5"
      newModuleTab["name"] = "竣工交维"
      newModuleTab["sub"] = {}
      newLinkTab["name"] = "竣工照片"
      newLinkTab["proj_link_type"] = 24
      newModuleTab["sub"][1] = newLinkTab
      newProj_linksTab[newProj_linksTabLength + 1] = newModuleTab
      local proj_links_before = cjson.encode(proj_linksTab)
      local proj_links = cjson.encode(newProj_linksTab)
    
      local status, apps = db_project.project_module_links_add(proj_code,proj_links_before,proj_links,"竣工交维","5","竣工照片",24)
    end
    
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


