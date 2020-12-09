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

ngx.log(ngx.ERR, "sync info -------: ", 1111111)

local tab = {}
tab["result"] = "参数必须是JSON格式"
tab["error"] = error_table.get_error("ERROR_JSON_WRONG")

local function modifyTableProjLinks(proj_code, proj_linksTab)
    comm_func.do_dump_value("------zjq---9999999", 0)
    comm_func.do_dump_value(proj_linksTab, 0)
    local statusT, appsT = db_project.projectLinkType_get(proj_code, 30)
    if statusT == true and appsT[1] ~= nil then
    else
        local isHaveNewModule = false
        for plk, plv in pairs(proj_linksTab) do
            if plv["proj_module_code"] == "9" or plv["proj_module_code"] == 9 then
                for plsubk, plsubv in pairs(plv["sub"]) do
                    if plsubv["proj_link_type"] == "30" or plv["proj_link_type"] == 30 then
                        isHaveNewModule = true
                        break
                    end
                end
            end
            if isHaveNewModule == true then
                break
            end
        end
        if isHaveNewModule == false then
            local newProj_linksTab = comm_func.table_clone(proj_linksTab)
            local newProj_linksTabLength = #newProj_linksTab
            local newModuleTab = {}
            newModuleTab["proj_module_code"] = "9"
            newModuleTab["name"] = "改造"
            newModuleTab["sub"] = {}
            local newLinkTab = {}
            newLinkTab["name"] = "技术安全交底"
            newLinkTab["proj_link_type"] = 30
            local newLinkTab2 = {}
            newLinkTab2["name"] = "材料验收"
            newLinkTab2["proj_link_type"] = 31
            local newLinkTab3 = {}
            newLinkTab3["name"] = "关键工序"
            newLinkTab3["proj_link_type"] = 32
            local newLinkTab4 = {}
            newLinkTab4["name"] = "完工整体照片"
            newLinkTab4["proj_link_type"] = 33
            newModuleTab["sub"][1] = newLinkTab
            newModuleTab["sub"][2] = newLinkTab2
            newModuleTab["sub"][3] = newLinkTab3
            newModuleTab["sub"][4] = newLinkTab4
            newProj_linksTab[newProj_linksTabLength + 1] = newModuleTab
            local proj_links_before = cjson.encode(proj_linksTab)
            local proj_links = cjson.encode(newProj_linksTab)

            comm_func.do_dump_value(proj_links, 0)

            local status, apps = db_project.project_module_links_add_gaizao(proj_code, proj_links_before, proj_links, "改造", "9", "技术安全交底", 30, "材料验收", 31, "关键工序", 32, "完工整体照片", 33)
        end

    end
end

local status, apps, count, total = db_query.projectList_get('GDJZAAAA201903YD', nil, nil, nil, nil, nil, nil, nil, nil, true, 1, 0)
--local status, apps,count,total = db_query.projectList_get(nil,nil,nil,nil,nil,nil,nil,nil,nil,true,100000,0)
--local status, apps,count,total = db_query.projectList_get(nil,nil,nil,nil,nil,nil,nil,nil,nil,true,1,0)
comm_func.do_dump_value(apps, 0)
if status == true and apps ~= nil and apps[1] ~= nil then
    for k, v in pairs(apps) do
        modifyTableProjLinks(v["proj_code"], cjson.decode(v["proj_links"]))
    end
end
local tab = {}
tab["result"] = "OK"
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))


