local common_fun = {}

function common_fun.to_hex(str)
    return (str:gsub('.', function(c)
        return string.format('%02X', string.byte(c))
    end))
end

function common_fun.api_name_get(api)
    local apiTab = {}
    apiTab["/api/user_login"] = "登录"
    apiTab["/api/userPassword_change"] = "修改密码"
    apiTab["/api/projectList_get"] = "获取项目"
    apiTab["/api/projectLink_get"] = "获取项目施工环节"
    apiTab["/api/projectLinkList_get"] = "获取待审核列表"
    apiTab["/api/projectLink_review"] = "审核施工环节"
    apiTab["/api/projectLink_submit"] = "提交审核"
    return apiTab[api]
end

function common_fun.get_key_value(key)
    local value = red:get(key)
    return value
end

function common_fun.set_key_value(key, value, exptime)
    red:set(key, value)
    red:expire(key, exptime)
end

function common_fun.do_check_user_id_valid(userId)
    if userId ~= nil and type(userId) == "number" and userId > 0 then
        return 1
    end
    if userId ~= nil and type(userId) == "string" and tonumber(userId) > 0 then
        return 1
    end
    return 0
end

function common_fun.get_from_cache(key)
    local cache_ngx = ngx.shared.token_cache
    local value = cache_ngx:get(key)
    return value
end

function common_fun.set_to_cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end

    local cache_ngx = ngx.shared.token_cache
    local succ, err, forcible = cache_ngx:set(key, value, exptime)
    return succ
end

function common_fun.delete_from_cache(key)
    local cache_ngx = ngx.shared.token_cache
    local value = cache_ngx:delete(key)
end


--2016-08-18 16:49:43
function common_fun.check_format_time(formatTime)
    if string.len(formatTime) ~= 19 then
        return false
    end
    local numerTIi = tonumber(string.sub(formatTime, 1, 4))
    if numerTIi < 2016 then
        return false
    end

    numerTIi = tonumber(string.sub(formatTime, 6, 7))
    if numerTIi < 1 or numerTIi > 12 then
        return false
    end

    numerTIi = tonumber(string.sub(formatTime, 9, 10))
    if numerTIi < 0 or numerTIi > 59 then
        return false
    end

    numerTIi = tonumber(string.sub(formatTime, 12, 13))
    if numerTIi < 0 or numerTIi > 23 then
        return false
    end

    numerTIi = tonumber(string.sub(formatTime, 15, 16))
    if numerTIi < 0 or numerTIi > 59 then
        return false
    end

    numerTIi = tonumber(string.sub(formatTime, 18, 19))
    if numerTIi < 0 or numerTIi > 59 then
        return false
    end

    return true
end

function common_fun.trim_string(str)
    if str == nil then
        return ""
    end
    str = tostring(str)
    return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end

function common_fun.sql_singleQuotationMarks(str)
    if str == nil then
        return ""
    end
    local normalStr = " " .. str .. " "
    local strTab = common_fun.split_string(normalStr, "'")
    return table.concat(strTab, "''")
end
function common_fun.sql_singleQuotationEscape(str)
    if str == nil then
        return ""
    end
    local normalStr = " " .. str .. " "
    local strTab = common_fun.split_string(normalStr, "'")
    return table.concat(strTab, "\'")
end

function common_fun.file_exists(filePath)
    local file = io.open(filePath, "rb")
    if file then
        file:close()
    end
    return file ~= nil
end

function common_fun.generate_radom_number(n, m)
    math.randomseed(os.clock() * math.random(1000000, 90000000) + math.random(1000000, 9000000))
    return math.random(n, m)
end

function common_fun.generate_radom_str_cn(lenStr)
    local BC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local SC = "abcdefghijklmnopqrstuvwxyz"
    local NO = "0123456789"
    local maxLen = 0
    local templete = ""
    templete = BC .. SC .. NO
    maxLen = 62
    local srt = {}
    for i = 1, lenStr, 1 do
        local index = common_fun.generate_radom_number(1, maxLen)
        srt[i] = string.sub(templete, index, index)
    end
    return table.concat(srt, "")
end

