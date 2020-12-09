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
local proj_company_code = decode_params["proj_company_code"]
local proj_bu_code_before = decode_params["proj_bu_code"]
local start_time = decode_params["start_time"]
local end_time = decode_params["end_time"]
local is_download = decode_params["is_download"]

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

if start_time ~= nil and type(start_time) ~= "number" then
    local tab = {}
    tab["result"] = "start_time必须为长整型"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end
if end_time ~= nil and type(end_time) ~= "number" then
    local tab = {}
    tab["result"] = "end_time必须为长整型"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end
if start_time == nil or end_time == nil then
    local tab = {}
    tab["result"] = "start_time、end_time必须为长整型"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
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
    tab["error"] = error_table.get_error("ERROR_PROJ_FINED_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

local status, apps, count, total, limit, offset, excelSql = db_project.projectFinedList_get(proj_code, proj_bu_code, isAdmin, proj_company_code, proj_bu_code_before, start_time, end_time, limit, offset)

if status == true then
    local red = redis:new()
    local nowTime = ngx.now()
    red:set(conf_sys.project_fined_list_excel_sql .. tostring(user_id), excelSql)
    if apps ~= nil and apps[1] ~= nil then
        for k, v in pairs(apps) do
            v["gc_xj"] = v["gc_tj_gj"] + v["gc_tj_hnt"] + v["gc_tj_dw"] + v["gc_tj_qt"] + v["gc_jd_cl"] + v["gc_jd_gy"] + v["gc_yjzl_jd"] + v["gc_yjzl_zb"] + v["gc_yjzl_zp"]
            v["cg_xj"] = v["cg_tt_cp"] + v["cg_tt_az"] + v["cg_pt_pt"]
            if v["gc_tj_gj_max"] == -1 then
                v["gc_tj_gj"] = -1
            end
            if v["gc_tj_hnt_max"] == -1 then
                v["gc_tj_hnt"] = -1
            end
            if v["gc_tj_dw_max"] == -1 then
                v["gc_tj_dw"] = -1
            end
            if v["gc_tj_qt_max"] == -1 then
                v["gc_tj_qt"] = -1
            end
            if v["gc_jd_cl_max"] == -1 then
                v["gc_jd_cl"] = -1
            end
            if v["gc_jd_gy_max"] == -1 then
                v["gc_jd_gy"] = -1
            end
            if v["gc_yjzl_jd_max"] == -1 then
                v["gc_yjzl_jd"] = -1
            end
            if v["gc_yjzl_zb_max"] == -1 then
                v["gc_yjzl_zb"] = -1
            end
            if v["gc_yjzl_zp_max"] == -1 then
                v["gc_yjzl_zp"] = -1
            end
            if v["cg_tt_cp_max"] == -1 then
                v["cg_tt_cp"] = -1
            end
            if v["cg_tt_az_max"] == -1 then
                v["cg_tt_az"] = -1
            end
            if v["cg_pt_pt_max"] == -1 then
                v["cg_pt_pt"] = -1
            end

            v["gc_tj_gj_max"] = nil
            v["gc_tj_hnt_max"] = nil
            v["gc_tj_dw_max"] = nil
            v["gc_tj_qt_max"] = nil
            v["gc_jd_cl_max"] = nil
            v["gc_jd_gy_max"] = nil
            v["gc_yjzl_jd_max"] = nil
            v["gc_yjzl_zb_max"] = nil
            v["gc_yjzl_zp_max"] = nil
            v["cg_tt_cp_max"] = nil
            v["cg_tt_az_max"] = nil
            v["cg_pt_pt_max"] = nil

        end
    end
    local fileUrl
    if is_download == true then
        local fileName = "Deduction_" .. tostring(nowTime) .. ".xlsx"
        local filePath = conf_sys.project_fined_list_excel_file_dir .. fileName
        local peroidTime = os.date("%Y-%m-%d %H:%M:%S", start_time) .. tostring("----") .. os.date("%Y-%m-%d %H:%M:%S", end_time)
        local fileCmd = string.format("/usr/bin/python /home/gqh_workspace/project/gd_worksite_manage_trial/lua/py/project_fined_statistics_gen.py %s %s %s %s %s \"%s\" %s \"%s\"", conf_sys.sys_db["database_value"], conf_sys.sys_db["user_value"], conf_sys.sys_db["password_value"], conf_sys.sys_db["host_value"], conf_sys.sys_db["port_value"], excelSql, filePath, peroidTime)
        os.execute(fileCmd)
        if comm_func.file_exists(filePath) == true then
            fileUrl = conf_sys.project_fined_list_excel_file_url_path .. fileName
        else
            local tab = {}
            tab["result"] = "生成报表失败"
            tab["error"] = error_table.get_error("ERROR_PROJ_FINED_LIST_FILE_GEN_FAILED")
            ngx.say(cjson.encode(tab))
            return
        end
    end
    local tab = {}
    local otherTab = {}
    --comm_func.do_dump_value(total,0)
    otherTab["total"] = total
    otherTab["limit"] = limit
    otherTab["offset"] = offset
    otherTab["count"] = count
    if is_download == true then
        if fileUrl ~= nil then
            tab["result"] = fileUrl
        end
    else
        tab["other"] = otherTab
        tab["result"] = apps
    end
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_PROJ_FINED_LIST_GET_FAILED")
    ngx.say(cjson.encode(tab))
end

