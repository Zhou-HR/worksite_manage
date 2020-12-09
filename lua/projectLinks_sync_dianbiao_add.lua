ngx.req.read_body()
local data = ngx.req.get_body_data()
local decode_data = cjson.decode(data)
if decode_data == nil then
    local tab = {}
    tab["result"] = "参数必须是JSON格式"
    tab["error"] = error_table.get_error("ERROR_JSON_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local decode_params = decode_data["params"]

ngx.log(ngx.ERR, "dianbiao: ", 1111111)

local tab = {}
tab["result"] = "参数必须是JSON格式"
tab["error"] = error_table.get_error("ERROR_JSON_WRONG")
ngx.say(cjson.encode(tab))
return

--local function modifyTableProjLinks(proj_code,proj_linksTab)
--  comm_func.do_dump_value("------ggg---9999999",0)
--  comm_func.do_dump_value(proj_linksTab,0)
--  local statusT, appsT = db_project.projectLinkType_get(proj_code,28)
--  if statusT == true and appsT[1] ~= nil  then
--  else
--    local isHaveNewModule = false
--    for plk, plv in pairs(proj_linksTab) do
--      if plv["proj_module_code"] == "7" or plv["proj_module_code"] == 7 then
--        for plsubk, plsubv in pairs(plv["sub"]) do
--          if plsubv["proj_link_type"] == "28" or plv["proj_link_type"] == 28 then
--            isHaveNewModule  = true
--            break
--          end
--        end 
--      end
--      if isHaveNewModule == true then
--        break
--      end
--    end 
--    if isHaveNewModule == false then
--      local newProj_linksTab = comm_func.table_clone(proj_linksTab)
--      local newProj_linksTabLength = #newProj_linksTab
--      local newModuleTab = {}
--      local newLinkTab = {}
--      newModuleTab["proj_module_code"] = "7"
--      newModuleTab["name"] = "安装电表"
--      newModuleTab["sub"] = {}
--      newLinkTab["name"] = "安装电表照片"
--      newLinkTab["proj_link_type"] = 28
--      newModuleTab["sub"][1] = newLinkTab
--      newProj_linksTab[newProj_linksTabLength + 1] = newModuleTab
--      local proj_links_before = cjson.encode(proj_linksTab)
--      local proj_links = cjson.encode(newProj_linksTab)
--      
--      comm_func.do_dump_value(proj_links,0)
--    
--      local status, apps = db_project.project_module_links_add(proj_code,proj_links_before,proj_links,"安装电表","7","装电表照片",28)
--    end
--    
--  end
--end
--
--local status, apps,count,total = db_query.projectList_get(nil,nil,nil,nil,nil,nil,nil,nil,nil,true,10000000,0)
----local status, apps,count,total = db_query.projectList_get(nil,nil,nil,nil,nil,nil,nil,nil,nil,true,1,0)
--comm_func.do_dump_value(apps,0)
--if status == true and apps ~= nil and apps[1] ~= nil then
--  for k, v in pairs(apps) do
--    modifyTableProjLinks(v["proj_code"],cjson.decode(v["proj_links"]))
--  end
--end
--local tab= {}
--tab["result"] = "OK" 
--tab["error"] = error_table.get_error("ERROR_NONE") 
--ngx.say(cjson.encode(tab))
--
--
