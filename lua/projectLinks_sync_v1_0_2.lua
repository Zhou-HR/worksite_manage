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

local function modifyTableProjLinks(proj_code, proj_linksTab, projTab)
    local isHaveNewModule = false
    local proj_links_before = cjson.encode(proj_linksTab)
    if proj_linksTab ~= nil and proj_linksTab[1] ~= nil then
        if proj_linksTab[1]["proj_module_code"] == "1" then
            if proj_linksTab[3]["proj_module_code"] == "3" then
                if proj_linksTab[3]["sub"][2]["proj_link_type"] == 19 then
                    proj_linksTab[3]["sub"][2]["name"] = "电表及空开照片"
                end
            end
            if proj_linksTab[4]["proj_module_code"] == "4" then
                if proj_linksTab[4]["sub"][2]["proj_link_type"] == 22 then
                    proj_linksTab[4]["sub"][2]["name"] = "机房柜布线照片"
                end
            end

        elseif proj_linksTab[2]["proj_module_code"] == "1" then
            if proj_linksTab[4]["proj_module_code"] == "3" then
                if proj_linksTab[4]["sub"][2]["proj_link_type"] == 19 then
                    proj_linksTab[4]["sub"][2]["name"] = "电表及空开照片"
                end
            end
            if proj_linksTab[5]["proj_module_code"] == "4" then
                if proj_linksTab[5]["sub"][2]["proj_link_type"] == 22 then
                    proj_linksTab[5]["sub"][2]["name"] = "机房柜布线照片"
                end
            end
        else
            isHaveNewModule = true
        end

        if isHaveNewModule == false then
            local proj_links = cjson.encode(proj_linksTab)
            local status, apps = db_project.project_module_links_name_update(proj_code, proj_links_before, proj_links, nil, nil, nil, nil)
            return status
        end
    end

end
local projTab = {}
local status, apps, count, total = db_query.projectList_get(nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 10000000, 0)
if status == true and apps ~= nil and apps[1] ~= nil then
    for k, v in pairs(apps) do
        if v["proj_code"] ~= nil and cjson.decode(v["proj_links"]) ~= nil then
            local insertLinkProjCode = modifyTableProjLinks(v["proj_code"], cjson.decode(v["proj_links"]), v)
            if insertLinkProjCode == true then
                table.insert(projTab, v["proj_code"])
                --break
            end
        end
        --break
    end
end
local tab = {}
tab["result"] = projTab
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))


