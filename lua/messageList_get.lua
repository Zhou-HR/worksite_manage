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

local user_id = comm_func.get_http_header("user_id",ngx)

local decode_params = decode_data["params"]
local cids = decode_params["cids"]
local cid_max = decode_params["cid_max"]

local dev_request_type = comm_func.get_http_header("dev-request-type",ngx)
local limit = decode_params["limit"]
local offset = decode_params["offset"]

if type(limit) ~= "number" or limit <= 0 then
  limit = 10
end

if type(offset) ~= "number" or offset <= 0 then
  offset = 0
end


if cids ~= nil and cids[1] ~= nil then
  cids = table.concat(cids,",")
else
  cids = nil 
end

if cid_max ~= nil and type(cid_max) ~= "number" then
  local tab = {}
  tab["result"]="cid_max不合法"
  tab["error"]=error_table.get_error("ERROR_PARAMS_WRONG")
  ngx.say(cjson.encode(tab))
  return
else
  
end

local status, apps,count,total = db_push_msg.msgPushList_get(user_id,cids,cid_max,limit,offset)

if status == true then
  for appsk,appsv in pairs(apps) do
     local receivers = appsv["receivers"]
     local receiversTab = cjson.decode(receivers)
     local isUpdate = false
     for t1,tv1 in pairs(receiversTab) do
        if tonumber( tv1["user_id"]) == tonumber(user_id) then
          receiversTab[t1]["view_status"] = 1
          isUpdate = true
        end
     end
     if isUpdate == true then
        db_push_msg.msgPushStatus_update(appsv["cid"],cjson.encode(receiversTab))
     end
     appsv["receivers"] = nil   
  end
  
	local tab = {} 
	local otherTab = {}
	otherTab["total"] = total
	otherTab["limit"] = limit
	otherTab["offset"] = offset
	otherTab["count"] = count
	tab["other"] = otherTab 
	tab["result"] = apps 
	tab["error"] = error_table.get_error("ERROR_NONE") 
	ngx.say(cjson.encode(tab))
else
	local tab = {} 
	tab["result"] = apps 
	tab["error"] = error_table.get_error("ERROR_MESSAGE_LIST_GET_FAILED") 
	ngx.say(cjson.encode(tab))
end

