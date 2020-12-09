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

local decode_params = decode_data["params"]
local proj_code = decode_params["proj_code"]

if type(proj_code) ~= "string" then
    local tab = {}
    tab["result"] = "参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local Projstatus, Projapps = db_query.projectList_get(proj_code, nil, nil, nil, nil, nil, nil, proj_bu_code, nil, false, 1, 0)

local status, apps = db_query.projectLink_get(proj_code)
local recodStatus, recodApps = db_query.projectLinkRecodNum_get(proj_code)

if status == true and recodStatus == true then
    local linkStructure
    if Projapps ~= nil and Projapps[1] ~= nil and Projapps[1]["proj_links"] ~= nil then
        linkStructure = cjson.decode(Projapps[1]["proj_links"])
        local linkStructureLength = #linkStructure
        if linkStructure[linkStructureLength]["proj_module_code"] == "5" or linkStructure[linkStructureLength]["proj_module_code"] == 5 then
            linkStructure[linkStructureLength] = nil
        end
    end
    if linkStructure == nil then
        linkStructure = db_query.projectAllType_get(true)
    end

    if apps ~= nil and apps[1] ~= nil then
        for k, v in pairs(apps) do
            apps[k]["proj_link_pic"] = cjson.decode(apps[k]["proj_link_pic"])
            apps[k]["proj_link_recod_count"] = 0

            for recodAppsk, recodAppsv in pairs(recodApps) do
                if apps[k]["proj_link_id"] == recodApps[recodAppsk]["proj_link_id"] then
                    apps[k]["proj_link_recod_count"] = recodApps[recodAppsk]["count"]
                    break
                end
            end
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
    local tab = {}
    local appResult = {}
    appResult["proj_code"] = proj_code
    appResult["detail"] = apps
    tab["result"] = appResult
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_LINK_GET_FAILED")
    ngx.say(cjson.encode(tab))
end

