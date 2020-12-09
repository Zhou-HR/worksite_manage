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
local proj_link_id = decode_params["proj_link_id"]
local fine_item_ids = decode_params["fine_item_ids"]
local fine_item_extra = decode_params["fine_item_extra"]
local fine_item_extra_value = decode_params["fine_item_extra_value"]
local fine_from_review = decode_params["fine_from_review"]
if fine_from_review == nil then
	fine_from_review = decode_params["fine_form_review"]
end
local user_idHeader = comm_func.get_http_header("user_id",ngx)


if type(proj_link_id) ~= "number"   then
  local tab = {}
  tab["result"]="proj_link_id参数错误"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

fine_item_extra = comm_func.trim_string(fine_item_extra)
if fine_item_extra_value ~= nil and type(fine_item_extra_value) ~= "number"  then
  local tab = {}
  tab["result"]="fine_item_extra_value参数错误"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end
if fine_item_extra_value ~= nil and fine_item_extra_value < 0 then
  local tab = {}
  tab["result"]="fine_item_extra_value必须大于0"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if (fine_item_extra ~= nil and string.len(fine_item_extra) > 0 and fine_item_extra_value == nil ) or (fine_item_extra == nil and fine_item_extra_value ~= nil) then
  local tab = {}
  tab["result"]="fine_item_extra和fine_item_extra_value必须同时存在或不存在"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

local fineItemCheckOk = false
local fineItemTotalValue = 0
if fine_item_ids ~= nil and type(fine_item_ids) ~= "table" then
  local tab = {}
  tab["result"]="fine_item_ids参数不存在"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end
local fineItemDataInfo
if fine_item_ids ~= nil and type(fine_item_ids) == "table" and #fine_item_ids > 0 then
  local fineItemStatus,fineItemData = db_project.fineItems_get(fine_item_ids,nil,nil)
  fineItemDataInfo = fineItemData
  if fineItemData ~= nil and #fineItemData == #fine_item_ids then
    fineItemCheckOk = true
    for k, v in pairs(fineItemData) do
      fineItemTotalValue = fineItemTotalValue + v["item_value"]
    end 
  end
end
if fineItemCheckOk == false then
	--[==[
  local tab = {}
  tab["result"]="fine_item_ids参数不存在"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
]==]--
end

if fine_item_extra_value ~= nil then
  fineItemTotalValue = fineItemTotalValue + fine_item_extra_value
end


local Projstatus, Projapps = db_project.linksWithId_get(proj_link_id)
local linkInfo
if Projstatus == true and Projapps ~= nil and Projapps[1] ~= nil then
  linkInfo = Projapps[1]
  if Projapps[1]["proj_link_status"] ~= 3 and Projapps[1]["proj_link_status"] ~= 5 and Projapps[1]["proj_link_status"] ~= 7 and Projapps[1]["proj_link_status"] ~= 8  then
      local tab = {}
      tab["result"]="该环节尚未审批通过"
      tab["error"]=error_table.get_error("ERROR_LINK_REVIEWED_NO_PASS")
      ngx.say(cjson.encode(tab))
      return
  end
 -- if Projapps[1]["proj_link_fine_value"] > 0 or Projapps[1]["proj_link_fine_detail_id"] > 0 then
 --   local tab = {}
 --   tab["result"]="该环节已被扣款"
 --   tab["error"]=error_table.get_error("ERROR_LINK_FINED_ALREADY")
 --   ngx.say(cjson.encode(tab))
 --   return
 -- end
else
  local tab = {}
  tab["result"]="proj_link_id不存在"
  tab["error"]=error_table.get_error("ERROR_LINK_ID_NO_EXISTS")
  ngx.say(cjson.encode(tab))
  return
end


local isAdmin  = false
local userStatus,userApps = db_query.userFromId_get(user_idHeader)
local userInfo
local proj_bu_code
if userStatus == true and userApps ~= nil and userApps[1] ~= nil  then
  userApps[1]["user_role_v2"] = db_query.userRoleValue_get(userApps[1]["user_role"])
  userInfo = userApps[1]
  isAdmin =  db_query.userAdmin_is(userApps[1],user_idHeader)
  proj_bu_code = userApps[1]["user_bu_code"]
  --if isAdmin == false then
  if db_query.permission_check_project_fine(userApps[1]["user_role_v2"]) == false  then
 -- if userApps[1]["user_role"] == 1 then 
    local tab = {} 
    tab["result"] = "您的账号无扣款权限" 
    tab["error"] = error_table.get_error("ERROR_USER_PERMISSION_REFUSE") 
    ngx.say(cjson.encode(tab))
    return
  end
  if db_query.user_is_group_admin(userApps[1]["user_role_v2"])  == true or  db_query.user_is_group_jianli(userApps[1]["user_role_v2"]) then
    proj_bu_code = nil
  else
    proj_bu_code = string.sub(userApps[1]["user_bu_code"],1,2)
    proj_bu_code = comm_func.buprovince_get(proj_bu_code)
  end
