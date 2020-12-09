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
local link_fine_projcode = decode_params["link_fine_projcode"]
local start_time = nil 
local end_time = nil

if decode_params["start_time"] ~= nil then
  start_time = decode_params["start_time"]
end
if decode_params["end_time"] ~= nil then
  end_time = decode_params["end_time"]
end

if type(link_fine_projcode) ~= "string"   then
  local tab = {}
  tab["result"]="link_fine_projcode参数错误"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end


local linkFineTab = {}

linkFineTab[25] = {
                     name="施工进场",
                     fine_items={
                                  module_name="隐蔽工程资料",
                                  module_order=6,
                                  link_order={
                                              [1]=0
                                            }
                                }
                  }

linkFineTab[2] = {
                     name="开挖验收",
                     fine_items={
                                  module_name="塔基",
                                  module_order=0,
                                  link_order={
                                              [1]=0
                                            }
                                }
                  }

linkFineTab[3] = {
                     name="材料验收",
                     fine_items={
                                  module_name="隐蔽工程资料",
                                  module_order=6,
                                  link_order={
                                              [1]=1,
                                              [2]=2,
                                              [3]=3,
                                              [4]=4
                                            }
                                }
                  }
linkFineTab[4] = {
                     name="钢筋验收",
                     fine_items={
                                  module_name="塔基",
                                  module_order=0,
                                  link_order={
                                              [1]=1
                                            }
                                }
                  }
linkFineTab[5] = {
                     name="浇筑验收",
                     fine_items={
                                  module_name="塔基",
                                  module_order=0,
                                  link_order={
                                              [1]=2,
                                              [2]=3
                                            }
                                }
                  }
linkFineTab[6] = {
                     name="地网验收",
                     fine_items={
                                  module_name="塔基",
                                  module_order=0,
                                  link_order={
                                              [1]=5
                                            }
                                }
                  }

linkFineTab[7] = {
                     name="预埋件验收",
                     fine_items={
                                  module_name="塔基",
                                  module_order=0,
                                  link_order={
                                              [1]=4
                                            }
                                }
                  }
                  
linkFineTab[8] = {
                     name="基槽验收",
                     fine_items={
                                  module_name="机房",
                                  module_order=1,
                                  link_order={
                                              [1]=0
                                            }
                                }
                  }
linkFineTab[9] = {
                     name="钢筋工序验收",
                     fine_items={
                                  module_name="机房",
                                  module_order=1,
                                  link_order={
                                              [1]=1
                                            }
                                }
                  }

linkFineTab[10] = {
                     name="混凝土浇筑验收",
                     fine_items={
                                  module_name="机房",
                                  module_order=1,
                                  link_order={
                                              [1]=2,
                                              [2]=3
                                            }
                                }
                  }
linkFineTab[26] = {
                     name="整体验收",
                     fine_items={
                                  module_name="机房",
                                  module_order=1,
                                  link_order={
                                              [1]=4,
                                              [2]=5,
                                              [3]=6,
                                              [4]=7,
                                              [5]=8,
                                              [6]=9,
                                              [7]=10
                                            }
                                }
                  }
linkFineTab[17] = {
                     name="整体完工（初验）照片",
                     fine_items={
                                  module_name="铁塔",
                                  module_order=2,
                                  link_order={
                                              [1]=0,
                                              [2]=1,
                                              [3]=2,
                                              [4]=3,
                                              [5]=4,
                                              [6]=5,
                                              [7]=6
                                            }
                                },
                      fine_ext_items={
                                  {
                                    module_name="环境",
                                    module_order=5,
                                    link_order={
                                                [1]=0
                                              }
                                  }
                                }
                  }
linkFineTab[19] = {
                     name="电表及空开照片",
                     fine_items={
                                  module_name="市电引入",
                                  module_order=3,
                                  link_order={
                                              [1]=0
                                            }
                                }
                  }

linkFineTab[20] = {
                     name="线缆材质及埋深照片",
                     fine_items={
                                  module_name="市电引入",
                                  module_order=3,
                                  link_order={
                                              [1]=0,
                                              [2]=1,
                                              [3]=2,
                                              [4]=3
                                            }
                                }
                  }
linkFineTab[21] = {
                     name="底座固定照片",
                     fine_items={
                                  module_name="配套",
                                  module_order=4,
                                  link_order={
                                              [1]=0,
                                              [2]=1,
                                              [3]=2
                                            }
                                }
                  }
linkFineTab[22] = {
                     name="机房柜布线照片",
                     fine_items={
                                  module_name="配套",
                                  module_order=4,
                                  link_order={
                                              [1]=0,
                                              [2]=1,
                                              [3]=2
                                            }
                                }
                  }
linkFineTab[23] = {
                     name="整体完工照片（初验）",
                     fine_items={
                                  module_name="配套",
                                  module_order=4,
                                  link_order={
                                              [1]=0,
                                              [2]=1,
                                              [3]=2
                                            }
                                }
                  }
linkFineTab[24] = {
                     name="竣工照片",
                     fine_items={
                                  module_name="环境",
                                  module_order=5,
                                  link_order={
                                              [1]=0
                                            }
                                }
                  }
linkFineTab[11] = {
                     name="基础尺寸",
                     fine_items={
                                  module_name="塔基",
                                  module_order=0,
                                  link_order={
                                              [1]=2,
                                              [2]=3
                                            }
                                }
                  }
