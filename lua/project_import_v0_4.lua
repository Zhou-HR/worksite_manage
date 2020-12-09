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

local csvConstroctor = {
    "项目编码", "项目名称", "站型", "塔型", "塔高", "植筋或基础形式", "经度", "纬度", "详细地址", "立项日期", "事业部代码", "事业部", "公司代码"
}
local data = {}
data[1] = decode_params["proj_code"]
data[2] = decode_params["proj_name"]
data[3] = decode_params["proj_station_type"]
data[4] = decode_params["proj_tower_type"]
data[5] = decode_params["proj_tower_height"]
data[6] = decode_params["proj_base_type"]
data[7] = decode_params["proj_lon"]
data[8] = decode_params["proj_lat"]
data[9] = decode_params["proj_addr"]
data[10] = decode_params["proj_establish_time"]
data[11] = decode_params["proj_bu_code"]
data[12] = decode_params["proj_bu_name"]
data[13] = decode_params["proj_company_code"]
data[14] = decode_params["read_status"]
if data[3] == nil or data[3] == "" or data[3] == "" then
    data[3] = "落地"
end
local status, apps = db_query.project_import(data)
if status == true then
    local tab = {}
    tab["result"] = decode_params
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
    return
end

local tab = {}
tab["result"] = "导入项目数据失败"
tab["error"] = error_table.get_error("ERROR_PROJ_IMPORT_FAILED")
ngx.say(cjson.encode(tab))


