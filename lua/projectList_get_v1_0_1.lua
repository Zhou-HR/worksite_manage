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
ngx.log(ngx.ERR, "projectList_get_v1_0_1: ", user_id)

local decode_params = decode_data["params"]
local proj_code = decode_params["proj_code"]
local proj_name = decode_params["proj_name"]
local proj_addr = decode_params["proj_addr"]
local proj_establish_time = decode_params["proj_establish_time"]
local proj_station_type = decode_params["proj_station_type"]
local proj_tower_type = decode_params["proj_tower_type"]
local proj_base_type = decode_params["proj_base_type"]
local fuzzy_searche_key = decode_params["fuzzy_searche_key"]
local proj_bu_code
local dev_request_type = comm_func.get_http_header("dev-request-type", ngx)
local limit = decode_params["limit"]
local offset = decode_params["offset"]

if type(limit) ~= "number" or limit <= 0 then
    limit = 10
end

if limit > 10 then
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

local function add_link_info(projTab)
    for projTabk, projTabv in pairs(projTab) do
        local proj_code = projTabv["proj_code"]

        local status, apps = db_query.projectLink_get(proj_code)
        --local recodStatus,recodApps = db_query.projectLinkRecodNum_get(proj_code)

        --if status == true and recodStatus == true then
        if status == true then
            local linkStructure
            if projTabv["proj_links"] ~= nil then
                linkStructure = cjson.decode(projTabv["proj_links"])
            end
            if linkStructure == nil then
                linkStructure = db_query.projectAllType_get(true)
            end
            if apps ~= nil and apps[1] ~= nil then
                for k, v in pairs(apps) do
                    apps[k]["proj_link_pic"] = cjson.decode(apps[k]["proj_link_pic"])
                    apps[k]["proj_link_recod_count"] = 0

                    --[==[
                    for recodAppsk, recodAppsv in pairs(recodApps) do
                      if apps[k]["proj_link_id"] == recodApps[recodAppsk]["proj_link_id"] then
                        apps[k]["proj_link_recod_count"] = recodApps[recodAppsk]["count"]
                        break
                      end
                    end
                    ]==]--
                    apps[k]["proj_link_recod_count"] = 0
                end
                local tempApps = db_query.projectLinkData_put(linkStructure, apps)
                if tempApps ~= nil and tempApps[1] ~= nil and tempApps[1]["name"] == apps[1]["proj_type_name"] then
                    apps = tempApps[1]["sub"]
                    apps["name"] = nil
                    apps["value"] = nil
                elseif tempApps ~= nil and tempApps[2] ~= nil and tempApps[2]["name"] == apps[1]["proj_type_name"] then
                    apps = tempApps[2]["sub"]
                    apps["name"] = nil
                    apps["value"] = nil
                elseif tempApps ~= nil and tempApps[3] ~= nil and tempApps[3]["name"] == apps[1]["proj_type_name"] then
                    apps = tempApps[3]["sub"]
                    apps["name"] = nil
                    apps["value"] = nil
                elseif tempApps ~= nil and tempApps[4] ~= nil and tempApps[4]["name"] == apps[1]["proj_type_name"] then
                    apps = tempApps[4]["sub"]
                    apps["name"] = nil
                    apps["value"] = nil
                else
                    apps = tempApps
                end
            end
        end
        projTabv["proj_links"] = apps
    end
end
local orstatus, orapps, orcount, ortotal = db_query.organizationListProvince_get(10000, 0)
local organizationTab = {}
for k, v in pairs(orapps) do
    organizationTab[v["o_code"]] = v["o_name"]
end

local status, apps, count, total = db_query.projectList_get(proj_code, proj_name, proj_addr, proj_establish_time, proj_station_type, proj_tower_type, proj_base_type, proj_bu_code, fuzzy_searche_key, isAdmin, limit, offset)

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
            apps[k]["proj_company"] = organizationTab[v["proj_company_code"]]
        end
        add_link_info(apps)
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

