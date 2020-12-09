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
    if fuzzy_searche_key ~= nil and string.len(fuzzy_searche_key) < 3 then
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

function filter_spec_chars(s)
    local ss = {}
    local k = 1
    while true do
        if k > #s then
            break
        end
        local c = string.byte(s, k)
        if not c then
            break
        end
        if c < 192 then
            if (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c <= 122) then
                table.insert(ss, string.char(c))
            end
            k = k + 1
        elseif c < 224 then
            k = k + 2
        elseif c < 240 then
            if c >= 228 and c <= 233 then
                local c1 = string.byte(s, k + 1)
                local c2 = string.byte(s, k + 2)
                if c1 and c2 then
                    local a1, a2, a3, a4 = 128, 191, 128, 191
                    if c == 228 then
                        a1 = 184
                    elseif c == 233 then
                        a2, a4 = 190, c1 ~= 190 and 191 or 165
                    end
                    if c1 >= a1 and c1 <= a2 and c2 >= a3 and c2 <= a4 then
                        table.insert(ss, string.char(c, c1, c2))
                    end
                end
            end
            k = k + 3
        elseif c < 248 then
            k = k + 4
        elseif c < 252 then
            k = k + 5
        elseif c < 254 then
            k = k + 6
        end
    end
    return table.concat(ss)
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
            str = filter_spec_chars(str)
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


--lat,lon convert
local x_pi = 3.14159265358979324 * 3000.0 / 180.0
local pi = 3.1415926535897932384626  --# π
local a = 6378245.0  --# 长半轴
local ee = 0.00669342162296594323  --# 扁率

local function out_of_china(lng, lat)
    --"""
    --判断是否在国内，不在国内不做偏移
    --:param lng:
    --:param lat:
    --:return:
    --"""
    return not (lng > 73.66 and lng < 135.05 and lat > 3.86 and lat < 53.55)
end

local function _transformlat(lng, lat)
    local lngAbs = lng
    if lngAbs < 0 then
        lngAbs = 0 - lngAbs
    end
    local ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * math.sqrt(lngAbs)
    ret = ret + (20.0 * math.sin(6.0 * lng * pi) + 20.0 * math.sin(2.0 * lng * pi)) * 2.0 / 3.0
    ret = ret + (20.0 * math.sin(lat * pi) + 40.0 * math.sin(lat / 3.0 * pi)) * 2.0 / 3.0
    ret = ret + (160.0 * math.sin(lat / 12.0 * pi) + 320 * math.sin(lat * pi / 30.0)) * 2.0 / 3.0
    return ret
end

local function _transformlng(lng, lat)
    local lngAbs = lng
    if lngAbs < 0 then
        lngAbs = 0 - lngAbs
    end
    ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * math.sqrt(lngAbs)
    ret = ret + (20.0 * math.sin(6.0 * lng * pi) + 20.0 * math.sin(2.0 * lng * pi)) * 2.0 / 3.0
    ret = ret + (20.0 * math.sin(lng * pi) + 40.0 * math.sin(lng / 3.0 * pi)) * 2.0 / 3.0
    ret = ret + (150.0 * math.sin(lng / 12.0 * pi) + 300.0 * math.sin(lng / 30.0 * pi)) * 2.0 / 3.0
    return ret
end

local function gcj02_to_bd09(lng, lat)
    --"""
    --火星坐标系(GCJ-02)转百度坐标系(BD-09)
    --谷歌、高德——>百度
    --:param lng:火星坐标经度
    --:param lat:火星坐标纬度
    --:return:
    --"""
    local z = math.sqrt(lng * lng + lat * lat) + 0.00002 * math.sin(lat * x_pi)
    local theta = math.atan2(lat, lng) + 0.000003 * math.cos(lng * x_pi)
    local bd_lng = z * math.cos(theta) + 0.0065
    local bd_lat = z * math.sin(theta) + 0.006
    return bd_lng, bd_lat
end

