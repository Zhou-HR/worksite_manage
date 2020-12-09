local uri_args = ngx.req.get_uri_args()
--local uploadPolicy = decode_data["uploadPolicy"]


local uploadPolicy = uri_args["uploadPolicy"]
local callback = uri_args["callback"]

local ak = "23249288";
local sk = "383204d206642d5104a2cb97d6d456c5";

local encodedPolicy = ngx.encode_base64(uploadPolicy)
--comm_func.do_dump_value(encodedPolicy,0)
if string.find(encodedPolicy, "+", 1) ~= nil then
    encodedPolicy = string.gsub(encodedPolicy, "+", "-")
end
--comm_func.do_dump_value(encodedPolicy,0)
if string.find(encodedPolicy, "/", 1) ~= nil then
    encodedPolicy = string.gsub(encodedPolicy, "/", "_")
end
if string.find(encodedPolicy, "=", 1) ~= nil then
    encodedPolicy = string.gsub(encodedPolicy, "=", "")
end
--sign = ngx.hmac_sha1(sk, encodedPolicy)
sign = ngx.hmac_sha1(sk, encodedPolicy)
sign = comm_func.to_hex(sign)
sign = string.lower(sign)

local temp = ngx.encode_base64(ak .. ":" .. encodedPolicy .. ":" .. sign);
if string.find(temp, "+", 1) ~= nil then
    temp = string.gsub(temp, "+", "-")
end
if string.find(temp, "/", 1) ~= nil then
    temp = string.gsub(temp, "/", "_")
end
if string.find(temp, "=", 1) ~= nil then
    temp = string.gsub(temp, "=", "")
end

local tokenInner = {}
--tokenInner["baichuanToken"] = "MjMyNDkyODg6ZXlKcGJuTmxjblJQYm14NUlqb2lNQ0lzSW01aGJXVnpjR0ZqWlNJNkltZGtkMjl5YTNOcGRHVWlMQ0psZUhCcGNtRjBhVzl1SWpvaUxURWlmUTpkN2NkNDMzMDY4ZDhhZTBjZGUxMWUwNjU0ZjJjOWRkM2NmOTQyMjA3"
tokenInner["baichuanToken"] = temp

local tabout = {}
tabout["result"] = tokenInner
tabout["error"] = error_table.get_error("ERROR_NONE")
--ngx.say(cjson.encode(tabout))
ngx.say(callback .. "(" .. cjson.encode(temp) .. ")")
--ngx.say(callback.."("..cjson.encode(sign)..")")