else
  local tab = {} 
  tab["result"] = "扣款失败" 
  tab["error"] = error_table.get_error("ERROR_LINK_FINE_FAILED") 
  ngx.say(cjson.encode(tab))
  return
end

comm_func.do_dump_value(Projapps,0)
comm_func.do_dump_value(fine_from_review,0)




local nowFineStatus,nowFineDatas =  db_project.linkFine_get(linkInfo["proj_code"],linkInfo["proj_link_type"])
local nowFineData
if nowFineStatus == true  then
  if nowFineDatas ~= nil and nowFineDatas[1] ~= nil then
    --有扣款记录
    nowFineData = nowFineDatas[1]
    if userInfo["user_role_v2"] >= nowFineDatas[1]["reviewer_role"]  then
        --有扣款记录
        -- local tab = {}
        -- tab["result"] = "已扣款，无法再次扣款" 
        -- tab["error"] = error_table.get_error("ERROR_LINK_FINE_FAILED") 
        -- ngx.say(cjson.encode(tab))
        -- return
    else
       --OK,判断时间
      local nowtime = ngx.now()
      local curtime_year,curtime_month,finetime_year,finetime_month
      curtime_year = os.date("%Y",nowtime)
      curtime_month = os.date("%m",nowtime)
      finetime_year = os.date("%Y",nowFineDatas[1]["fine_time"])
      finetime_month = os.date("%m",nowFineDatas[1]["fine_time"])
      
      ngx.log(ngx.ERR, "curtime_year: ", curtime_year)
      ngx.log(ngx.ERR, "finetime_year: ", finetime_year)
      ngx.log(ngx.ERR, "curtime_month: ", curtime_month)

      if curtime_year == finetime_year and (tonumber(curtime_month) - tonumber(finetime_month) <= 1 and tonumber(curtime_month) - tonumber(finetime_month) >= 0) then
        --OK,可以扣款
      elseif tonumber(curtime_year) > tonumber(finetime_year) and (tonumber(curtime_month) == 1) then
      	--ok
      else
        local tab = {}
        tab["result"] = "扣款失败,只能修改"..tostring(tonumber(finetime_month)).."月".."--"..tostring(tonumber(finetime_month)+1).."月扣款项" 
        tab["error"] = error_table.get_error("ERROR_LINK_FINE_FAILED") 
        ngx.say(cjson.encode(tab))
        return
      end
    end
  else
    -- OK,无扣款记录可以扣款
  end
else
  local tab = {}
  tab["result"] = "扣款失败" 
  tab["error"] = error_table.get_error("ERROR_LINK_FINE_FAILED") 
  ngx.say(cjson.encode(tab))
  return
end
local projInfo

local status, apps,count,total = db_query.projectList_get(linkInfo["proj_code"],nil,nil,nil,nil,nil,nil,proj_bu_code,nil,false,1,0)

if status == true and apps ~= nil and apps[1] ~= nil then
  projInfo = apps[1]
  local status, apps,count,total = db_query.organizationList_get(true,projInfo["proj_company_code"],userInfo["user_bu_code"],nil,projInfo["proj_company_code"],nil,nil,1,0)
  if status == true and apps ~= nil and apps[1] ~= nil then
    projInfo["proj_company_name"] = apps[1]["o_name"]
  end
end
if projInfo == nil then
  local tab = {}
  tab["result"] = "扣款失败" 
  tab["error"] = error_table.get_error("ERROR_LINK_FINE_FAILED") 
  ngx.say(cjson.encode(tab))
  return
end

local tongjiTab ={}
tongjiTab["gc_tj_gj"] = -1
tongjiTab["gc_tj_hnt"] = -1
tongjiTab["gc_tj_dw"] = -1
tongjiTab["gc_tj_qt"] = -1
tongjiTab["gc_jd_cl"] = -1
tongjiTab["gc_jd_gy"] = -1
tongjiTab["gc_yjzl_jd"] = -1
tongjiTab["gc_yjzl_zb"] = -1
tongjiTab["gc_yjzl_zp"] = -1
tongjiTab["cg_tt_cp"] = -1
tongjiTab["cg_tt_az"] = -1
tongjiTab["cg_pt_pt"] = -1

if fineItemDataInfo ~= nil then
  
end

if linkInfo["proj_link_type"] ==  4 or linkInfo["proj_link_type"] ==  9 or linkInfo["proj_link_type"] ==  12 then
--钢筋验收、钢筋工序验收、植筋验收
--
  tongjiTab["gc_tj_gj"] = fineItemTotalValue
