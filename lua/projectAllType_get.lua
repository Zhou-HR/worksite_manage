ngx.req.read_body()
local data = ngx.req.get_body_data()




--db_query.projectAllType_set(allType[1]["name"],allType[1]["value"],cjson.encode(allType[1]["sub"]))
--db_query.projectAllType_set(allType[2]["name"],allType[2]["value"],cjson.encode(allType[2]["sub"]))
--db_query.projectAllType_set(allType[3]["name"],allType[3]["value"],cjson.encode(allType[3]["sub"]))

local tab = {}
tab["result"] = allType
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))


