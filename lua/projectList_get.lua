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

ngx.log(ngx.ERR, "projectList_get user_id: ", user_id)

local decode_params = decode_data["params"]
local proj_code = decode_params["proj_code"]
local proj_name = decode_params["proj_name"]
local proj_addr = decode_params["proj_addr"]
local proj_establish_time = decode_params["proj_establish_time"]
local proj_station_type = decode_params["proj_station_type"]
local proj_tower_type = decode_params["proj_tower_type"]
local proj_base_type = decode_params["proj_base_type"]
local fuzzy_searche_key = decode_params["fuzzy_searche_key"]
local proj_company_code = decode_params["proj_company_code"]
local proj_bu_code_before = decode_params["proj_bu_code"]
local proj_module_code_ls = decode_params["proj_module_code_ls"]
local proj_submit_time = decode_params["proj_submit_time"]

local proj_bu_code
local dev_request_type = comm_func.get_http_header("dev-request-type", ngx)
local limit = decode_params["limit"]
local offset = decode_params["offset"]

if type(limit) ~= "number" or limit <= 0 then
    limit = 10
end

if type(offset) ~= "number" or offset <= 0 then
    offset = 0
end

if type(dev_request_type) ~= "string" then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_code ~= nil and type(proj_code) ~= "string" then
    local tab = {}
    tab["result"] = "proj_code必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_name ~= nil and type(proj_name) ~= "string" then
    local tab = {}
    tab["result"] = "proj_name必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_addr ~= nil and type(proj_addr) ~= "string" then
    local tab = {}
    tab["result"] = "proj_addr必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_establish_time ~= nil and type(proj_establish_time) ~= "string" then
    local tab = {}
    tab["result"] = "proj_establish_time必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_station_type ~= nil and type(proj_station_type) ~= "string" then
    local tab = {}
    tab["result"] = "proj_station_type必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_tower_type ~= nil and type(proj_tower_type) ~= "string" then
    local tab = {}
    tab["result"] = "proj_tower_type必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_base_type ~= nil and type(proj_base_type) ~= "string" then
    local tab = {}
    tab["result"] = "proj_base_type必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_company_code ~= nil and type(proj_company_code) ~= "string" then
    local tab = {}
    tab["result"] = "proj_company_code必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_bu_code_before ~= nil and type(proj_bu_code_before) ~= "string" then
    local tab = {}
    tab["result"] = "proj_bu_code_before必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local moduleTab = {}
moduleTab["0"] = "地质勘探"
moduleTab["1"] = "土建施工"
moduleTab["1-0"] = "土建施工-落地塔基"
moduleTab["1-1"] = "土建施工-落地机房"
moduleTab["2"] = "塔桅安装"
moduleTab["3"] = "接电施工"
moduleTab["4"] = "配套安装"
moduleTab["5"] = "竣工交维"
moduleTab["10"] = "交付验收"
moduleTab["6"] = "拆站"
moduleTab["7"] = "安装电表"
moduleTab["8"] = "并购"
moduleTab["9"] = "改造"
--fixed by zhangjieqiong at 20200520
if proj_module_code_ls ~= nil and type(proj_module_code_ls) ~= "string" then
    local tab = {}
    tab["result"] = "proj_module_name_ls必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end
local proj_module_name_ls = moduleTab[proj_module_code_ls]

if proj_submit_time ~= nil and type(proj_submit_time) ~= "number" then
    local tab = {}
    tab["result"] = "proj_submit_time必须为长整型"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if fuzzy_searche_key ~= nil and type(fuzzy_searche_key) ~= "string" then
    local tab = {}
    tab["result"] = "fuzzy_searche_key必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
else
    fuzzy_searche_key = comm_func.trim_string(fuzzy_searche_key)
    if fuzzy_searche_key == "" then
        fuzzy_searche_key = nil
    end
    if fuzzy_searche_key ~= nil and string.len(fuzzy_searche_key) < conf_sys.fuzzy_searche_key_length_min then
        local tab = {}
        tab["result"] = "fuzzy_searche_key的长度不小于" .. tostring(conf_sys.fuzzy_searche_key_length_min)
        tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
        ngx.say(cjson.encode(tab))
        return
    end