function common_fun.getIpFromHostName(hostName)
    local resultHostIp = hostName
    local resolver = require "resty.dns.resolver"
    local r, err = resolver:new {
        nameservers = { "114.114.114.114", { "114.114.115.115", 53 } },
        retrans = 5, -- 5 retransmissions on receive timeout
        timeout = 2000, -- 2 sec
    }

    if not r then
        common_fun.do_dump_value("failed to instantiate the resolver: ", 0)
        return resultHostIp
    end

    local answers, err = r:query(hostName)
    if not answers then
        common_fun.do_dump_value("failed to query the DNS server: ", 0)
        return resultHostIp
    end

    if answers.errcode then
        common_fun.do_dump_value("server returned error code: ", 0)
        return resultHostIp
    end

    for i, ans in ipairs(answers) do
        --common_fun.do_dump_value(ans.name,0)
        --common_fun.do_dump_value(ans.address,0)
        --common_fun.do_dump_value(ans.cname,0)
        ---common_fun.do_dump_value(ans.type,0)
        --common_fun.do_dump_value(ans.class,0)
        --common_fun.do_dump_value(ans.ttl,0)
        if ans.address ~= nil then
            resultHostIp = ans.address
        end
    end
    return resultHostIp
end

function common_fun.upload_file_to_cdn(filePath, fileName)
    local fh = assert(io.open(filePath, "rb"))
    local fileLen = assert(fh:seek("end"))
    fh:close()
    local f = assert(io.open(filePath, 'r'))
    local content = f:read("*all")
    f:close()

    local boundaryStr = "----gdserverupload"
    local http = require("resty.http")
    local httpc = http.new()

    local hostName = "upload.media.aliyun.com"
    hostName = common_fun.getIpFromHostName(hostName)
    local url = "http://" .. hostName .. "/api/proxy/upload"
    local bodyTab = {}
    bodyTab[1] = "\r\n--" .. boundaryStr .. "\r\n"
    bodyTab[2] = "Content-Disposition: form-data; name=\"size\"" .. "\r\n"
    bodyTab[3] = "Content-Type: text/plain; charset=UTF-8" .. "\r\n"
    bodyTab[4] = "\r\n"
    bodyTab[5] = tostring(fileLen) .. "\r\n"

    bodyTab[6] = "--" .. boundaryStr .. "\r\n"
    bodyTab[7] = "Content-Disposition: form-data; name=\"dir\"" .. "\r\n"
    bodyTab[8] = "Content-Type: text/plain; charset=UTF-8" .. "\r\n"
    bodyTab[9] = "\r\n"
    bodyTab[10] = "node_approved" .. "\r\n"

    bodyTab[11] = "--" .. boundaryStr .. "\r\n"
    bodyTab[12] = "Content-Disposition: form-data; name=\"name\"" .. "\r\n"
    bodyTab[13] = "Content-Type: text/plain; charset=UTF-8" .. "\r\n"
    bodyTab[14] = "\r\n"
    bodyTab[15] = fileName .. "\r\n"

    bodyTab[16] = "--" .. boundaryStr .. "\r\n"
    bodyTab[17] = "Content-Disposition: form-data; name=\"content\"; filename=\"nodes.zip\"" .. "\r\n"
    bodyTab[18] = "Content-Type: application/octet-stream" .. "\r\n"
    bodyTab[19] = "Content-Transfer-Encoding: binary" .. "\r\n"
    bodyTab[20] = "\r\n"
    bodyTab[21] = content .. "\r\n"

    bodyTab[22] = "--" .. boundaryStr .. "--\r\n"
    local bodyStr = table.concat(bodyTab, "")
    local bodyLen = tostring(string.len(bodyStr))

    local res, err = httpc:request_uri(url, {
        method = "POST",
        body = bodyStr,
        headers = {
            ["Content-Length"] = bodyLen,
            ["Accept"] = "*/*",
            ["Accept-Language"] = "zh-cn",
            ["Content-Type"] = "multipart/form-data; boundary=" .. boundaryStr,
            ["Authorization"] = "UPLOAD_AK_TOP MjMyNDkyODg6ZXlKcGJuTmxjblJQYm14NUlqb2lNQ0lzSW01aGJXVnpjR0ZqWlNJNkltcHZjMmgxWVMweklpd2laWGh3YVhKaGRHbHZiaUk2SWkweEluMDpmNGZiMGM0NTU4YjRkYmU0ZjBkYWNmNjFhMTU4ZTkzNDI2YmVjNmEx"
        }
    })

    --common_fun.do_dump_value(res,0)
    --common_fun.do_dump_value(err,0)
    if res ~= nil and res.status == 200 then
        local bodyJson = cjson.decode(res.body)
        return bodyJson["url"];
    else
        return nil
    end
