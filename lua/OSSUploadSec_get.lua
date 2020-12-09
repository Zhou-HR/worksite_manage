local uri_args = ngx.req.get_uri_args()

local callback = uri_args["callback"]
local expireTime = math.ceil(ngx.now()) + 3600 - 1
local status, res = comm_func.getHttpRequestDo("", "127.0.0.1", 7080, "", "")
comm_func.do_dump_value(res, 0)
local result = {}
result = res
if status == true then
    result["error"] = error_table.get_error("ERROR_NONE")
else

end
if callback ~= nil then
    ngx.say(callback .. "(" .. cjson.encode(result) .. ")")
else
    if result ~= nil then
        result["expireTime"] = expireTime
    end
    ngx.say(cjson.encode(result))
end