end

ngx.log(ngx.ERR, "projectList_get user_id0: ", user_id)

local userIdValid = comm_func.do_check_user_id_valid(user_id)
if userIdValid == 0 then
    local tab = {}
    tab["result"] = "user_id不合法"
    tab["error"] = error_table.get_error("ERROR_USER_ID_INVALID")
    ngx.say(cjson.encode(tab))
    return
end
local isAdmin = false
local userStatus, userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    proj_bu_code = userApps[1]["user_bu_code"]
    isAdmin = db_query.userAdmin_is(userApps[1], user_id)
    if isAdmin == true then
        proj_bu_code = nil
    end
    if userApps[1]["user_role"] == 1 then
        proj_bu_code = string.sub(userApps[1]["user_bu_code"], 1, 2)
    else
        proj_bu_code = comm_func.buprovince_get(proj_bu_code)
    end
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_PROJ_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

local function parseStrToLatLon(str)
    local beforeStr = str
    if str ~= nil then
        str = comm_func.trim_string(str)

        local toNumber = tonumber(str)
        if toNumber ~= nil then
            return str
        end
        --[==[
            if string.find(str, "..") ~= nil then
              str =  string.gsub(str,"%..",".")
              local toNumber = tonumber(str)
              if toNumber ~= nil then
                return str
              end
            end
        ]==]--
        if string.find(str, "°") ~= nil then
            str = string.gsub(str, "°", "")
            local toNumber = tonumber(str)
            if toNumber ~= nil then
                return str
            end
        end

        if string.find(str, "？") ~= nil then
            str = string.gsub(str, "？", "")
            local toNumber = tonumber(str)
            if toNumber ~= nil then
                return str
            end
        end
        if string.find(str, "..") ~= nil then
            str = string.gsub(str, "%..", ".")
            local toNumber = tonumber(str)
            if toNumber ~= nil then
                return str
            end
        end

    end
    return str;

end

local orstatus, orapps, orcount, ortotal = db_query.organizationListProvince_get(10000, 0)
local organizationTab = {}
for k, v in pairs(orapps) do
    organizationTab[v["o_code"]] = v["o_name"]
end

local status, apps, count, total = db_project.projectList_search(proj_code, proj_name, proj_addr, proj_establish_time, proj_station_type, proj_tower_type, proj_base_type, proj_bu_code, fuzzy_searche_key, isAdmin, proj_company_code, proj_bu_code_before, proj_module_name_ls, proj_submit_time, limit, offset)

if status == true then
    if apps ~= nil and apps[1] ~= nil then
        for k, v in pairs(apps) do
            local lonStr = v["proj_lon"]
            local latStr = v["proj_lat"]

            --comm_func.do_dump_value(latStr,0);
            lonStr = parseStrToLatLon(lonStr)
            latStr = parseStrToLatLon(latStr)
            --comm_func.do_dump_value(latStr,0);
            if tonumber(latStr) ~= nil and tonumber(lonStr) ~= nil then
                latStr, lonStr = comm_func.wgs_to_bd_encrypt(latStr, lonStr)
                latStr = tostring(latStr)
                lonStr = tostring(lonStr)
                if string.len(latStr) > 10 then
                    latStr = string.sub(latStr, 1, 10)
                end
                if string.len(lonStr) > 10 then
                    lonStr = string.sub(lonStr, 1, 10)
                end
            end
            apps[k]["proj_lon"] = lonStr
            apps[k]["proj_lat"] = latStr
            apps[k]["proj_links"] = "[]"
            apps[k]["proj_company"] = organizationTab[v["proj_company_code"]]
        end
    end
    local tab = {}
    local otherTab = {}
    --comm_func.do_dump_value(total,0)
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
    tab["error"] = error_table.get_error("ERROR_PROJ_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
end