end

function common_fun.postHttpRequestDo(postData, apiStr, timeOut, cacheAccesssKey)
    local http = require("resty.http")
    local httpc = http.new()

    local hostName = "120.55.75.63"
    --hostName = common_fun.getIpFromHostName(hostName)
    local url = "http://" .. hostName .. ":2101/" .. apiStr

    local bodyLen = string.len(postData)

    if timeOut ~= nil then
        httpc:set_timeout(timeOut * 1000)
    end
    --["cache-accesss-key"] = "496d1bac094f11e79d9c0a0027000010"
    --["cache_accesss_key"] = "496d1bac094f11e79d9c0a0027000010",
    if cacheAccesssKey == nil then
        cacheAccesssKey = "496d1bac094f11e79d9c0a0027000010"
    end
    local res, err = httpc:request_uri(url, {
        method = "POST",
        body = postData,
        headers = {
            ["Content-Length"] = bodyLen,
            ["Content-Type"] = "application/json",
            ["cache_accesss_key"] = cacheAccesssKey,
            ["cache-accesss-key"] = cacheAccesssKey
        }
    })
    --common_fun.do_dump_value(url,0)
    --common_fun.do_dump_value(postData,0)
    common_fun.do_dump_value(res, 0)
    common_fun.do_dump_value(err, 0)
    if res ~= nil and res.status == 200 then
        local bodyJson = cjson.decode(res.body)
        return true, bodyJson
    else
        return false
    end
end
function common_fun.getHttpRequestDo(getData, hostName, port, apiStr, urlParam)
    local http = require("resty.http")
    local httpc = http.new()

    hostName = common_fun.getIpFromHostName(hostName)
    local url = "http://" .. hostName .. ":" .. port .. "/" .. apiStr .. urlParam

    local key = hostName .. "_" .. port .. "_" .. apiStr .. urlParam
    local valueJson = common_fun.get_from_cache(key)
    common_fun.do_dump_value("key:" .. key, 0)
    if valueJson ~= nil then
        common_fun.do_dump_value("valueJson:" .. valueJson, 0)
        return true, valueJson
    end

    local bodyLen = tostring(string.len(getData))

    local res, err = httpc:request_uri(url, {
        method = "GET",
        body = getData,
        headers = {
            ["Content-Length"] = bodyLen,
            ["Accept"] = "*/*",
            ["Accept-Language"] = "zh-cn",
            ["Content-Type"] = "text/plain;"
        }
    })
    common_fun.do_dump_value(url, 0)
    common_fun.do_dump_value(res, 0)
    common_fun.do_dump_value(err, 0)

    if res ~= nil and res.status == 200 then
        local bodyJson = cjson.decode(res.body)
        common_fun.set_to_cache(key, bodyJson, 60)
        return true, bodyJson
    else
        return false
    end
end

function common_fun.alimedia_getHttpRequestDo(getData, url, requestHeader)
    local http = require("resty.http")
    local httpc = http.new()

    local bodyLen = tostring(string.len(getData))
    local headersss = {
        ["Content-Length"] = bodyLen,
        ["Accept"] = "*/*",
        ["Accept-Language"] = "zh-cn",
        ["Content-Type"] = "text/plain;"
    }
    local authKeys = {}
    local headersNgx = ngx.req.get_headers()
    authKeys["sysauthentication"] = 1
    authKeys["authentication"] = 1
    authKeys["appkey"] = 1
    authKeys["token"] = 1
    authKeys["userid"] = 1
    authKeys["applicationid"] = 1
    authKeys["time"] = 1
    authKeys["reauthentication"] = 1
    if headersNgx ~= nil then
        for key, value in pairs(authKeys) do
            headersss[key] = headersNgx[key]
        end
    end

    if requestHeader ~= nil then
        for key, value in pairs(requestHeader) do
            headersss[key] = value
        end
    end
    if headersss["time"] == nil and headersss["sysauthentication"] == nil then
        --headersss["time"] =  ngx.now()*1000
        --headersss["sysauthentication"] = ngx.md5(conf_sys.REDIS_SYS_REQUEST_APPSERCERT..":"..tostring(headersss["time"]))
    end
    local res, err = httpc:request_uri(url, {
        method = "GET",
        body = getData,
        headers = headersss
    })
    --common_fun.do_dump_value(url,0)
    --common_fun.do_dump_value(res,0)
    --common_fun.do_dump_value(err,0)
    if res ~= nil and res.status == 200 then
        local bodyJson = cjson.decode(res.body)
        return true, bodyJson, res
    else
        return false
    end
