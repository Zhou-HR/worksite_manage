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

local user_id = comm_func.get_http_header("user_id", ngx)

local decode_params = decode_data["params"]

local apps = {}
apps[1] = {
    module_name = "地质勘探",
    module_code = "0"
}
apps[2] = {
    module_name = "土建施工",
    module_code = "1"
}
apps[3] = {
    module_name = "塔桅安装",
    module_code = "2"
}
apps[4] = {
    module_name = "接电施工",
    module_code = "3"
}
apps[5] = {
    module_name = "配套安装",
    module_code = "4"
}
apps[6] = {
    module_name = "竣工交维",
    module_code = "5"
}
apps[7] = {
    module_name = "交付验收",
    module_code = "10"
}
apps[8] = {
    module_name = "拆站",
    module_code = "6"
}
apps[9] = {
    module_name = "安装电表",
    module_code = "7"
}
apps[10] = {
    module_name = "并购",
    module_code = "8"
}
--fixed by zhangjieqiong at 20200520 start
apps[11] = {
    module_name = "改造",
    module_code = "9"
}
--fixed by zhangjieqiong at 20200520 end

local tab = {}
tab["result"] = apps
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))


