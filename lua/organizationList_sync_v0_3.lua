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

local status, appps = db_query.excute(" select * from  tb_organization  where LENGTH(o_code) = 4 and o_parent_code = ''   order by o_code asc  ")
local parentStatus, parentAppps = db_query.excute(" select * from  tb_organization  where LENGTH(o_code) = 2 order by o_code asc  ")

local parentTab = {}
for k, v in pairs(parentAppps) do
    parentTab[v["o_code"]] = v["o_name"]
end

if status == true and appps ~= nil then
    for k, v in pairs(appps) do
        local parentCode = string.sub(v["o_code"], 1, 2)
        if parentTab[parentCode] ~= nil then
            local sqlUpdate = string.format(" update tb_organization set o_parent_code='%s',o_parent_name='%s'  where o_code='%s' ", parentCode, parentTab[parentCode], v["o_code"])
            db_query.excute(sqlUpdate)
        end
    end
end

local tab = {}
tab["result"] = "success"
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))


