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
local proj_code = decode_params["proj_code"]
local proj_name = decode_params["proj_name"]
local proj_link_name = decode_params["proj_link_name"]
local proj_module_name = decode_params["proj_module_name"]

local proj_link_status = decode_params["proj_link_status"]
local fuzzy_searche_key = decode_params["fuzzy_searche_key"]
local proj_bu_code
local proj_company_code
local dev_request_type = comm_func.get_http_header("dev-request-type", ngx)
local limit = decode_params["limit"]
local offset = decode_params["offset"]
local time_begin = decode_params["start_time"]
local time_end = decode_params["end_time"]

if type(time_begin) ~= "number" or type(time_end) ~= "number" then
    local tab = {}
    tab["result"] = "time_begin、time_end必须为时间戳类型"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if time_end - time_begin > 2592000 then
    local tab = {}
    tab["result"] = "查询时间跨度在30天内"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

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

if proj_link_status ~= nil and type(proj_link_status) ~= "number" then
    local tab = {}
    tab["result"] = "proj_link_status必须为整形"
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

if proj_link_name ~= nil and type(proj_link_name) ~= "string" then
    local tab = {}
    tab["result"] = "proj_link_name必须为字符串"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

if proj_module_name ~= nil and type(proj_module_name) ~= "string" then
    local tab = {}
    tab["result"] = "proj_module_name必须为字符串"
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
        tab["result"] = "fuzzy_searche_key的长度不小于3"
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
    proj_company_code = userApps[1]["user_company_code"]
    isAdmin = db_query.userAdmin_is(userApps[1], user_id)
    if isAdmin == true then
        proj_bu_code = nil
        proj_company_code = nil
    end
    if userApps[1]["user_role"] == 1 then
        proj_bu_code = string.sub(userApps[1]["user_bu_code"], 1, 2)
    else
        proj_bu_code = comm_func.buprovince_get(proj_bu_code)
    end
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_LINK_LIST_GET_FAILED")
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

        if string.find(str, "..") ~= nil then
            str = string.gsub(str, "%..", ".")
            local toNumber = tonumber(str)
            if toNumber ~= nil then
                return str
            end
        end

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

    end
    return str;

end

--赤道半径(单位m)
local EARTH_RADIUS = 6378137
local Math_PI = 3.141592653589793

local function rad(d)
    return d * Math_PI / 180.0
end

local function LantitudeLongitudeDist(lon1, lat1, lon2, lat2)
    local radLat1 = rad(lat1);
    local radLat2 = rad(lat2);

    local radLon1 = rad(lon1);
    local radLon2 = rad(lon2);

    if (radLat1 < 0) then
        radLat1 = Math_PI / 2 + math.abs(radLat1);-- south  
    end
    if (radLat1 > 0) then
        radLat1 = Math_PI / 2 - math.abs(radLat1);-- north
    end
    if (radLon1 < 0) then
        radLon1 = Math_PI * 2 - math.abs(radLon1);-- west
    end
    if (radLat2 < 0) then
        radLat2 = Math_PI / 2 + math.abs(radLat2);-- south
    end
    if (radLat2 > 0) then
        radLat2 = Math_PI / 2 - math.abs(radLat2);-- north
    end
    if (radLon2 < 0) then
        radLon2 = Math_PI * 2 - math.abs(radLon2);-- west
    end
    local x1 = EARTH_RADIUS * math.cos(radLon1) * math.sin(radLat1);
    local y1 = EARTH_RADIUS * math.sin(radLon1) * math.sin(radLat1);
    local z1 = EARTH_RADIUS * math.cos(radLat1);

    local x2 = EARTH_RADIUS * math.cos(radLon2) * math.sin(radLat2);
    local y2 = EARTH_RADIUS * math.sin(radLon2) * math.sin(radLat2);
    local z2 = EARTH_RADIUS * math.cos(radLat2);

    local d = math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2));
    --余弦定理求夹角  
    local theta = math.acos((EARTH_RADIUS * EARTH_RADIUS + EARTH_RADIUS * EARTH_RADIUS - d * d) / (2 * EARTH_RADIUS * EARTH_RADIUS));
    local dist = theta * EARTH_RADIUS;
    return dist;
end

local statusText = {}
statusText["0"] = "初始化，空，未提交"
statusText["1"] = "已提交未审核"
statusText["2"] = "审核不通过"
statusText["3"] = "审核通过"
statusText["4"] = "审核不通过并且留档"
statusText["5"] = "条件通过"
statusText["6"] = "该环节被禁用"

local sqlStr = string.format(" select oog.o_name,aa.* from( select * from ( select proj_bu_code,proj_code,proj_module_name,proj_link_name,proj_link_submit_time,proj_link_review_time,age(to_timestamp( proj_link_review_time),to_timestamp(proj_link_submit_time))   from tb_proj_link where (proj_code !='GDJZAAAAAAAAAAYD' and proj_code !='GDJZAAAAAAAAABYD' ) and ( ( proj_link_submit_time > %d and proj_link_submit_time<= %d and proj_link_review_time > 0 and proj_link_review_time - proj_link_submit_time > 7200  ) or (  proj_link_submit_time > %d and  proj_link_submit_time<= %d  and proj_link_review_time <= 0 and extract(epoch from now()) - proj_link_submit_time > 7200  ) )) b order by b.age desc) aa , tb_organization oog where oog.o_code=aa.proj_bu_code order  by aa.age desc", time_begin, time_end, time_begin, time_end)

local status, apps = db_project.excute(sqlStr)
local resultApps = {}
local resultAppsLength = 1

local tab = {}
tab["result"] = apps
tab["total"] = #apps
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))