linkFineTab[12] = {
                     name="植筋验收",
                     fine_items={
                                  module_name="塔基",
                                  module_order=0,
                                  link_order={
                                              [1]=1
                                            }
                                }
                  }

local Projstatus, Projapps = db_project.Finelinks_detail_get(link_fine_projcode,start_time,end_time)
local result_search_temp = {}
if Projstatus ~= false and Projapps ~= nil and Projapps[1] ~= nil then
  for k, v in pairs(Projapps) do
      local tabtemp = {}
      tabtemp["proj_link_name"] = v["proj_link_name"]
      tabtemp["fine_item_extra"] = v["fine_item_extra"]
      tabtemp["fine_value"] = v["fine_value"]
      tabtemp["proj_module_name"] = v["proj_module_name"]
      tabtemp["proj_link_type"] = v["proj_link_type"]
      tabtemp["proj_link_id"] = v["proj_link_id"]
      tabtemp["fine_item_extra_value"] = v["fine_item_extra_value"]
      local Getstatus, Getapps = db_project.Getproj_module_code(tabtemp["proj_module_name"] )
      if Projstatus ~= false and Projapps ~= nil and Projapps[1] ~= nil then
      tabtemp["proj_module_code"] = Getapps[1]["proj_module_code"]  
      end

      local proj_link_type = v["proj_link_type"]

      if linkFineTab[proj_link_type] ~= nil then
        local itemStatus, itemStatusDatas
        if linkFineTab[proj_link_type]["fine_ext_items"] ~= nil then
          itemStatus, itemStatusDatas = db_project.fineItemsExt_get(nil,linkFineTab[proj_link_type]["fine_items"]["module_order"],linkFineTab[proj_link_type]["fine_items"]["link_order"],linkFineTab[proj_link_type]["fine_ext_items"])
        else
          itemStatus, itemStatusDatas = db_project.fineItems_get(nil,linkFineTab[proj_link_type]["fine_items"]["module_order"],linkFineTab[proj_link_type]["fine_items"]["link_order"])
        end

        local itemIdTab = {}
        local result_search = {}

        if itemStatus == true and itemStatusDatas ~= nil and itemStatusDatas[1] ~= nil then
          itemIdTab = cjson.decode(v["fine_item_ids"])
          if type(itemIdTab) == "table" then
            for m, n in pairs(itemIdTab) do
              for i = 1,table.maxn(itemStatusDatas) ,1 do
                if tonumber(n) == itemStatusDatas[i]["item_id"] then
                  local tabtemp1 = {}
                  tabtemp1["item_name"] = itemStatusDatas[i]["item_name"]
                  tabtemp1["item_value"] = itemStatusDatas[i]["item_value"]
                  table.insert (result_search,tabtemp1)
                end
              end
            end
          end
          tabtemp["fine_info_msg"] = result_search
        end
      end
      table.insert (result_search_temp,tabtemp)
  end
end

local result_search_fin = {}
local result_search_module_name = {}
local tj_fine_value = 0
if result_search_temp[1] ~= nil then
  result_search_module_name[1] = result_search_temp[1]["proj_module_name"]
    for i = 2,table.maxn(result_search_temp) ,1 do
      local curname = result_search_temp[i]["proj_module_name"]
      local curcnt = table.maxn(result_search_module_name)
      local nameexist = true
      for j = 1,curcnt,1 do
        if curname == result_search_module_name[j] then
          nameexist = false
          break
        end
      end
      if nameexist == true then
        table.insert(result_search_module_name,curname)
      end
    end

    for i = 1,table.maxn(result_search_module_name) ,1 do
      local itemTab = {}
      local itemDetail = {}
      itemTab["proj_module_name"] = result_search_module_name[i]
      for j = 1,table.maxn(result_search_temp) ,1 do
        local itemTabget = {}
        if itemTab["proj_module_name"] == result_search_temp[j]["proj_module_name"] then
          itemTabget["proj_link_type"] = result_search_temp[j]["proj_link_type"]
          itemTabget["proj_link_name"] = result_search_temp[j]["proj_link_name"]
          itemTabget["fine_value"] = result_search_temp[j]["fine_value"]
          itemTabget["fine_item_extra"] = result_search_temp[j]["fine_item_extra"]
          itemTabget["proj_link_id"] = result_search_temp[j]["proj_link_id"]
          itemTabget["fine_info_msg"] = result_search_temp[j]["fine_info_msg"]
          itemTabget["proj_module_code"] = result_search_temp[j]["proj_module_code"]
          itemTabget["fine_item_extra_value"] = result_search_temp[j]["fine_item_extra_value"]
          table.insert (itemDetail,itemTabget)
          tj_fine_value = tj_fine_value + tonumber(itemTabget["fine_value"])
        end
      end
      itemTab["fine_info_detail"] = itemDetail
      table.insert (result_search_fin,itemTab)
    end
    local tj_fine_value_tab = {}
    tj_fine_value_tab["tj_fine_value"] = tj_fine_value
    table.insert (result_search_fin,tj_fine_value_tab)
end

local tab = {}
--tab["mmmm"] = result_search_module_name
--tab["rtop"] = Projapps
tab["result"] = result_search_fin
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))




