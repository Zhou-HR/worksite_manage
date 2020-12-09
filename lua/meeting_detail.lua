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
local meeting_id = decode_params["meeting_id"]
local limit = decode_params["limit"]
local offset = decode_params["offset"]


if type(meeting_id) ~= "number" then
  local tab = {}
  tab["resual"] = "meeting_id必须是整型"
  tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
end

if type(limit) ~= "number" or limit <= 0 then
  limit = 10
end

if type(offset) ~= "number" or offset < 10 then
  offset = 0
end

local status,apps,count,total = db_query.meetingList_get(meeting_id,nil,nil,nil,nil,nil,false,limit,offset)
if status == true and #apps > 0 then
  local Annexstatus,Annexapps,Annexcount,Annextotal = db_query.meetingAnnexList_get(meeting_id)
  if Annexstatus == true and #Annexapps > 0 then
    apps[1]["meeting_annex_info"] = Annexapps
  end
  local tab = {}
  apps[1]["meeting_pic"] = cjson.decode(apps[1]["meeting_pic"])


    local urlindex
    local newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
    --for k, v in pairs(apps) do
          for m in pairs(apps[1]["meeting_pic"]) do
            urlindex = string.find(apps[1]["meeting_pic"][m]["pic"], "com", 1)
            newurl = newurl..string.sub(apps[1]["meeting_pic"][m]["pic"],urlindex,string.len(apps[1]["meeting_pic"][m]["pic"]))
            apps[1]["meeting_pic"][m]["pic"] = newurl
            newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
          end
    --end
    if apps[1]["meeting_annex_info"] ~= nil then
      newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
      for m1 in pairs(apps[1]["meeting_annex_info"]) do
        urlindex = string.find(apps[1]["meeting_annex_info"][m1]["meeting_annex_url"], "com", 1)
        newurl = newurl..string.sub(apps[1]["meeting_annex_info"][m1]["meeting_annex_url"],urlindex,string.len(apps[1]["meeting_annex_info"][m1]["meeting_annex_url"]))
        apps[1]["meeting_annex_info"][m1]["meeting_annex_url"] = newurl
        newurl = "https://worksitemanage.oss-cn-hangzhou.aliyuncs."
      end
    end
  tab["result"] = apps[1]
  tab["error"] = error_table.get_error("ERROR_NONE")
  ngx.say(cjson.encode(tab))
  return
else
  local tab = {}
  tab["result"] = "获取会议失败"
  tab["error"] = error_table.get_error("ERROR_MEET_GET_FAILED")
  ngx.say(cjson.encode(tab))
  return
end