local function bd09_to_gcj02(bd_lon, bd_lat)
    --"""
    --百度坐标系(BD-09)转火星坐标系(GCJ-02)
    --百度——>谷歌、高德
    --:param bd_lat:百度坐标纬度
    --:param bd_lon:百度坐标经度
    --:return:转换后的坐标列表形式
    --"""
    local x = bd_lon - 0.0065
    local y = bd_lat - 0.006
    local z = math.sqrt(x * x + y * y) - 0.00002 * math.sin(y * x_pi)
    local theta = math.atan2(y, x) - 0.000003 * math.cos(x * x_pi)
    local gg_lng = z * math.cos(theta)
    local gg_lat = z * math.sin(theta)
    return gg_lng, gg_lat
end

local function wgs84_to_gcj02(lng, lat)
    --"""
    --WGS84转GCJ02(火星坐标系)
    --:param lng:WGS84坐标系的经度
    --:param lat:WGS84坐标系的纬度
    --:return:
    --"""
    if out_of_china(lng, lat) == true then
        --:  # 判断是否在国内
        return lng, lat
    end
    local dlat = _transformlat(lng - 105.0, lat - 35.0)
    local dlng = _transformlng(lng - 105.0, lat - 35.0)
    local radlat = lat / 180.0 * pi
    local magic = math.sin(radlat)
    magic = 1 - ee * magic * magic
    local sqrtmagic = math.sqrt(magic)
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * pi)
    dlng = (dlng * 180.0) / (a / sqrtmagic * math.cos(radlat) * pi)
    local mglat = lat + dlat
    local mglng = lng + dlng
    return mglng, mglat
end

local function gcj02_to_wgs84(lng, lat)
    --"""
    --GCJ02(火星坐标系)转GPS84
    --:param lng:火星坐标系的经度
    --:param lat:火星坐标系纬度
    --:return:
    --"""
    if out_of_china(lng, lat) == true then
        return lng, lat
    end
    local dlat = _transformlat(lng - 105.0, lat - 35.0)
    local dlng = _transformlng(lng - 105.0, lat - 35.0)
    local radlat = lat / 180.0 * pi
    local magic = math.sin(radlat)
    magic = 1 - ee * magic * magic
    local sqrtmagic = math.sqrt(magic)
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * pi)
    dlng = (dlng * 180.0) / (a / sqrtmagic * math.cos(radlat) * pi)
    local mglat = lat + dlat
    local mglng = lng + dlng
    return lng * 2 - mglng, lat * 2 - mglat
end

local function bd09_to_wgs84(bd_lon, bd_lat)
    local lon, lat = bd09_to_gcj02(bd_lon, bd_lat)
    return gcj02_to_wgs84(lon, lat)
end

local function wgs84_to_bd09(lon, lat)
    local lon, lat = wgs84_to_gcj02(lon, lat)
    return gcj02_to_bd09(lon, lat)
end



--[==[
if __name__ == '__main__':
    lng = 128.543
    lat = 37.065
    result1 = gcj02_to_bd09(lng, lat)
    result2 = bd09_to_gcj02(lng, lat)
    result3 = wgs84_to_gcj02(lng, lat)
    result4 = gcj02_to_wgs84(lng, lat)
    result5 = bd09_to_wgs84(lng, lat)
    result6 = wgs84_to_bd09(lng, lat)

    g = Geocoding('API_KEY')  # 这里填写你的高德api的key
    result7 = g.geocode('北京市朝阳区朝阳公园')
    print result1, result2, result3, result4, result5, result6, result7
--end
]==]--



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

            comm_func.do_dump_value(latStr, 0)
            comm_func.do_dump_value(lonStr, 0)
            lonStr = parseStrToLatLon(lonStr)
            latStr = parseStrToLatLon(latStr)
            comm_func.do_dump_value(latStr, 0)
            comm_func.do_dump_value(lonStr, 0)
            if tonumber(latStr) ~= nil and tonumber(lonStr) ~= nil then
                --latStr,lonStr =  comm_func.wgs_to_bd_encrypt(latStr,lonStr)
                comm_func.do_dump_value(tonumber(lonStr), 0)
                comm_func.do_dump_value(tonumber(latStr), 0)
                lonStr, latStr = wgs84_to_bd09(tonumber(lonStr), tonumber(latStr))
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