end

function common_fun.postHttpRequestDo(ipAddr, port, apiStr, header, postData)
    local http = require("resty.http")
    local httpc = http.new()

    local url = "http://" .. ipAddr .. ":" .. port .. "/" .. apiStr
    if header == nil then
        header = {
            ["Content-Type"] = "application/json"
        }
    end

    local bodyLen = tostring(string.len(postData))
    header["Content-Length"] = bodyLen

    local res, err = httpc:request_uri(url, {
        method = "POST",
        ssl_verify = false,
        body = postData,
        headers = common_fun.table_clone(header)
    })

    common_fun.do_dump_value(res, 0)
    common_fun.do_dump_value(err, 0)
    if res ~= nil and res.status == 200 then
        local bodyJson = cjson.decode(res.body)
        return true, bodyJson
    else
        return false
    end
end
--
--for Jpush
--
function common_fun.Jpush_to_msg(postData, timeOut)
    local http = require("resty.http")
    local httpc = http.new()

    local hostName = "api.jpush.cn"
    --hostName = common_fun.getIpFromHostName(hostName)
    local url = "https://" .. hostName .. "/v3/push"

    local bodyLen = string.len(postData)

    if timeOut ~= nil then
        httpc:set_timeout(timeOut * 1000)
    end
    local authorizationStr = ngx.encode_base64(conf_sys.jpush_api_keys["AppKey"] .. ":" .. conf_sys.jpush_api_keys["MasterSecret"])

    local res, err = httpc:request_uri(url, {
        method = "POST",
        ssl_verify = false,
        body = postData,
        headers = {
            ["Content-Length"] = bodyLen,
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Basic " .. authorizationStr,
        }
    })
    common_fun.do_dump_value(url, 0)
    common_fun.do_dump_value(authorizationStr, 0)
    common_fun.do_dump_value(postData, 0)
    common_fun.do_dump_value(res, 0)
    common_fun.do_dump_value(err, 0)
    if res ~= nil and res.status == 200 then
        local bodyJson = cjson.decode(res.body)
        return true, bodyJson, res
    else
        return false, nil, res
    end
end

--
--end
--


function common_fun.remove_same_and_sort_table(originTable, isAsc)
    if originTable ~= nil then
        if isAsc == false then
            table.sort(originTable, function(a, b)
                return a > b
            end)
        else
            table.sort(originTable, function(a, b)
                return a < b
            end)
        end
        local resultTable = {}
        local resultTableIndex = 1
        local tempValue = nil
        for k, v in pairs(originTable) do
            if tempValue == nil then
                resultTable[resultTableIndex] = v
                resultTableIndex = resultTableIndex + 1
            elseif tempValue ~= nil and tempValue ~= v then
                resultTable[resultTableIndex] = v
                resultTableIndex = resultTableIndex + 1
            end
            tempValue = v
        end
        return resultTable
    end
    return nil
end

