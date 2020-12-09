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

local function modifyTableProjLinks(proj_code)
    local statusT, appsT = db_query.projectLink_get(proj_code)

    if statusT == true then
        local linkStructure = db_query.projectAllType_get(true)
        if appsT ~= nil and appsT[1] ~= nil then
            local tempApps = linkStructure
            if tempApps ~= nil and tempApps[1] ~= nil and tempApps[1]["name"] == appsT[1]["proj_type_name"] then
                appsT = tempApps[1]["sub"]
                appsT["name"] = nil
                appsT["value"] = nil
            elseif tempApps ~= nil and tempApps[2] ~= nil and tempApps[2]["name"] == appsT[1]["proj_type_name"] then
                appsT = tempApps[2]["sub"]
                appsT["name"] = nil
                appsT["value"] = nil
            elseif tempApps ~= nil and tempApps[3] ~= nil and tempApps[3]["name"] == appsT[1]["proj_type_name"] then
                appsT = tempApps[3]["sub"]
                appsT["name"] = nil
                appsT["value"] = nil
            elseif tempApps ~= nil and tempApps[4] ~= nil and tempApps[4]["name"] == appsT[1]["proj_type_name"] then
                appsT = tempApps[4]["sub"]
                appsT["name"] = nil
                appsT["value"] = nil
            end
            local linksStr = cjson.encode(appsT)
            local sqlStr = string.format(" update tb_proj set proj_links='%s' where proj_code='%s' ", linksStr, proj_code)
            db_query.excute(sqlStr)
        end
    end
end

local status, apps, count, total = db_query.projectList_get(nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 10000000, 0)
if status == true and apps ~= nil and apps[1] ~= nil then
    for k, v in pairs(apps) do
        modifyTableProjLinks(v["proj_code"])
    end
end

local tab = {}
tab["result"] = "OK"
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))


