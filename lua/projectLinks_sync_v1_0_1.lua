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



local function modifyTableProjLinks(proj_code,proj_linksTab,projTab)
    local isHaveNewModule = false
    local proj_links_before = cjson.encode(proj_linksTab)
    if proj_linksTab ~= nil and proj_linksTab[1] ~= nil then
      if proj_linksTab[1]["proj_module_code"] == "1"  then
        local subLength = #proj_linksTab[1]["sub"]
        if proj_linksTab[1]["sub"][subLength]["proj_link_type"] == 26 then
          isHaveNewModule = true
        else
          proj_linksTab[1]["sub"][subLength + 1] = {
                                            name="整体验收",
                                            proj_link_type=26
                                          }
        end
        if proj_linksTab[3]["proj_module_code"] == "3" then
          if proj_linksTab[3]["sub"][2]["proj_link_type"] == 19 then
            proj_linksTab[3]["sub"][2]["name"] = "电表及空开照片"
          end
          if proj_linksTab[3]["sub"][3]["proj_link_type"] == 20 then
            proj_linksTab[3]["sub"][3]["name"] = "线缆材质及埋深照片"
          end
        end
        if proj_linksTab[4]["proj_module_code"] == "4" then
          if proj_linksTab[4]["sub"][2]["proj_link_type"] == 22 then
            proj_linksTab[4]["sub"][2]["name"] = "机房柜布线照片"
          end
        end
        
      elseif proj_linksTab[2]["proj_module_code"] == "1"  then
        local subLength = #proj_linksTab[2]["sub"]
        if proj_linksTab[2]["sub"][subLength]["proj_link_type"] == 26 then
          isHaveNewModule = true
        else
          proj_linksTab[2]["sub"][subLength + 1] = {
                                            name="整体验收",
                                            proj_link_type=26
                                          }
        end
        if proj_linksTab[2]["sub"][2]["proj_module_code"] == "1-0" then
          if proj_linksTab[2]["sub"][2]["sub"][3]["proj_link_type"] == 4 then
            proj_linksTab[2]["sub"][2]["sub"][3]["name"] = "钢筋验收"
          end
        end
        
        if proj_linksTab[2]["sub"][3]["proj_module_code"] == "1-1" then
          if proj_linksTab[2]["sub"][3]["sub"][2]["proj_link_type"] == 9 then
            proj_linksTab[2]["sub"][3]["sub"][2]["name"] = "钢筋工序验收"
          end
          if proj_linksTab[2]["sub"][3]["sub"][3]["proj_link_type"] == 10 then
            proj_linksTab[2]["sub"][3]["sub"][3]["name"] = "混凝土浇筑验收"
          end
        end
        if proj_linksTab[4]["proj_module_code"] == "3" then
          if proj_linksTab[4]["sub"][2]["proj_link_type"] == 19 then
            proj_linksTab[4]["sub"][2]["name"] = "电表及空开照片"
          end
          if proj_linksTab[4]["sub"][3]["proj_link_type"] == 20 then
            proj_linksTab[4]["sub"][3]["name"] = "线缆材质及埋深照片"
          end
        end
         if proj_linksTab[5]["proj_module_code"] == "4" then
            if proj_linksTab[5]["sub"][2]["proj_link_type"] == 22 then
              proj_linksTab[5]["sub"][2]["name"] = "机房柜布线照片"
            end
          end
      else
        isHaveNewModule = true
      end
      
      if  isHaveNewModule == false then
        local proj_links = cjson.encode(proj_linksTab)
        local status, apps = db_project.project_module_links_add(proj_code,proj_links_before,proj_links,"土建施工","1","整体验收",26)
        return status
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