function common_fun.remove_same_and_sort_cascade_table(originTable, isAsc, cascadeOne, cascadeTwo)
    if originTable ~= nil then
        if isAsc == false then
            table.sort(originTable, function(a, b)
                return a[cascadeOne] > b[cascadeOne]
            end)
        else
            table.sort(originTable, function(a, b)
                return a[cascadeOne] < b[cascadeOne]
            end)
        end

        local tempTable = {}
        local resultTableIndex = 1
        local tempValue = nil
        for k, v in pairs(originTable) do
            if tempValue == nil then
                tempTable[resultTableIndex] = v
                resultTableIndex = resultTableIndex + 1
            elseif tempValue ~= nil and tempValue ~= v then
                tempTable[resultTableIndex] = v
                resultTableIndex = resultTableIndex + 1
            end
            tempValue = v
        end
        local resultTable = {}
        for tk, tv in pairs(tempTable) do
            resultTable[tk] = tv
            --common_fun.do_dump_value(tv[cascadeTwo],0)
            local tempMonthTable = tv[cascadeTwo]
            resultTable[tk][cascadeTwo] = common_fun.remove_same_and_sort_table(tempMonthTable, false)
            --common_fun.do_dump_value(resultTable[tk][cascadeTwo],0)
        end

        return resultTable
    end
    return nil
end

function common_fun.table_clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

