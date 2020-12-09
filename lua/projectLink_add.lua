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
--local proj_module_name = decode_params["proj_module_name"]

local proj_module_code = decode_params["proj_module_code"]
local proj_link_name = decode_params["proj_link_name"]
local proj_link_type = decode_params["proj_link_type"]

local proj_links_before

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

local isParamRight = true
local errMsg
if type(proj_code) ~= "string" or string.len(proj_code) < 2 then
    errMsg = "proj_code参数错误"
    isParamRight = false
end

if isParamRight and (type(proj_module_code) ~= "string" or string.len(proj_module_code) < 1 or moduleTab[proj_module_code] == nil) then
    errMsg = "proj_module_code参数错误"
    isParamRight = false
end

if isParamRight and (type(proj_link_name) ~= "string" or string.len(proj_link_name) < 1) then
    errMsg = "proj_link_name参数错误"
    isParamRight = false
end

if isParamRight and type(proj_link_type) ~= "number" then
    errMsg = "proj_link_type参数错误"
    isParamRight = false
end

if isParamRight == false then
    local tab = {}
    tab["result"] = errMsg
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local user_id = comm_func.get_http_header("user_id", ngx)
local proj_bu_code
local userStatus, userApps = db_query.userFromId_get(user_id)
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    proj_bu_code = userApps[1]["user_bu_code"]
    if userApps[1]["user_role"] ~= 1 then
        local tab = {}
        tab["result"] = "该账号无权限修改"
        tab["error"] = error_table.get_error("ERROR_USER_PERMISSION_REFUSE")
        ngx.say(cjson.encode(tab))
        return
    else
        proj_bu_code = string.sub(userApps[1]["user_bu_code"], 1, 2)
    end
else
    local tab = {}
    tab["result"] = "用户不存在"
    tab["error"] = error_table.get_error("ERROR_USER_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps, count, total = db_query.projectList_get(proj_code, nil, nil, nil, nil, nil, nil, proj_bu_code, nil, false, 1, 0)
if status == true and count == 1 then
else
    local tab = {}
    tab["result"] = "项目不存在"
    tab["error"] = error_table.get_error("ERROR_PROJ_NO_EXISTS")
    ngx.say(cjson.encode(tab))
    return
end

proj_links_before = apps[1]["proj_links"]
local links = apps[1]["proj_links"]

links = cjson.decode(links)
local isHasModule = false
local isLinkDupli = false
local newLink = {}
newLink["name"] = proj_link_name
newLink["proj_link_type"] = proj_link_type
local parentModuleCode = string.sub(proj_module_code, 1, 1)
for k, v in pairs(links) do
    if isHasModule == true then
        break
    end
    if proj_module_code == v["proj_module_code"] then
        isHasModule = true
        local subLinksTab = v["sub"]
        for subLinkk, subLinkv in pairs(subLinksTab) do
            if subLinkv["name"] == proj_link_name or subLinkv["proj_link_type"] == proj_link_type then
                isLinkDupli = true
                break
            end
        end
        if isLinkDupli == false then
            links[k]["sub"][#subLinksTab + 1] = newLink
        end
        break
    elseif parentModuleCode == v["proj_module_code"] then
        local subModule = v["sub"]
        for subk, subv in pairs(subModule) do
            if proj_module_code == subv["proj_module_code"] then
                isHasModule = true

                local subLinksTab = subv["sub"]
                for subLinkk, subLinkv in pairs(subLinksTab) do
                    if subLinkv["name"] == proj_link_name or subLinkv["proj_link_type"] == proj_link_type then
                        isLinkDupli = true
                        break
                    end
                end
                if isLinkDupli == false then
                    links[k]["sub"]["sub"][#subLinksTab + 1] = newLink
                end
                break
            end
        end
    end
end

if isHasModule == false then
    local tab = {}
    tab["result"] = "模块不存在"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end
if isLinkDupli == true then
    local tab = {}
    tab["result"] = "施工环节重复"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local proj_links = cjson.encode(links)
local proj_module_name = moduleTab[proj_module_code]

if string.find(proj_module_name, "-") ~= nil then
    local modules = comm_func.split_string(proj_module_name, "-")
    proj_module_name = modules[1]
end

local status, apps = db_project.project_module_links_add(proj_code, proj_links_before, proj_links, proj_module_name, proj_module_code, proj_link_name, proj_link_type)
if status == true and apps[1] ~= nil then
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = "fail"
    tab["error"] = error_table.get_error("ERROR_LINK_ADD_FAILED")
    ngx.say(cjson.encode(tab))
end



