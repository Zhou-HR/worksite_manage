ngx.req.read_body()
local data = ngx.req.get_body_data()

function postHttpRequestTask(postData, apiStr)
    local http = require("resty.http")
    local httpc = http.new()

    local hostName = "120.55.75.63"
    --hostName = comm_func.getIpFromHostName(hostName)
    local url = "http://" .. hostName .. ":2101/" .. apiStr

    local bodyLen = string.len(postData)

    local res, err = httpc:request_uri(url, {
        method = "POST",
        body = postData,
        headers = {
            ["cache_accesss_key"] = "496d1bac094f11e79d9c0a0027000010",
            ["Content-Length"] = bodyLen,
            ["Content-Type"] = "application/json"
        }
    })
    comm_func.do_dump_value(url, 0)
    comm_func.do_dump_value(postData, 0)
    comm_func.do_dump_value(res, 0)
    comm_func.do_dump_value(err, 0)
    if res ~= nil and res.status == 200 then
        local bodyJson = cjson.decode(res.body)
        return true, bodyJson
    else
        return false
    end
end

local status, resultContent = postHttpRequestTask("{\"processor_name\":\"lorameterv1\",\"ctrl_state\":0}", "api/Cache/CtrlData/GetList?startrow=0&rowcount=1000")

local tab = {}
if status then
    tab["result"] = resultContent
else
    tab["result"] = "OK"
end
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))
return

