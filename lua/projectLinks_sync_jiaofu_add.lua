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

ngx.log(ngx.ERR, "sync info -------: ", 1111111)

local tab = {}
tab["result"]="参数必须是JSON格式"
tab["error"]=error_table.get_error("ERROR_JSON_WRONG")

local function modifyTableProjLinks(proj_code,proj_linksTab)
  --comm_func.do_dump_value("------zjq---jiaofu---------------------------------",0)
  comm_func.do_dump_value(proj_linksTab,0)
  local statusT, appsT = db_project.projectLinkType_get(proj_code,34)
  if statusT == true and appsT[1] ~= nil  then
  else
    local isHaveNewModule = false
    for plk, plv in pairs(proj_linksTab) do
      if plv["proj_module_code"] == "10" or plv["proj_module_code"] == 10 then
        for plsubk, plsubv in pairs(plv["sub"]) do
          if plsubv["proj_link_type"] == "34" or plv["proj_link_type"] == 34 then
            isHaveNewModule  = true
            break
          end
        end 
      end
      if isHaveNewModule == true then
        break
      end
    end 
    comm_func.do_dump_value("------zjq---jiaofu----0000000000000000000-----------------------------------------------",0)
    if isHaveNewModule == false then
      local newProj_linksTab = comm_func.table_clone(proj_linksTab)
      local newProj_linksTabLength = #newProj_linksTab
      local newModuleTab = {}
      newModuleTab["proj_module_code"] = "10"
      newModuleTab["name"] = "交付验收"
      newModuleTab["sub"] = {}
      local newLinkTab = {}
      newLinkTab["name"] = "交付单"
      newLinkTab["proj_link_type"] = 34
      local newLinkTab2 = {}
      newLinkTab2["name"] = "基站设备"
      newLinkTab2["proj_link_type"] = 35
      newModuleTab["sub"][1] = newLinkTab
      newModuleTab["sub"][2] = newLinkTab2
      --newProj_linksTab[newProj_linksTabLength + 1] = newModuleTab
      
      newProj_linksTab[newProj_linksTabLength + 1] = newProj_linksTab[newProj_linksTabLength]
      newProj_linksTab[newProj_linksTabLength    ] = newProj_linksTab[newProj_linksTabLength - 1]
      newProj_linksTab[newProj_linksTabLength - 1] = newProj_linksTab[newProj_linksTabLength - 2]
      newProj_linksTab[newProj_linksTabLength - 2] = newProj_linksTab[newProj_linksTabLength - 3]
      newProj_linksTab[newProj_linksTabLength - 3] = newModuleTab
    
    
    	comm_func.do_dump_value(newProj_linksTab,0)
    	comm_func.do_dump_value("------zjq---jiaofu-----222222222222222222222----------------------------------------------",0)
    
      local proj_links_before = cjson.encode(proj_linksTab)
      local proj_links = cjson.encode(newProj_linksTab)
      
      comm_func.do_dump_value(proj_links,0)
      local status, apps = db_project.project_module_links_add_jiaofu(proj_code,proj_links_before,proj_links,"交付验收","10","交付单",34,"基站设备",35)
    end
    
  end
end

--local status, apps,count,total = db_query.projectList_get(nil,nil,nil,nil,nil,nil,nil,nil,nil,true,100000,0)
local status, apps,count,total = db_query.projectList_get("GDJZAAAA201905YD",nil,nil,nil,nil,nil,nil,nil,nil,true,1,0)
--comm_func.do_dump_value(apps,0)
if status == true and apps ~= nil and apps[1] ~= nil then
  for k, v in pairs(apps) do
    modifyTableProjLinks(v["proj_code"],cjson.decode(v["proj_links"]))
  end
end

comm_func.do_dump_value("------zjq---jiaofu-----end--------end---------end-------------end----------------",0)

local tab= {}
tab["result"] = "OK" 
tab["error"] = error_table.get_error("ERROR_NONE") 
ngx.say(cjson.encode(tab))