elseif linkInfo["proj_link_type"] ==  5 or linkInfo["proj_link_type"] ==  10 or linkInfo["proj_link_type"] ==  11 then
--浇筑验收、混凝土浇筑验收、基础尺寸
--
  tongjiTab["gc_tj_hnt"] = fineItemTotalValue
elseif linkInfo["proj_link_type"] ==  6  then
--地网验收
--
  tongjiTab["gc_tj_dw"] = fineItemTotalValue
elseif linkInfo["proj_link_type"] ==  2 or linkInfo["proj_link_type"] ==  7  or linkInfo["proj_link_type"] ==  8 or  linkInfo["proj_link_type"] ==  26 then
--开挖验收、预埋件验收、基槽验收、整体验收
--
  tongjiTab["gc_tj_qt"] = fineItemTotalValue
elseif linkInfo["proj_link_type"] ==  19  then
--电表及空开照片
--
  tongjiTab["gc_jd_cl"] = fineItemTotalValue
elseif linkInfo["proj_link_type"] ==  20  then
--线缆材质及埋深照片
--
  if fineItemDataInfo ~= nil then
    local gc_jd_cl_value = 0
    for k, v in pairs(fineItemDataInfo) do
      if v["module_order"]== 3 and v["link_order"] == 0 then
        gc_jd_cl_value = gc_jd_cl_value + v["item_value"]
      end
    end 
    if gc_jd_cl_value > 0 then
      tongjiTab["gc_jd_cl"] = gc_jd_cl_value
      tongjiTab["gc_jd_gy"] = fineItemTotalValue - gc_jd_cl_value
    else
      tongjiTab["gc_jd_gy"] = fineItemTotalValue
    end
  else
    tongjiTab["gc_jd_gy"] = fineItemTotalValue
  end
elseif linkInfo["proj_link_type"] ==  25  then
--施工进场
--
  tongjiTab["gc_yjzl_jd"] = fineItemTotalValue
elseif linkInfo["proj_link_type"] ==  3  then
--材料验收
--
  tongjiTab["gc_yjzl_zb"] = fineItemTotalValue
elseif linkInfo["proj_link_type"] ==  17  then
--整体完工照片（初验）
--
  if fineItemDataInfo ~= nil then
    local cg_tt_cp_value = 0
    for k, v in pairs(fineItemDataInfo) do
      if v["module_order"]== 2 and (v["link_order"] == 0  or v["link_order"] == 1 or v["link_order"] == 2) then
        cg_tt_cp_value = cg_tt_cp_value + v["item_value"]
      end
    end 
    if cg_tt_cp_value > 0 then
      tongjiTab["cg_tt_cp"] = cg_tt_cp_value
      tongjiTab["cg_tt_az"] = fineItemTotalValue - cg_tt_cp_value
    else
      tongjiTab["cg_tt_az"] = fineItemTotalValue
    end
  else
    tongjiTab["cg_tt_az"] = fineItemTotalValue
  end
elseif linkInfo["proj_link_type"] ==  21 or linkInfo["proj_link_type"] ==  22 or linkInfo["proj_link_type"] ==  23  then
--底座固定照片、机柜布线照片、整体完工照片（初验）
--
  tongjiTab["cg_pt_pt"] = fineItemTotalValue
else 
  tongjiTab["gc_yjzl_zp"] = fineItemTotalValue
end



local Finestatus, Fineapps = db_project.linkFine_set( linkInfo,userInfo,nowFineData,projInfo,tongjiTab,fine_item_ids,fine_item_extra,fine_item_extra_value,fineItemTotalValue)

if Finestatus == true then
  --更新工程项目里的 施工环节状态proj_link_status(针对移动端是否勾选扣款项)
  if linkInfo["proj_link_status"] == 7 or linkInfo["proj_link_status"] == 8 then 
    local projUpStatus = db_project.linkFine_proj_updata(linkInfo,true,nil)
  end
  --如果点击追加照片后仍提交扣款申请，则更新扣款记录里的权限reviewer_role
  if linkInfo["proj_link_pic_add_number"] == 6 then
    --local projUpStatus = db_project.linkFine_proj_updata(linkInfo,nil,true)
  end



  local tab = {}
  tab["result"] = "ok" 
  tab["error"] = error_table.get_error("ERROR_NONE") 
  ngx.say(cjson.encode(tab))
else
  local tab = {}
  tab["result"] = "扣款失败" 
  tab["error"] = error_table.get_error("ERROR_LINK_FINE_FAILED") 
  ngx.say(cjson.encode(tab))
  return
end

