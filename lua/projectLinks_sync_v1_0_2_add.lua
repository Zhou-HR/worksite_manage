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

local new_proj_link_type = 28
local new_proj_link_name = "螺栓防锈处理"
local proj_modlue_type = "2"
local proj_modlue_name = "塔桅安装"

local decode_params = decode_data["params"]



local function modifyTableProjLinks(proj_code,proj_linksTab,projTab)
    local isHaveNewModule = false
    local proj_links_before = cjson.encode(proj_linksTab)
    if proj_linksTab ~= nil and proj_linksTab[1] ~= nil then
      if proj_linksTab[1]["proj_module_code"] == "1"  then
        if proj_linksTab[2]["proj_module_code"] == proj_modlue_type then
          local subLength = #proj_linksTab[2]["sub"]
          if proj_linksTab[2]["sub"][subLength - 1]["proj_link_type"] == new_proj_link_type then
            isHaveNewModule = true
          else
            proj_linksTab[2]["sub"][subLength + 1] = comm_func.table_clone(proj_linksTab[2]["sub"][subLength ])
            proj_linksTab[2]["sub"][subLength] = {
                                              name=new_proj_link_name,
                                              proj_link_type=new_proj_link_type
                                            }
          end
        end
      elseif proj_linksTab[2]["proj_module_code"] == "1"  then
        if proj_linksTab[3]["proj_module_code"] == proj_modlue_type then
          local subLength = #proj_linksTab[3]["sub"]
          if proj_linksTab[3]["sub"][subLength - 1]["proj_link_type"] == new_proj_link_type then
            isHaveNewModule = true
          else
            proj_linksTab[3]["sub"][subLength + 1] = comm_func.table_clone(proj_linksTab[3]["sub"][subLength ])
            proj_linksTab[3]["sub"][subLength] = {
                                              name=new_proj_link_name,
                                              proj_link_type=new_proj_link_type
                                            }
          end
        end
      else
        isHaveNewModule = true
      end
      
      if  isHaveNewModule == false then
        local proj_links = cjson.encode(proj_linksTab)
        local status, apps = db_project.project_module_links_add(proj_code,proj_links_before,proj_links,proj_modlue_name,proj_modlue_type,new_proj_link_name,new_proj_link_type)
        return status
      else
        local statusT, appsT = db_project.projectLinkType_get(proj_code,new_proj_link_type)
        if statusT == true and appsT[1] ~= nil  then
        else
          local status, apps = db_project.project_module_links_only_add(projTab,proj_code,proj_modlue_name,proj_modlue_type,new_proj_link_name,new_proj_link_type)
          return status
        end
      end
    end
    
end
local projTab = {}
local status, apps,count,total = db_query.projectList_get(nil,nil,nil,nil,nil,nil,nil,nil,nil,true,10000000,0)
if status == true and apps ~= nil and apps[1] ~= nil then
  for k, v in pairs(apps) do
    if v["proj_code"] ~= nil and cjson.decode(v["proj_links"]) ~= nil  then
      local insertLinkProjCode = modifyTableProjLinks(v["proj_code"],cjson.decode(v["proj_links"]),v)
      if insertLinkProjCode == true then
        table.insert(projTab,v["proj_code"])
  --break
      end
    end
    --break
  end
end
local tab= {}
tab["result"] = projTab 
tab["error"] = error_table.get_error("ERROR_NONE") 
ngx.say(cjson.encode(tab))