function common_fun.split_string(inputStr, delimiter)
    inputStr = tostring(inputStr)
    delimiter = tostring(delimiter)
    if (delimiter == '') then
        return false
    end
    local pos, arr = 0, {}
    -- for each divider found  
    for st, sp in function()
        return string.find(inputStr, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(inputStr, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(inputStr, pos))
    return arr
end

function common_fun.get_http_header(name, ngx)
    local name2 = string.gsub(name, "_", "-")
    local headers = ngx.req.get_headers()
    if headers[name] ~= nil then
        return headers[name]
    end
    if headers[name2] ~= nil then
        return headers[name2]
    end
    return nil
end

function common_fun.update_http_token(devType, user_id, tokenStr, expiredTime, isClearBefore)
    local red = redis:new()
    local userToken = red:hget(conf_sys.sys_user_token["worksite_token"], tostring(user_id))
    local updateStr = nil

    if userToken ~= nil then
        local token = cjson.decode(userToken)
        local userDevTokenTab = token[devType]
        if userDevTokenTab ~= nil and #userDevTokenTab > 0 then
            local tokenLength = #userDevTokenTab
            local i = 1
            while i <= #token[devType] do
                if isClearBefore == true or (#token[devType] > 9) then
                    table.remove(token[devType], i)
                else
                    i = i + 1
                end
            end

            local innerTab = {}

            innerTab["token"] = tokenStr
            innerTab["expiredTime"] = expiredTime
            table.insert(token[devType], innerTab)
            updateStr = cjson.encode(token)
        else
            local innerTab = {}
            token[devType] = {}

            innerTab["token"] = tokenStr
            innerTab["expiredTime"] = expiredTime
            table.insert(token[devType], innerTab)
            updateStr = cjson.encode(token)
        end
    else
        local tabOut = {}
        local tabInner = {}
        local innerTab = {}

        innerTab["token"] = tokenStr
        innerTab["expiredTime"] = expiredTime
        table.insert(tabInner, innerTab)
        tabOut[devType] = tabInner
        updateStr = cjson.encode(tabOut)
    end
    red:hset(conf_sys.sys_user_token["worksite_token"], tostring(user_id), updateStr)
end

function common_fun.check_http_token(devType, user_id, time, tokenStr)
    local red = redis:new()
    local userToken = red:hget(conf_sys.sys_user_token["worksite_token"], tostring(user_id))
    local updateStr = nil
    local nowTime = ngx.now()
    if userToken ~= nil then
        local token = cjson.decode(userToken)
        --common_fun.do_dump_value(token,0)
        local userDevTokenTab = token[devType]
        --common_fun.do_dump_value(devType,0)
        if userDevTokenTab ~= nil and #userDevTokenTab > 0 then
            local md5Result

            for i = #userDevTokenTab, 1, -1 do
                md5Result = ngx.md5(tostring(user_id) .. tostring(time) .. userDevTokenTab[i]["token"])
                --common_fun.do_dump_value(md5Result,0)
                if md5Result == tokenStr then
                    if userDevTokenTab[i]["expiredTime"] < nowTime then
                        return "ERROR_HTTP_TOKEN_EXPIRED", "token过期，其重新登录"
                    else
                        local tokenExpiredTime = math.ceil(nowTime)
                        if devType == "user_web" then
                            tokenExpiredTime = tokenExpiredTime + 7200
                        else
                            tokenExpiredTime = tokenExpiredTime + 2592000
                        end
                        userDevTokenTab[i]["expiredTime"] = tokenExpiredTime
                        red:hset(conf_sys.sys_user_token["worksite_token"], tostring(user_id), cjson.encode(token))
                        return "ERROR_NONE"
                    end
                end
            end
            if devType == "user_mobile" or devType == "user_android" or devType == "user_ios" then
                return "ERROR_HTTP_TOKEN", "该账号在其他设备登录，请您重新登录"
            end
            return "ERROR_HTTP_TOKEN", "token错误"
        else
            return "ERROR_HTTP_TOKEN_NONE", "您尚未登录"
        end
    else
        return "ERROR_HTTP_TOKEN_NONE", "您尚未登录"
    end
end

function common_fun.get_client_ip(ngx)
    local headers = ngx.req.get_headers()
    local ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
    return ip
end

function common_fun.__TRACKBACK__(errmsg)
    local track_text = debug.traceback(tostring(errmsg), 6)
    common_fun.do_dump_value("FATAL Exception!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", 0)
    common_fun.do_dump_value(track_text, 0)
    return false
end

function common_fun.trycall(func, ...)
    local args = { ... }
    return xpcall(function()
        return func(unpack(args))
    end, common_fun.__TRACKBACK__)
end
--
--WGS-84 to BD-09
--
function common_fun.transformLat(x, y)
    local PI = 3.14159265358979324
    local x_pi = 52.359877559829887333333333333333
    local ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * math.sqrt(math.abs(x))
    ret = ret + (20.0 * math.sin(6.0 * x * PI) + 20.0 * math.sin(2.0 * x * PI)) * 2.0 / 3.0
    ret = ret + (20.0 * math.sin(y * PI) + 40.0 * math.sin(y / 3.0 * PI)) * 2.0 / 3.0
    ret = ret + (160.0 * math.sin(y / 12.0 * PI) + 320 * math.sin(y * PI / 30.0)) * 2.0 / 3.0
    return ret
end
function common_fun.transformLon(x, y)
    local PI = 3.14159265358979324
    local x_pi = 52.359877559829887333333333333333
    local ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * math.sqrt(math.abs(x))
    ret = ret + (20.0 * math.sin(6.0 * x * PI) + 20.0 * math.sin(2.0 * x * PI)) * 2.0 / 3.0
    ret = ret + (20.0 * math.sin(x * PI) + 40.0 * math.sin(x / 3.0 * PI)) * 2.0 / 3.0
    ret = ret + (150.0 * math.sin(x / 12.0 * PI) + 300.0 * math.sin(x / 30.0 * PI)) * 2.0 / 3.0
    return ret
end
function common_fun.delta(lat, lon)
    local PI = 3.14159265358979324
    local x_pi = 52.359877559829887333333333333333
    local a = 6378245.0
    local ee = 0.00669342162296594323
    local dLat = common_fun.transformLat(lon - 105.0, lat - 35.0)
    local dLon = common_fun.transformLon(lon - 105.0, lat - 35.0)
    local radLat = lat / 180.0 * PI
    local magic = math.sin(radLat)
    magic = 1 - ee * magic * magic
    local sqrtMagic = math.sqrt(magic)
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * PI)
    dLon = (dLon * 180.0) / (a / sqrtMagic * math.cos(radLat) * PI)
    return dLat, dLon
end
function common_fun.outOfChina (lat, lon)
    local PI = 3.14159265358979324
    local x_pi = 52.359877559829887333333333333333
    if (lon < 72.004 or lon > 137.8347) then
        return true
    end
    if (lat < 0.8293 or lat > 55.8271) then
        return true
    end
    return false
end

--WGS-84 to GCJ-02
function common_fun.gcj_encrypt(wgsLat, wgsLon)
    if (common_fun.outOfChina(wgsLat, wgsLon)) then
        return wgsLat, wgsLon
    end
    local dlat, dlon = common_fun.delta(wgsLat, wgsLon)
    return wgsLat + dlat, wgsLon + dlon
end

--GCJ-02 to BD-09
function common_fun.bd_encrypt(gcjLat, gcjLon)
    local PI = 3.14159265358979324
    local x_pi = 52.359877559829887333333333333333
    local x = gcjLon
    local y = gcjLat
    local z = math.sqrt(x * x + y * y) + 0.00002 * math.sin(y * x_pi)
    local theta = math.atan2(y, x) + 0.000003 * math.cos(x * x_pi)
    bdLon = z * math.cos(theta) + 0.0065
    bdLat = z * math.sin(theta) + 0.006
    return bdLat, bdLon
end
function common_fun.wgs_to_bd_encrypt(wgsLat, wgsLon)
    local tempLat = wgsLat
    local tempLon = wgsLon
    if type(wgsLat) == "string" then
        tempLat = tonumber(wgsLat)
    end
    if type(wgsLon) == "string" then
        tempLon = tonumber(wgsLon)
    end

    tempLat, tempLon = common_fun.gcj_encrypt(tempLat, tempLon)
    tempLat, tempLon = common_fun.bd_encrypt(tempLat, tempLon)
    return tempLat, tempLon
end
--
--end
--
function common_fun.file_exists(path)
    local file = io.open(path, "rb")
    if file then
        file:close()
    end
    return file ~= nil
end

function common_fun.buprovince_get(user_bu_code)
    local userBuTab = common_fun.split_string(user_bu_code, ",")
    if #userBuTab > 1 then
        for buk, buv in pairs(userBuTab) do
            if string.len(buv) == 2 then
                return buv
            end
        end
    end
    return user_bu_code
end

function common_fun.do_dump_value(t, i)
    local valuesStrTab = {}

    if (type(t) == "table") then
        if i == 0 then
            table.insert(valuesStrTab, "{")
        end
        for k, v in pairs(t) do
            if (type(v) == "table") then
                table.insert(valuesStrTab, "\"")
                table.insert(valuesStrTab, k)
                table.insert(valuesStrTab, "\":{")
                table.insert(valuesStrTab, common_fun.do_dump_value(v, i + 1))
                table.insert(valuesStrTab, "}")
            elseif (type(v) == "string") then
                table.insert(valuesStrTab, "\"")
                table.insert(valuesStrTab, k)
                table.insert(valuesStrTab, "\":string:\"")
                table.insert(valuesStrTab, v)
                table.insert(valuesStrTab, "\" ")
            elseif (type(v) == "number") then
                table.insert(valuesStrTab, "\"")
                table.insert(valuesStrTab, k)
                table.insert(valuesStrTab, "\":number:\"")
                table.insert(valuesStrTab, tostring(v))
                table.insert(valuesStrTab, "\" ")
            elseif (type(v) == "function") then
                table.insert(valuesStrTab, "\"")
                table.insert(valuesStrTab, k)
                table.insert(valuesStrTab, "\":function:\"")
                table.insert(valuesStrTab, tostring(v))
                table.insert(valuesStrTab, "\" ")
            elseif (type(v) == "boolean") then
                table.insert(valuesStrTab, "\"")
                table.insert(valuesStrTab, k)
                table.insert(valuesStrTab, "\":boolean:\"")
                table.insert(valuesStrTab, tostring(v))
                table.insert(valuesStrTab, "\" ")
            elseif (type(v) == "nil") then
                table.insert(valuesStrTab, "\"")
                table.insert(valuesStrTab, k)
                table.insert(valuesStrTab, "\":nil: ")
            end
        end
        if i == 0 then
            table.insert(valuesStrTab, "}")
        end
    elseif (type(t) == "string") then
        table.insert(valuesStrTab, "string:")
        table.insert(valuesStrTab, t)
    elseif (type(t) == "number") then
        table.insert(valuesStrTab, "number:")
        table.insert(valuesStrTab, tostring(t))
    elseif (type(t) == "function") then
        table.insert(valuesStrTab, "function:")
        table.insert(valuesStrTab, tostring(t))
    elseif (type(t) == "boolean") then
        table.insert(valuesStrTab, "boolean:")
        table.insert(valuesStrTab, tostring(t))
    elseif (type(t) == "nil") then
        table.insert(valuesStrTab, "nil:")
    end

    if i == 0 then
        ngx.log(ngx.ERR, "dumpValue:", table.concat(valuesStrTab, ""))
    else
        return table.concat(valuesStrTab, "")
    end
end

return common_fun
