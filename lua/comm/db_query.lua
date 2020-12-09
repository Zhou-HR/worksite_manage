local _M = {}

function _M.get_new_pgmoon_connection()
    local host_value = conf_sys.sys_db["host_value"]
    local port_value = conf_sys.sys_db["port_value"]
    local database_value = conf_sys.sys_db["database_value"]
    local user_value = conf_sys.sys_db["user_value"]
    local password_value = conf_sys.sys_db["password_value"]

    local pg = pgmoon.new({
        host = host_value,
        port = port_value,
        database = database_value,
        user = user_value,
        password = password_value
    })
    return pg
end

function _M.excute(sql)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

--added by shenzhengkai at 20200901 for links start
function _M.selectSecondLinkFilter(proj_module_code)
    local whereStr = ""
    local whereTab = {}
    local sql = "select proj_link_name,proj_link_type  from  tb_proj_link_types where 1=1"
    if proj_module_code ~= nil and proj_module_code ~= "" then
        local likeStr = " proj_module_code = '" .. proj_module_code .. "' "
        table.insert(whereTab, likeStr)
    end
    whereStr = table.concat(whereTab, " and ")
    if string.len(whereStr) > 3 then
        sql = sql .. " and " .. whereStr
    end
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()
    if res ~= nil then
        return true, res
    else
        return false, res
    end
end
--added by shenzhengkai at 20200901 end

--added by shenzhengkai at 20200901 start
function _M.selectLinkFilter(proj_module_code)
    local whereTab = {}
    local sql = "select proj_module_code,proj_module_name  from  tb_proj_link_types where 1=1"
    local groupStr = "GROUP BY proj_module_code,proj_module_name"
    sql = sql .. "  " .. groupStr

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end
--added by shenzhengkai at 20200901 end

--added by shenzhengkai at 20200828 start
function _M.selectLinkList_get(examine_start_time, examine_end_time, submit_start_time, submit_end_time, fuzzy_searche_key, proj_link_type, proj_module_code, proj_company_code, proj_link_status, proj_bu_code, limit, offset)
    local whereStr = ""
    local whereTab = {}
    local whereFuzzyStr = ""
    local whereFuzzyTab = {}
    local limitStr = " limit " .. tostring(limit) .. " offset " .. tostring(offset)
    --local sql=" select tb.proj_code,tb.proj_name,tb.proj_station_type,tb.proj_tower_type,tpl.proj_link_id,tpl.proj_link_name,tpl.proj_module_name,tpl.proj_link_submit_time,tpl.proj_link_status,tpl.proj_link_reviewer_id,tpl.proj_link_reviewer_name,tpl.proj_link_pic,tb.proj_bu_name,tb.proj_bu_code,tbo.o_parent_name,tbo.o_parent_code,tps.proj_link_type,tps.proj_module_code,proj_link_review_time FROM tb_proj tb LEFT JOIN tb_proj_link tpl ON tb.proj_code=tpl.proj_code LEFT JOIN tb_organization tbo on tbo.o_parent_code=tb.proj_company_code left join tb_proj_link_types tps on tpl.proj_link_type = tps.proj_link_type where 1=1"
    --local totalSql="select count(proj_code)  as total from (select DISTINCT tb.proj_code FROM tb_proj tb LEFT JOIN tb_proj_link tpl ON tb.proj_code=tpl.proj_code   LEFT JOIN tb_organization tbo on tbo.o_parent_code=tb.proj_company_code left join tb_proj_link_types tps on tpl.proj_link_type = tps.proj_link_type  where 1=1 "
    local sql = " select DISTINCT tpl.proj_link_id ,tpl.*,tb.proj_code,tb.proj_name,tb.proj_station_type,tb.proj_tower_type,tbo.o_parent_code,tbo.o_parent_name,tb.proj_bu_name from tb_proj_link tpl "
    sql = sql .. "LEFT JOIN tb_proj tb on tb.proj_code=tpl.proj_code LEFT JOIN tb_organization tbo on tbo.o_parent_code=tb.proj_company_code LEFT JOIN tb_proj_link_types tps on tpl.proj_link_type = tps.proj_link_type "
    local totalSql = "select count(*) as total from tb_proj_link tpl "
    local reportSql = "select DISTINCT tbo.o_parent_name,tb.proj_bu_name, tb.proj_code,tb.proj_name,tb.proj_station_type,tb.proj_tower_type,tpl.proj_module_name,tpl.proj_link_name,tpl.proj_link_submit_time, tpl.proj_link_status,tpl.proj_link_review_time,tpl.proj_link_reviewer_name,tpl.proj_link_fine_value,tf.fine_time,tf.reviewer_name from tb_proj_link tpl"
    reportSql = reportSql .. " LEFT JOIN tb_proj tb on tb.proj_code=tpl.proj_code LEFT JOIN tb_organization tbo on tbo.o_parent_code=tb.proj_company_code  LEFT JOIN tb_proj_link_types tps on tpl.proj_link_type = tps.proj_link_type left join tb_link_fine tf on tf.proj_link_id=tpl.proj_link_id"
    if proj_company_code ~= nil and proj_company_code ~= "" then
        local likeStr = " tpl.proj_code in (select proj_code from tb_proj where proj_company_code='" .. proj_company_code .. "') "
        table.insert(whereTab, likeStr)
    end

    if proj_module_code ~= nil and proj_module_code ~= "" then
        local likeStr = " tpl.proj_module_name in (select proj_module_name from tb_proj_link_types where proj_module_code='" .. proj_module_code .. "') "
        table.insert(whereTab, likeStr)
    end

    if proj_link_type ~= nil and proj_link_type ~= "" then
        if proj_link_type == 99999 then

        else
            local likeStr = " tpl.proj_link_type = " .. proj_link_type .. " "
            table.insert(whereTab, likeStr)
        end
    end
    if proj_link_status ~= nil and proj_link_status ~= "" then
        if proj_link_status == 99999 then
            --      local likeStr = "1=1"
            --      table.insert(whereTab, likeStr)
        else
            local likeStr = " tpl.proj_link_status = " .. proj_link_status .. " "
            table.insert(whereTab, likeStr)
        end
    end

    if submit_start_time ~= nil and submit_end_time ~= nil and submit_start_time ~= "" and submit_end_time ~= "" then
        local likeStr = " tpl.proj_link_submit_time BETWEEN " .. submit_start_time .. " and  " .. submit_end_time .. " "
        table.insert(whereTab, likeStr)
    end

    if examine_start_time ~= nil and examine_end_time ~= nil and examine_start_time ~= "" and examine_end_time ~= "" then
        local likeStr = " tpl.proj_link_review_time BETWEEN " .. examine_start_time .. " and " .. examine_end_time .. " "
        table.insert(whereTab, likeStr)
    end

    if proj_bu_code ~= nil and proj_bu_code ~= "" then
        local userBuTab = comm_func.split_string(proj_bu_code, ",")
        if string.len(proj_bu_code) == 2 then
            table.insert(whereTab, string.format(" tpl.proj_bu_code like '%s%%'  ", proj_bu_code))
        elseif #userBuTab > 1 then
            local whereBuTab = {}
            for buk, buv in pairs(userBuTab) do
                table.insert(whereBuTab, string.format(" '%s' ", buv))
            end
            local whereBuTabStr = table.concat(whereBuTab, " , ")
            table.insert(whereTab, string.format(" tpl.proj_bu_code in ( %s )  ", whereBuTabStr))
        else
            table.insert(whereTab, string.format(" tpl.proj_bu_code='%s'  ", proj_bu_code))
        end
    end

    whereStr = table.concat(whereTab, " and ")
    if string.len(whereStr) > 3 then
        sql = sql .. " where  " .. whereStr
        sql = sql .. " order by tpl.proj_link_submit_time desc " .. limitStr
        reportSql = reportSql .. " where  " .. whereStr
        reportSql = reportSql .. " order by tpl.proj_link_submit_time desc "
        totalSql = totalSql .. " where  " .. whereStr
    else
        sql = sql .. " where  1=1 "
        sql = sql .. " order by tpl.proj_link_submit_time desc " .. limitStr
        reportSql = reportSql .. " where  1=1 "
        reportSql = reportSql .. " order by tpl.proj_link_submit_time desc "
        totalSql = totalSql
    end
    comm_func.do_dump_value("------------zjq---------------sql:", 0)
    comm_func.do_dump_value(sql, 0)
    comm_func.do_dump_value("------------zjq----totalSql=" .. totalSql, 0)

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(totalSql)
        if totalResult == true then
            return true, res, #res, total, limit, offset, reportSql
        else
            return false, res
        end
    else
        return false, res
    end
end
--added by shenzhengkai at 20200828 end

function _M.Mid_HaTe_updateDevEUIWithComNo(comNo, deveui, appeui, meterType)

    local nowTime = math.ceil(ngx.now())
    local sqlStr
    nowTime = tostring(nowTime)
    local status, result = _M.Mid_HaTe_getMapFromDevEUI(deveui)
    if status == true and result ~= nil and result[1] ~= nil then
        sqlStr = " update tb_dev_eui_mapping_no set no='" .. comNo .. "', time_s=" .. nowTime .. ", app_eui='" .. appeui .. "', meter_type='" .. meterType .. "' where dev_eui='" .. deveui .. "' "
    else
        sqlStr = " insert into tb_dev_eui_mapping_no(dev_eui,no,time_s,app_eui,meter_type)  values('" .. deveui .. "','" .. comNo .. "'," .. nowTime .. ",'" .. appeui .. "','" .. meterType .. "') "
    end
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end
function _M.Mid_HaTe_getMapFromComNo(comNo)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())

    local res = assert(pg:query("select * from tb_dev_eui_mapping_no where no ='" .. comNo .. "' order by time_s desc "))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil and res[1]["dev_eui"] ~= nil then
        return true, res
    else
        return false, res
    end
end
function _M.Mid_HaTe_getMapFromDevEUI(deveui)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())

    local res = assert(pg:query("select * from tb_dev_eui_mapping_no where dev_eui ='" .. deveui .. "' order by time_s  desc "))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil and res[1]["dev_eui"] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.Mid_HaTe_getMeterCtrlFromMap(comNo, ctrl_id, processor_name, ctrl_type, ctrl_state)
    local sqlStr = ""
    if comNo ~= nil then
        sqlStr = " no='" .. comNo .. "' "
    end
    if ctrl_id ~= nil then
        if string.len(sqlStr) > 0 then
            sqlStr = sqlStr .. " and ctrl_id=" .. tostring(ctrl_id)
        else
            sqlStr = " ctrl_id=" .. tostring(ctrl_id)
        end
    end
    if processor_name ~= nil then
        if string.len(sqlStr) > 0 then
            sqlStr = sqlStr .. " and processor_name='" .. processor_name .. "' "
        else
            sqlStr = " processor_name='" .. processor_name .. "' "
        end
    end
    if ctrl_type ~= nil then
        if string.len(sqlStr) > 0 then
            sqlStr = sqlStr .. " and ctrl_type='" .. ctrl_type .. "' "
        else
            sqlStr = " ctrl_type='" .. ctrl_type .. "' "
        end
    end
    if ctrl_state ~= nil then
        if string.len(sqlStr) > 0 then
            sqlStr = sqlStr .. " and ctrl_state=" .. tostring(ctrl_state)
        else
            sqlStr = " ctrl_state=" .. tostring(ctrl_state)
        end
    end

    local selectStr
    if string.len(sqlStr) > 0 then
        selectStr = "select * from tb_meter_ctrl_mapping_id where " .. sqlStr .. " order by time_s desc "
    else
        selectStr = "select * from tb_meter_ctrl_mapping_id  order by time_s desc "
    end

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())

    local res = assert(pg:query(selectStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil and res[1]["no"] ~= nil then
        return true, res
    else
        return false, res
    end
end
function _M.Mid_HaTe_updateMeterCtrlMap(comNo, ctrl_id, processor_name, ctrl_type, ctrl_state)

    local nowTime = math.ceil(ngx.now())
    local sqlStr
    nowTime = tostring(nowTime)
    local status, result = _M.Mid_HaTe_getMeterCtrlFromMap(comNo, nil, processor_name, ctrl_type, nil)
    if status == true and result ~= nil and result[1] ~= nil then
        sqlStr = " update tb_meter_ctrl_mapping_id set no='" .. comNo .. "', time_s=" .. nowTime .. ", ctrl_id=" .. tostring(ctrl_id) .. ", processor_name='" .. processor_name .. "',ctrl_type='" .. ctrl_type .. "', ctrl_state=" .. tostring(ctrl_state) .. " where no='" .. comNo .. "' and processor_name='" .. processor_name .. "' and ctrl_type='" .. ctrl_type .. "' "
    else
        sqlStr = " insert into tb_meter_ctrl_mapping_id(no,ctrl_id,processor_name,ctrl_type,time_s,ctrl_state)  values('" .. comNo .. "'," .. tostring(ctrl_id) .. ",'" .. processor_name .. "','" .. ctrl_type .. "'," .. nowTime .. "," .. tostring(ctrl_state) .. ") "
    end
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end
function _M.listTotal_get(sqlStr)

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res[1]["total"]
    else
        return false, res
    end
end

function _M.Link_get_list()
    local sqlStr = "select * from tb_link_debug  order by submit_time desc "

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.Link_add(sqlStr)

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.userRoleValue_get(roleValue)
    local roleTab = {}
    roleTab['0'] = 1000
    roleTab['1'] = 1100
    roleTab['2'] = 1200
    roleTab['3'] = 1300

    if roleTab[tostring(roleValue)] ~= nil then
        return roleTab[tostring(roleValue)]
    else
        return roleValue
    end
end

function _M.user_get(user_name, user_number)

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = nil
    if user_name ~= nil then
        res = assert(pg:query(" select * from tb_user where user_name='" .. user_name .. "' "))
    else
        res = assert(pg:query(" select * from tb_user where user_number='" .. user_number .. "' "))
    end
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.userId_get(user_name)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = nil
    res = assert(pg:query(" select * from tb_user where user_name='" .. user_name .. "' "))

    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return res[1]["user_id"]
    end
    return nil
end

function _M.userFromId_get(user_id)

    local pg = _M.get_new_pgmoon_connection()
    local sqlStr = string.format(" select * from tb_user where user_id= %s ", tostring(user_id))
    --comm_func.do_dump_value(sqlStr,0)
    assert(pg:connect())
    local res = assert(pg:query(" select * from tb_user where user_id=" .. tostring(user_id)))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.userAdmin_is(userInfo, user_id)
    if type(userInfo) == "table" then

        if (userInfo["user_role"] > 10 and userInfo["user_role"] < 1100) or userInfo["user_role"] == 0 then
            return true
        end
    else
        local pg = _M.get_new_pgmoon_connection()

        assert(pg:connect())
        local res = assert(pg:query(" select * from tb_user where user_id=" .. tostring(user_id)))
        pg:keepalive()

        if res ~= nil and res[1] ~= nil then
            if (res[1]["user_role"] > 10 and res[1]["user_role"] < 1100) or res[1]["user_role"] == 0 then
                return true
            end
        end
    end
    return false
end

function _M.userToken_update(dev_request_type, tokenStr, tokenUpdateTime, tokenExpiredTime, user_id)
    local sql = ""
    if dev_request_type == "user_web" then
        sql = " update tb_user set  user_web_token='" .. tokenStr .. "' , user_web_token_update_time=" .. tostring(tokenUpdateTime) .. " , user_web_token_expired_time=" .. tostring(tokenUpdateTime) .. " where user_id=" .. tostring(user_id)
    else
        sql = " update tb_user set  user_mobile_token='" .. tokenStr .. "' , user_mobile_token_update_time=" .. tostring(tokenUpdateTime) .. " , user_mobile_token_expired_time=" .. tostring(tokenUpdateTime) .. " where user_id=" .. tostring(user_id)
    end

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.userPassword_update(user_id, oldPasswd, newPasswd)
    local sql = " update tb_user set  user_password='" .. newPasswd .. "'  where user_id=" .. tostring(user_id) .. " and user_password='" .. oldPasswd .. "' RETURNING user_id "

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.reset_password(user_id, newPasswd)
    local sql = " update tb_user set  user_password='" .. newPasswd .. "'  where user_id=" .. tostring(user_id) .. " RETURNING user_id "

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.userList_get(isAdmin, user_bu_codeLike, user_id, user_name, user_mail, user_phone, user_role, user_number, user_bu_name, user_bu_code, user_job, user_code, user_entry_time, user_company, user_company_code, fuzzy_searche_key, limit, offset)
    local sqlWhereTab = {}
    local sqlWhereFuzzyTab = {}
    local sqlWhereTabIndex = 1
    local sqlStr
    local sqlFuzzyStr = ""
    local sqlTotal

    sqlStr = " select * from tb_user  "
    sqlTotal = " select count(*) as total from tb_user "

    if isAdmin == true then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  where 1=1 ")
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    else
        if user_bu_codeLike ~= nil then
            local userBuTab = comm_func.split_string(user_bu_codeLike, ",")
            if string.len(user_bu_codeLike) < 3 then
                sqlWhereTab[sqlWhereTabIndex] = string.format("  where user_bu_code like '%s%%'  ", user_bu_codeLike)
            elseif #userBuTab > 1 then
                local whereBuTab = {}
                for buk, buv in pairs(userBuTab) do
                    table.insert(whereBuTab, string.format(" '%s' ", buv))
                end
                local whereBuTabStr = table.concat(whereBuTab, " , ")
                sqlWhereTab[sqlWhereTabIndex] = string.format(" where user_bu_code in ( %s )  ", whereBuTabStr)
            else
                sqlWhereTab[sqlWhereTabIndex] = string.format("  where  user_bu_code like '%%%s%%' ", user_bu_codeLike)
            end

        end
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end

    if user_id ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_id=%d ", user_id)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_name ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_name  like '%%%s%%' ", user_name)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" user_name like '%%%s%%' ", fuzzy_searche_key))
    end
    if user_mail ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_mail  like '%%%s%%' ", user_mail)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" user_mail like '%%%s%%' ", fuzzy_searche_key))
    end
    if user_phone ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_phone  like '%%%s%%' ", user_phone)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" user_phone like '%%%s%%' ", fuzzy_searche_key))
    end
    if user_role ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_role = %d ", user_role)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_number ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_number = '%s' ", user_number)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" user_number like '%%%s%%' ", fuzzy_searche_key))
    end
    if user_bu_name ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_bu_name  like '%%%s%%' ", user_bu_name)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" user_bu_name  like '%%%s%%' ", fuzzy_searche_key))
    end
    if user_bu_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_bu_code  = '%s' ", user_bu_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_job ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_job  like '%%%s%%' ", user_job)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format("  user_job  like '%%%s%%' ", fuzzy_searche_key))
    end
    if user_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_code  = '%s' ", user_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_entry_time ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_entry_time  like '%%%s%%' ", user_entry_time)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_company ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_company  like '%%%s%%' ", user_company)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format("  user_company  like '%%%s%%' ", fuzzy_searche_key))
    end
    if user_company_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_company_code  = '%s' ", user_company_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end

    local sqlWhereStr = table.concat(sqlWhereTab, " ")
    local sqlWhereFuzzyStr = table.concat(sqlWhereFuzzyTab, " or ")

    if string.len(sqlWhereFuzzyStr) > 3 then
        sqlWhereStr = string.format(" %s and ( %s ) ", sqlWhereStr, sqlWhereFuzzyStr)
        sqlWhereTab[sqlWhereTabIndex] = string.format(" and ( %s  ) ", sqlWhereFuzzyStr)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    sqlTotal = string.format(" %s %s ", sqlTotal, sqlWhereStr)

    sqlWhereTab[sqlWhereTabIndex] = string.format(" order by user_company asc,   user_bu_name asc, user_entry_time asc limit %d offset %d  ", limit, offset)
    sqlWhereTabIndex = sqlWhereTabIndex + 1

    sqlStr = string.format(" %s %s ", sqlStr, table.concat(sqlWhereTab, " "))
    --comm_func.do_dump_value(sqlStr,0)
    --comm_func.do_dump_value(sqlTotal,0)

    local sql = sqlStr
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(sqlTotal)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false, res
    end
end

function _M.user_update(user_id, user_mail, user_phone, user_role, user_number, user_bu_name, user_bu_code, user_job, user_code, user_entry_time, user_company, user_company_code)
    local sqlWhereTab = {}
    local sqlWhereTabIndex = 1
    local sqlStr

    if user_mail ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format(" user_mail  = '%s' ", user_mail)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_phone ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_phone  = '%s' ", user_phone)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_role ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_role = %d ", user_role)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_number ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_number = '%s' ", user_number)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_bu_name ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_bu_name  = '%s' ", user_bu_name)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_bu_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_bu_code  = '%s' ", user_bu_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_job ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_job  = '%s' ", user_job)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_code  = '%s' ", user_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_entry_time ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_entry_time  = '%s' ", user_entry_time)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_company ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_company  = '%s' ", user_company)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_company_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_company_code  = '%s' ", user_company_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end

    local sqlWhereStr = table.concat(sqlWhereTab, " ,")
    sqlStr = string.format(" %s %s where user_id= %d ", " update tb_user set ", sqlWhereStr, user_id)

    local sql = sqlStr
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.organizationList_get(isAdmin, user_company_code, user_bu_code, o_name, o_code, o_parent_code, o_parent_name, limit, offset)
    local sqlWhereTab = {}
    local sqlWhereTabIndex = 1
    local sqlStr
    local sqlTotal

    sqlStr = " select * from tb_organization  "
    sqlTotal = " select count(*) as total from tb_organization "

    if isAdmin == true then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  where 1=1 ")
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    else
        sqlWhereTab[sqlWhereTabIndex] = string.format("  where o_parent_code='%s' ", user_company_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end

    if o_name ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and o_name like '%%%s%%' ", o_name)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if o_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and o_code  = '%s' ", o_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if o_parent_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and o_parent_code  = '%s' ", o_parent_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if o_parent_name ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and o_parent_name  like '%%%s%%' ", o_parent_name)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end

    local sqlWhereStr = table.concat(sqlWhereTab, " ")
    sqlTotal = string.format(" %s %s ", sqlTotal, sqlWhereStr)

    sqlWhereTab[sqlWhereTabIndex] = string.format(" order by o_parent_code asc,   o_code asc limit %d offset %d  ", limit, offset)
    sqlWhereTabIndex = sqlWhereTabIndex + 1

    sqlStr = string.format(" %s %s ", sqlStr, table.concat(sqlWhereTab, " "))
    --comm_func.do_dump_value(sqlStr,0)
    --comm_func.do_dump_value(sqlTotal,0)

    local sql = sqlStr
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(sqlTotal)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false, res
    end
end

function _M.organizationListProvince_get(limit, offset)
    local sqlWhereTab = {}
    local sqlWhereTabIndex = 1
    local sqlStr
    local sqlTotal

    sqlStr = " select * from tb_organization   where LENGTH(o_code) =2 "
    sqlTotal = " select count(*) as total from tb_organization  where LENGTH(o_code) =2 "

    local sql = sqlStr
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(sqlTotal)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false, res
    end
end

function _M.projectList_get(proj_code, proj_name, proj_addr, proj_establish_time, proj_station_type, proj_tower_type, proj_base_type, proj_bu_code, fuzzy_searche_key, isAdmin, limit, offset)
    local whereStr = ""
    local whereTab = {}
    local whereFuzzyStr = ""
    local whereFuzzyTab = {}
    local limitStr = " limit " .. tostring(limit) .. " offset " .. tostring(offset)
    local totalSql = " select count(proj_code) as total from tb_proj "
    if proj_code ~= nil then
        table.insert(whereTab, string.format(" proj_code='%s'  ", proj_code))
    elseif fuzzy_searche_key ~= nil then
        table.insert(whereFuzzyTab, string.format(" proj_code like '%%%s%%'  ", fuzzy_searche_key))
    end

    if proj_name ~= nil and proj_name ~= "" then
        local likeStr = " proj_name like '%" .. proj_name .. "%' "
        table.insert(whereTab, likeStr)
    elseif fuzzy_searche_key ~= nil then
        table.insert(whereFuzzyTab, string.format(" proj_name like '%%%s%%'  ", fuzzy_searche_key))
    end

    if proj_addr ~= nil and proj_addr ~= "" then
        local likeStr = " proj_addr like '%" .. proj_addr .. "%' "
        table.insert(whereTab, likeStr)
    elseif fuzzy_searche_key ~= nil then
        table.insert(whereFuzzyTab, string.format(" proj_addr like '%%%s%%'  ", fuzzy_searche_key))
    end

    if proj_establish_time ~= nil and proj_establish_time ~= "" then
        local likeStr = " proj_establish_time like '%" .. proj_establish_time .. "%' "
        table.insert(whereTab, likeStr)
    end
    if proj_station_type ~= nil and proj_station_type ~= "" then
        local likeStr = " proj_station_type like '%" .. proj_station_type .. "%' "
        table.insert(whereTab, likeStr)
    end
    if proj_tower_type ~= nil and proj_tower_type ~= "" then
        local likeStr = " proj_tower_type like '%" .. proj_tower_type .. "%' "
        table.insert(whereTab, likeStr)
    end
    if proj_base_type ~= nil and proj_base_type ~= "" then
        local likeStr = " proj_base_type like '%" .. proj_base_type .. "%' "
        table.insert(whereTab, likeStr)
    end
    if proj_bu_code ~= nil and proj_bu_code ~= "" then
        local userBuTab = comm_func.split_string(proj_bu_code, ",")
        if string.len(proj_bu_code) == 2 then
            table.insert(whereTab, string.format(" proj_bu_code like '%s%%'  ", proj_bu_code))
        elseif #userBuTab > 1 then
            local whereBuTab = {}
            for buk, buv in pairs(userBuTab) do
                table.insert(whereBuTab, string.format(" '%s' ", buv))
            end
            local whereBuTabStr = table.concat(whereBuTab, " , ")
            table.insert(whereTab, string.format(" proj_bu_code in ( %s )  ", whereBuTabStr))
        else
            table.insert(whereTab, string.format(" proj_bu_code='%s'  ", proj_bu_code))
        end
    end
    whereStr = table.concat(whereTab, " and ")
    whereFuzzyStr = table.concat(whereFuzzyTab, " or  ")

    local sql = " select * from tb_proj "
    if string.len(whereStr) > 3 then
        if string.len(whereFuzzyStr) > 3 then
            whereStr = string.format(" %s and ( %s ) ", whereStr, whereFuzzyStr)
        end
        sql = sql .. " where " .. whereStr
        totalSql = totalSql .. " where " .. whereStr
    elseif string.len(whereFuzzyStr) > 3 then
        sql = sql .. " where " .. whereFuzzyStr
        totalSql = totalSql .. " where " .. whereFuzzyStr
    end
    sql = sql .. " order by proj_submit_time desc " .. limitStr

    comm_func.do_dump_value("------ggg---projectList_get:1" .. sql, 0)

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(totalSql)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false, res
    end
end

function _M.project_import(data)
    local status, apps, count, total = _M.projectList_get(data[1], nil, nil, nil, nil, nil, nil, nil, nil, false, 1, 0)
    if status == true and count == 1 then
        if data[14] == "2" then

            local proj_type_value_old
            local proj_type_value_new

            if apps[1]["proj_station_type"] == "落地" then
                proj_type_value_old = 0
            elseif apps[1]["proj_base_type"] == "" then
                proj_type_value_old = 1
            else
                if string.find(apps[1]["proj_base_type"], "不同意") ~= nil then
                    proj_type_value_old = 1
                elseif string.find(apps[1]["proj_base_type"], "同意") ~= nil then
                    proj_type_value_old = 2
                else
                    proj_type_value_old = 1
                end
            end

            if data[3] == "落地" then
                proj_type_value_new = 0
            elseif data[6] == "" then
                proj_type_value_new = 1
            else
                if string.find(data[6], "不同意") ~= nil then
                    proj_type_value_new = 1
                elseif string.find(data[6], "同意") ~= nil then
                    proj_type_value_new = 2
                else
                    proj_type_value_new = 1
                end
            end

            if data[3] ~= apps[1]["proj_station_type"] or proj_type_value_old ~= proj_type_value_new then
                local deleteStatus, deleteApps = db_project.project_delete(data[1])
                if deleteStatus == true and deleteApps ~= nil and deleteApps[1] ~= nil then
                else
                    return false, data[1]
                end
            else
                if true then
                    local status, res = db_project.project_update(data[1], data[4], data[5], data[7], data[8], data[9], data[10], nil, nil, nil)
                    return status, res
                end
                local projLinkStatus, projLinkDatas = db_project.linkUnInitStatusList_get(data[1])
                if projLinkDatas ~= nil and projLinkDatas[1] ~= nil then
                    return false, data[1]
                end
                local deleteStatus, deleteApps = db_project.project_delete(data[1])
                if deleteStatus == true and deleteApps ~= nil and deleteApps[1] ~= nil then
                else
                    return false, data[1]
                end
            end
        else
            return false, data[1]
        end
    end
    local notTime = math.ceil(ngx.now())
    local sqlFormat = "  insert into tb_proj(proj_code,proj_name,proj_station_type,proj_tower_type,proj_tower_height,proj_base_type,proj_lon,proj_lat,proj_addr,proj_establish_time,proj_bu_code,proj_bu_name,proj_company_code,proj_import_time) values('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s',%d) "
    local sql = string.format(sqlFormat, data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], notTime)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local proj_type_value
        if data[3] == "落地" then
            proj_type_value = 0
        elseif data[6] == "" then
            proj_type_value = 1
        else
            if string.find(data[6], "不同意") ~= nil then
                proj_type_value = 1
            elseif string.find(data[6], "同意") ~= nil then
                proj_type_value = 2
            else
                proj_type_value = 1
            end
        end
        _M.projectLink_gen(data[1], proj_type_value, data[11], data[13])

        return true, res
    else
        return false, res
    end


end

function _M.projectPicTakeControlLink_update(sqlLink)
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sqlLink))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.projectPicTakeControl_update(proj_code, proj_bu_code, isAdmin, proj_link_pic_max_num, proj_link_max_distan)
    local sqlTab = {}
    local sql
    local sqlLink = nil

    table.insert(sqlTab, " update tb_proj set ")
    if proj_link_pic_max_num ~= nil then
        table.insert(sqlTab, string.format(" proj_link_pic_max_num=%d ", proj_link_pic_max_num))
        if proj_link_max_distan ~= nil then
            table.insert(sqlTab, string.format(", proj_link_max_distan=%d ", proj_link_max_distan))
        end
        sqlLink = string.format(" update tb_proj_link set proj_link_pic_max_num=%d where proj_code='%s' returning proj_link_id ", proj_link_pic_max_num, proj_code)
    elseif proj_link_max_distan ~= nil then
        table.insert(sqlTab, string.format(" proj_link_max_distan=%d ", proj_link_max_distan))
    end
    table.insert(sqlTab, string.format(" where  proj_code='%s' ", proj_code))
    if isAdmin ~= true then
        table.insert(sqlTab, string.format(" and proj_bu_code like '%s%%' ", proj_bu_code))
    end
    table.insert(sqlTab, " returning proj_code ")

    sql = table.concat(sqlTab, "   ")

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        if sqlLink ~= nil then
            if res[1] ~= nil and res[1]["proj_code"] ~= nil then
                local linkStatus = _M.projectPicTakeControlLink_update(sqlLink)
                if linkStatus == true then
                    return true, res
                else
                    return false, res
                end
            else
                return false, res
            end
        end
        return true, res
    else
        return false, res
    end

end

function _M.projectAllType_get(hasLinkType)
    local allType
    if hasLinkType == true then
        allType = {
            [1] = {
                name = "落地",
                value = 0,
                sub = {
                    [1] = {
                        name = "地质勘探",
                        proj_module_code = "0",
                        sub = {
                            [1] = {
                                name = "钻孔照片",
                                proj_link_type = 0
                            },
                            [2] = {
                                name = "取土样照片",
                                proj_link_type = 1
                            }
                        }
                    },
                    [2] = {
                        name = "土建施工",
                        proj_module_code = "1",
                        sub = {
                            [1] = {
                                name = "施工进场",
                                proj_link_type = 25
                            },
                            [2] = {
                                name = "落地塔基",
                                proj_module_code = "1-0",
                                sub = {
                                    [1] = {
                                        name = "开挖验收",
                                        proj_link_type = 2
                                    },
                                    [2] = {
                                        name = "材料验收",
                                        proj_link_type = 3
                                    },
                                    [3] = {
                                        name = "钢筋验收",
                                        proj_link_type = 4
                                    },
                                    [4] = {
                                        name = "浇筑验收",
                                        proj_link_type = 5
                                    },
                                    [5] = {
                                        name = "地网验收",
                                        proj_link_type = 6
                                    },
                                    [6] = {
                                        name = "预埋件验收",
                                        proj_link_type = 7
                                    }
                                }
                            },
                            [3] = {
                                name = "落地机房",
                                proj_module_code = "1-1",
                                sub = {
                                    [1] = {
                                        name = "基槽验收",
                                        proj_link_type = 8
                                    },
                                    [2] = {
                                        name = "钢筋工序验收",
                                        proj_link_type = 9
                                    },
                                    [3] = {
                                        name = "混凝土浇筑验收",
                                        proj_link_type = 10
                                    }
                                }
                            },
                            [4] = {
                                name = "整体验收",
                                proj_link_type = 26
                            }
                        }
                    },
                    [3] = {
                        name = "塔桅安装",
                        proj_module_code = "2",
                        sub = {
                            [1] = {
                                name = "特殊工种上岗证照片",
                                proj_link_type = 13
                            },
                            [2] = {
                                name = "铁塔厂家出厂合格证照片",
                                proj_link_type = 14
                            },
                            [3] = {
                                name = "铁塔图纸照片",
                                proj_link_type = 15
                            },
                            [4] = {

                                name = "基础回弹照片",
                                proj_link_type = 16
                            },
                            [5] = {
                                name = "整体完工（初验）照片",
                                proj_link_type = 17
                            }
                        }
                    },
                    [4] = {
                        name = "接电施工",
                        proj_module_code = "3",
                        sub = {
                            [1] = {
                                name = "接入点照片",
                                proj_link_type = 18
                            },
                            [2] = {
                                name = "电表及空开照片",
                                proj_link_type = 19
                            },
                            [3] = {
                                name = "线缆材质及埋深照片",
                                proj_link_type = 20
                            }
                        }
                    },
                    [5] = {
                        name = "配套安装",
                        proj_module_code = "4",
                        sub = {
                            [1] = {
                                name = "底座固定照片",
                                proj_link_type = 21
                            },
                            [2] = {
                                name = "机房柜布线照片",
                                proj_link_type = 22
                            },
                            [3] = {
                                name = "整体完工照片（初验）",
                                proj_link_type = 23
                            }
                        }
                    },
                    [6] = {
                        name = "竣工交维",
                        proj_module_code = "5",
                        sub = {
                            [1] = {
                                name = "竣工照片",
                                proj_link_type = 24
                            }
                        }
                    },
                    [7] = {
                        name = "交付验收",
                        proj_module_code = "10",
                        sub = {
                            [1] = {
                                name = "交付单",
                                proj_link_type = 34
                            },
                            [2] = {
                                name = "基站设备",
                                proj_link_type = 35
                            }
                        }
                        --fixed by zhangjieqiong for jiaofuyanshou 20200820
                    },
                    [8] = {
                        name = "拆站",
                        proj_module_code = "6",
                        sub = {
                            [1] = {
                                name = "拆站照片",
                                proj_link_type = 27
                            }
                        }
                    },
                    [9] = {
                        name = "安装电表",
                        proj_module_code = "7",
                        sub = {
                            [1] = {
                                name = "安装电表照片",
                                proj_link_type = 28
                            }
                        }
                    },
                    [10] = {
                        name = "并购",
                        proj_module_code = "8",
                        sub = {
                            [1] = {
                                name = "并购照片",
                                proj_link_type = 29
                            }
                        }
                    },
                    [11] = {
                        name = "改造",
                        proj_module_code = "9",
                        sub = {
                            [1] = {
                                name = "技术安全交底",
                                proj_link_type = 30
                            },
                            [2] = {
                                name = "材料验收",
                                proj_link_type = 31
                            },
                            [3] = {
                                name = "关键工序",
                                proj_link_type = 32
                            },
                            [4] = {
                                name = "完工整体照片",
                                proj_link_type = 33
                            }
                        }
                        --fixed by zhangjieqiong for gaizao 20200520
                    }
                }
            },
            [2] = {
                name = "楼面（普通）",
                value = 1,
                sub = {
                    [1] = {
                        name = "土建施工",
                        proj_module_code = "1",
                        sub = {
                            [1] = {
                                name = "施工进场",
                                proj_link_type = 25
                            },
                            [2] = {
                                name = "基础尺寸",
                                proj_link_type = 11
                            },
                            [3] = {
                                name = "地网验收",
                                proj_link_type = 6
                            },
                            [4] = {
                                name = "整体验收",
                                proj_link_type = 26
                            }
                        }
                    },
                    [2] = {
                        name = "塔桅安装",
                        proj_module_code = "2",
                        sub = {
                            [1] = {
                                name = "特殊工种上岗证照片",
                                proj_link_type = 13
                            },
                            [2] = {
                                name = "铁塔厂家出厂合格证照片",
                                proj_link_type = 14
                            },
                            [3] = {
                                name = "铁塔图纸照片",
                                proj_link_type = 15
                            },
                            [4] = {

                                name = "基础回弹照片",
                                proj_link_type = 16
                            },
                            [5] = {
                                name = "整体完工（初验）照片",
                                proj_link_type = 17
                            }
                        }
                    },
                    [3] = {
                        name = "接电施工",
                        proj_module_code = "3",
                        sub = {
                            [1] = {
                                name = "接入点照片",
                                proj_link_type = 18
                            },
                            [2] = {
                                name = "电表及空开照片",
                                proj_link_type = 19
                            },
                            [3] = {
                                name = "线缆材质及埋深照片",
                                proj_link_type = 20
                            }
                        }
                    },
                    [4] = {
                        name = "配套安装",
                        proj_module_code = "4",
                        sub = {
                            [1] = {
                                name = "底座固定照片",
                                proj_link_type = 21
                            },
                            [2] = {
                                name = "机房柜布线照片",
                                proj_link_type = 22
                            },
                            [3] = {
                                name = "整体完工照片（初验）",
                                proj_link_type = 23
                            }
                        }
                    },
                    [5] = {
                        name = "竣工交维",
                        proj_module_code = "5",
                        sub = {
                            [1] = {
                                name = "竣工照片",
                                proj_link_type = 24
                            }
                        }
                    },
                    [6] = {
                        name = "交付验收",
                        proj_module_code = "10",
                        sub = {
                            [1] = {
                                name = "交付单",
                                proj_link_type = 34
                            },
                            [2] = {
                                name = "基站设备",
                                proj_link_type = 35
                            }
                        }
                        --fixed by zhangjieqiong for jiaofuyanshou 20200820
                    },
                    [7] = {
                        name = "拆站",
                        proj_module_code = "6",
                        sub = {
                            [1] = {
                                name = "拆站照片",
                                proj_link_type = 27
                            }
                        }
                    },
                    [8] = {
                        name = "安装电表",
                        proj_module_code = "7",
                        sub = {
                            [1] = {
                                name = "安装电表照片",
                                proj_link_type = 28
                            }
                        }
                    },
                    [9] = {
                        name = "并购",
                        proj_module_code = "8",
                        sub = {
                            [1] = {
                                name = "并购照片",
                                proj_link_type = 29
                            }
                        }
                    },
                    [10] = {
                        name = "改造",
                        proj_module_code = "9",
                        sub = {
                            [1] = {
                                name = "技术安全交底",
                                proj_link_type = 30
                            },
                            [2] = {
                                name = "材料验收",
                                proj_link_type = 31
                            },
                            [3] = {
                                name = "关键工序",
                                proj_link_type = 32
                            },
                            [4] = {
                                name = "完工整体照片",
                                proj_link_type = 33
                            }
                        }
                        --fixed by zhangjieqiong for gaizao 20200520
                    }
                }
            },
            [3] = {
                name = "楼面（植筋）",
                value = 2,
                sub = {
                    [1] = {
                        name = "土建施工",
                        proj_module_code = "1",
                        sub = {
                            [1] = {
                                name = "施工进场",
                                proj_link_type = 25
                            },
                            [2] = {
                                name = "植筋验收",
                                proj_link_type = 12
                            },
                            [3] = {
                                name = "预埋件验收",
                                proj_link_type = 7
                            },
                            [4] = {
                                name = "地网验收",
                                proj_link_type = 6
                            },
                            [5] = {
                                name = "整体验收",
                                proj_link_type = 26
                            }
                        }
                    },
                    [2] = {
                        name = "塔桅安装",
                        proj_module_code = "2",
                        sub = {
                            [1] = {
                                name = "特殊工种上岗证照片",
                                proj_link_type = 13
                            },
                            [2] = {
                                name = "铁塔厂家出厂合格证照片",
                                proj_link_type = 14
                            },
                            [3] = {
                                name = "铁塔图纸照片",
                                proj_link_type = 15
                            },
                            [4] = {

                                name = "基础回弹照片",
                                proj_link_type = 16
                            },
                            [5] = {
                                name = "整体完工（初验）照片",
                                proj_link_type = 17
                            }
                        }
                    },
                    [3] = {
                        name = "接电施工",
                        proj_module_code = "3",
                        sub = {
                            [1] = {
                                name = "接入点照片",
                                proj_link_type = 18
                            },
                            [2] = {
                                name = "电表及空开照片",
                                proj_link_type = 19
                            },
                            [3] = {
                                name = "线缆材质及埋深照片",
                                proj_link_type = 20
                            }
                        }
                    },
                    [4] = {
                        name = "配套安装",
                        proj_module_code = "4",
                        sub = {
                            [1] = {
                                name = "底座固定照片",
                                proj_link_type = 21
                            },
                            [2] = {
                                name = "机房柜布线照片",
                                proj_link_type = 22
                            },
                            [3] = {
                                name = "整体完工照片（初验）",
                                proj_link_type = 23
                            }
                        }
                    },
                    [5] = {
                        name = "竣工交维",
                        proj_module_code = "5",
                        sub = {
                            [1] = {
                                name = "竣工照片",
                                proj_link_type = 24
                            }
                        }
                    },
                    [6] = {
                        name = "交付验收",
                        proj_module_code = "10",
                        sub = {
                            [1] = {
                                name = "交付单",
                                proj_link_type = 34
                            },
                            [2] = {
                                name = "基站设备",
                                proj_link_type = 35
                            }
                        }
                        --fixed by zhangjieqiong for jiaofuyanshou 20200820
                    },
                    [7] = {
                        name = "拆站",
                        proj_module_code = "6",
                        sub = {
                            [1] = {
                                name = "拆站照片",
                                proj_link_type = 27
                            }
                        }
                    },
                    [8] = {
                        name = "安装电表",
                        proj_module_code = "7",
                        sub = {
                            [1] = {
                                name = "安装电表照片",
                                proj_link_type = 28
                            }
                        }
                    },
                    [9] = {
                        name = "并购",
                        proj_module_code = "8",
                        sub = {
                            [1] = {
                                name = "并购照片",
                                proj_link_type = 29
                            }
                        }
                    },
                    [10] = {
                        name = "改造",
                        proj_module_code = "9",
                        sub = {
                            [1] = {
                                name = "技术安全交底",
                                proj_link_type = 30
                            },
                            [2] = {
                                name = "材料验收",
                                proj_link_type = 31
                            },
                            [3] = {
                                name = "关键工序",
                                proj_link_type = 32
                            },
                            [4] = {
                                name = "完工整体照片",
                                proj_link_type = 33
                            }
                        }
                        --fixed by zhangjieqiong for gaizao 20200520
                    }
                }
            }
        }
    else
        allType = {
            [1] = {
                name = "落地",
                value = 0,
                sub = {
                    [1] = {
                        name = "地质勘探",
                        sub = {
                            [1] = "钻孔照片",
                            [2] = "取土样照片"
                        }
                    },
                    [2] = {
                        name = "土建施工",
                        sub = {
                            [1] = "施工进场",
                            [2] = {
                                name = "落地塔基",
                                sub = {
                                    [1] = "开挖验收",
                                    [2] = "材料验收",
                                    [3] = "钢筋验收",
                                    [4] = "浇筑验收",
                                    [5] = "地网验收",
                                    [6] = "预埋件验收"
                                }
                            },
                            [3] = {
                                name = "落地机房",
                                sub = {
                                    [1] = "基槽验收",
                                    [2] = "钢筋工序验收",
                                    [3] = "混凝土浇筑验收"
                                }
                            },
                            [4] = "整体验收"
                        }
                    },
                    [3] = {
                        name = "塔桅安装",
                        sub = {
                            [1] = "特殊工种上岗证照片",
                            [2] = "铁塔厂家出厂合格证照片",
                            [3] = "铁塔图纸照片",
                            [4] = "基础回弹照片",
                            [5] = "整体完工（初验）照片"
                        }
                    },
                    [4] = {
                        name = "接电施工",
                        sub = {
                            [1] = "接入点照片",
                            [2] = "电表及空开照片",
                            [3] = "线缆材质及埋深照片"
                        }
                    },
                    [5] = {
                        name = "配套安装",
                        sub = {
                            [1] = "底座固定照片",
                            [2] = "机房柜布线照片",
                            [3] = "整体完工照片（初验）"
                        }
                    },
                    [6] = {
                        name = "竣工交维",
                        sub = {
                            [1] = "竣工照片"
                        }
                    },
                    [7] = {
                        name = "交付验收",
                        sub = {
                            [1] = "交付单",
                            [2] = "基站设备"
                        }
                    },
                    [8] = {
                        name = "拆站",
                        sub = {
                            [1] = "拆站照片"
                        }
                    },
                    [9] = {
                        name = "安装电表",
                        sub = {
                            [1] = "安装电表照片"
                        }
                    },
                    [10] = {
                        name = "改造",
                        sub = {
                            [1] = "技术安全交底",
                            [2] = "材料验收",
                            [3] = "关键工序",
                            [4] = "完工整体照片"
                        }
                        --fixed by zhangjieqiong for gaizao 20200520
                    }
                }
            },
            [2] = {
                name = "楼面（普通）",
                value = 1,
                sub = {
                    [1] = {
                        name = "土建施工",
                        sub = {
                            [1] = "施工进场",
                            [2] = "基础尺寸",
                            [3] = "地网验收",
                            [4] = "整体验收"
                        }
                    },
                    [2] = {
                        name = "塔桅安装",
                        sub = {
                            [1] = "特殊工种上岗证照片",
                            [2] = "铁塔厂家出厂合格证照片",
                            [3] = "铁塔图纸照片",
                            [4] = "基础回弹照片",
                            [5] = "整体完工（初验）照片"
                        }
                    },
                    [3] = {
                        name = "接电施工",
                        sub = {
                            [1] = "接入点照片",
                            [2] = "电表及空开照片",
                            [3] = "线缆材质及埋深照片"
                        }
                    },
                    [4] = {
                        name = "配套安装",
                        sub = {
                            [1] = "底座固定照片",
                            [2] = "机房柜布线照片",
                            [3] = "整体完工照片（初验）"
                        }
                    },
                    [5] = {
                        name = "竣工交维",
                        sub = {
                            [1] = "竣工照片"
                        }
                    },
                    [6] = {
                        name = "交付验收",
                        sub = {
                            [1] = "交付单",
                            [2] = "基站设备"
                        }
                    },
                    [7] = {
                        name = "拆站",
                        sub = {
                            [1] = "拆站照片"
                        }
                    },
                    [8] = {
                        name = "安装电表",
                        sub = {
                            [1] = "安装电表照片"
                        }
                    },
                    [9] = {
                        name = "改造",
                        sub = {
                            [1] = "技术安全交底",
                            [2] = "材料验收",
                            [3] = "关键工序",
                            [4] = "完工整体照片"
                        }
                        --fixed by zhangjieqiong for gaizao 20200520
                    }
                }
            },
            [3] = {
                name = "楼面（植筋）",
                value = 2,
                sub = {
                    [1] = {
                        name = "土建施工",
                        sub = {
                            [1] = "施工进场",
                            [2] = "植筋验收",
                            [3] = "预埋件验收",
                            [4] = "地网验收",
                            [4] = "整体验收"
                        }
                    },
                    [2] = {
                        name = "塔桅安装",
                        sub = {
                            [1] = "特殊工种上岗证照片",
                            [2] = "铁塔厂家出厂合格证照片",
                            [3] = "铁塔图纸照片",
                            [4] = "基础回弹照片",
                            [5] = "整体完工（初验）照片"
                        }
                    },
                    [3] = {
                        name = "接电施工",
                        sub = {
                            [1] = "接入点照片",
                            [2] = "电表及空开照片",
                            [3] = "线缆材质及埋深照片"
                        }
                    },
                    [4] = {
                        name = "配套安装",
                        sub = {
                            [1] = "底座固定照片",
                            [2] = "机房柜布线照片",
                            [3] = "整体完工照片（初验）"
                        }
                    },
                    [5] = {
                        name = "竣工交维",
                        sub = {
                            [1] = "竣工照片"
                        }
                    },
                    [6] = {
                        name = "交付验收",
                        sub = {
                            [1] = "交付单",
                            [2] = "基站设备"
                        }
                    },
                    [7] = {
                        name = "拆站",
                        sub = {
                            [1] = "拆站照片"
                        }
                    },
                    [8] = {
                        name = "安装电表",
                        sub = {
                            [1] = "安装电表照片"
                        }
                    },
                    [9] = {
                        name = "改造",
                        sub = {
                            [1] = "技术安全交底",
                            [2] = "材料验收",
                            [3] = "关键工序",
                            [4] = "完工整体照片"
                        }
                        --fixed by zhangjieqiong for gaizao 20200520
                    }
                }
            }
        }
    end
    return allType
end

function _M.projectLinkData_put(t, data)
    for k, v in pairs(t) do
        if (type(v) == "table") then
            _M.projectLinkData_put(v, data)
        elseif k == "proj_link_type" then
            for datak, datav in pairs(data) do
                if type(datav) == "table" and datav["proj_link_type"] == v then
                    for datasubk, datasubv in pairs(datav) do
                        t[datasubk] = datasubv
                    end
                    return t
                end
            end
        end
    end
    return t
end

function _M.projectAllType_set(name, value, detail)
    local sql = " insert into  tb_proj_type(proj_type_name,proj_type_value,proj_type_detail) values('" .. name .. "', " .. tostring(value) .. ", '" .. detail .. "' ) "

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end
--
--[{"pic":"url","time":1728182781,"location":{"lat":"31.2323","lon":"121.232","alt":"121","addr":"上海"},"dev_info":"miUI","user":"13764267435"}...]
--
--
function _M.linkPic_check(pic)
    local picUrl = pic["pic"]
    if type(picUrl) ~= "string" or string.len(comm_func.trim_string(picUrl)) < 3 then
        return false, "pic必须是string类型"
    end
    if type(pic["time"]) ~= "number" then
        return false, "time必须是整形"
    end
    if type(pic["location"]) ~= "table" or pic["location"]["lat"] == nil or pic["location"]["lon"] == nil then
        return false, "location格式错误"
    end
    if type(pic["dev_info"]) ~= "string" then
        return false, "dev_info必须是string类型"
    end
    if type(pic["user_name"]) ~= "string" then
        return false, "user_name必须是string类型"
    end
    if type(pic["user_code"]) ~= "string" then
        return false, "user_code必须是string类型"
    end
    if type(pic["user_id"]) ~= "number" then
        return false, "user_id必须是整形"
    end
end

function _M.link_check(link)
    if type(link) ~= "table" then
        return false, "必须是JSON格式"
    end
    if type(link["proj_link_submit_user_name"]) ~= "string" then
        return false, "proj_link_submit_user_name必须是string类型"
    end
    if type(link["proj_link_submit_user_code"]) ~= "string" then
        return false, "proj_link_submit_user_code必须是string类型"
    end
    if type(link["proj_link_submit_user_id"]) ~= "number" then
        return false, "proj_link_submit_user_id必须是整形"
    end
    if type(link["proj_link_describe"]) ~= "string" then
        return false, "proj_link_describe必须是string类型"
    end
    if link["proj_link_submit_nw_type"] ~= nil then
        if link["proj_link_submit_nw_type"] ~= 0 and link["proj_link_submit_nw_type"] ~= 1 then
            return false, "proj_link_submit_nw_type必须是整形"
        end
    else
        link["proj_link_submit_nw_type"] = 0
    end
    if type(link["proj_link_pic"]) ~= "table" or #link["proj_link_pic"] < 1 then
        return false, "proj_link_pic必须是JSON格式"
    end
    local picHave = false
    for idk, idv in pairs(link["proj_link_pic"]) do
        local picCheckResult, msg = _M.linkPic_check(idv)
        if picCheckResult == false then
            return false, msg
        end
        picHave = true
    end
    if picHave == false then
        return false, "至少要有一张照片"
    end
    return true
end

function _M.linkReview_check(link)
    if type(link) ~= "table" then
        return false, "必须是JSON格式"
    end
    if type(link["proj_link_reviewer_name"]) ~= "string" then
        return false, "proj_link_reviewer_name必须是string类型"
    end
    if type(link["proj_link_reviewer_code"]) ~= "string" then
        return false, "proj_link_reviewer_code必须是string类型"
    end
    if type(link["proj_link_reviewer_id"]) ~= "number" then
        return false, "proj_link_reviewer_id必须是整形"
    end
    if type(link["proj_link_review_describe"]) ~= "string" then
        return false, "proj_link_review_describe必须是string类型"
    end
    if type(link["proj_link_status"]) ~= "number" then
        return false, "proj_link_status必须整形"
    end
    if link["proj_link_status"] ~= 2 and link["proj_link_status"] ~= 3 and link["proj_link_status"] ~= 5 then
        return false, "proj_link_status必须为2或者3或5"
    end
    if link["proj_link_review_charge"] ~= nil and link["proj_link_review_charge"] ~= 0 and link["proj_link_review_charge"] ~= 1 then
        return false, "proj_link_review_charge必须为number"
    end
    if link["proj_link_review_charge"] ~= nil then
        if link["proj_link_review_charge"] == 1 and (link["proj_link_status"] == 3 or link["proj_link_status"] == 5) then
            if link["proj_link_status"] == 3 then
                link["proj_link_status"] = 7
            else
                link["proj_link_status"] = 8
            end
        end
    end
    return true
end

function _M.projectLink_get(proj_code)
    local sql = " select * from tb_proj_link where proj_code= '" .. tostring(proj_code) .. "' order by proj_link_type asc "

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end
function _M.projectLinkRecodNum_get(proj_code)
    local sql = " select proj_link_id,count(proj_link_id) from tb_proj_link_recod where proj_code= '" .. tostring(proj_code) .. "' group by proj_link_id  "

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()
    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.projectLinkUnPassedRecodNum_get(proj_code)
    local sql = " select proj_link_id,count(proj_link_id) from tb_proj_link_recod where proj_code= '" .. tostring(proj_code) .. "' and proj_link_status = 2 group by proj_link_id  "

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.projectLink_submit(links, proj_code, linksTab)
    local innerTab = {}
    local innerTabIndex = 1
    local notTime = math.ceil(ngx.now())
    innerTab[1] = "CREATE OR REPLACE FUNCTION fun_links_update() returns text AS $BODY$"
    innerTab[2] = "BEGIN"
    innerTabIndex = 3
    local updateCount = 0
    local latestLinkId
    for k, v in pairs(links) do
        local proj_link_pic = cjson.encode(v["proj_link_pic"])
        latestLinkId = tostring(v["proj_link_id"])
        --if linksTab[latestLinkId]["proj_link_status"] == 2 or ( linksTab[latestLinkId]["proj_link_pic_add_number"] ~= nil  and  linksTab[latestLinkId]["proj_link_pic_add_number"] > 0) then
        if (linksTab[latestLinkId]["proj_link_pic_add_number"] ~= nil and linksTab[latestLinkId]["proj_link_pic_add_number"] > 0) then
            local copyStr1 = "insert into tb_proj_link_recod(proj_link_id,proj_name,proj_type_name ,proj_module_name ,proj_link_name  ,proj_link_type  ,"
            local copyStr2 = "proj_link_submit_time ,proj_link_submit_user_code ,proj_link_review_time ,proj_link_reviewer_code ,"
            local copyStr3 = "proj_link_review_describe , proj_link_pic,proj_link_status, proj_link_describe ,proj_code  ,proj_link_submit_user_name, "
            local copyStr4 = "proj_link_submit_user_id, proj_link_reviewer_name, proj_link_reviewer_id ,proj_bu_code , proj_company_code,proj_link_pic_max_num,proj_link_sync_time,proj_link_submit_nw_type,proj_link_fine_value,proj_link_fine_detail_id,proj_link_pic_add_number  )    "
            local copyStr5 = "select proj_link_id,proj_name,proj_type_name ,proj_module_name ,proj_link_name  ,proj_link_type  ,proj_link_submit_time ,proj_link_submit_user_code ,"
            local copyStr6 = " proj_link_review_time ,proj_link_reviewer_code , "
            local copyStr7 = "proj_link_review_describe , proj_link_pic,proj_link_status, proj_link_describe ,proj_code  ,proj_link_submit_user_name, "
            local copyStr8 = "proj_link_submit_user_id, proj_link_reviewer_name, proj_link_reviewer_id ,proj_bu_code , proj_company_code ,proj_link_pic_max_num,proj_link_sync_time,proj_link_submit_nw_type,proj_link_fine_value,proj_link_fine_detail_id,proj_link_pic_add_number "
            local copyStr9 = string.format("  from tb_proj_link where proj_link_id=%d; ", v["proj_link_id"])

            innerTab[innerTabIndex] = string.format("%s %s %s %s %s %s %s %s %s  ", copyStr1, copyStr2, copyStr3, copyStr4, copyStr5, copyStr6, copyStr7, copyStr8, copyStr9);
            innerTabIndex = innerTabIndex + 1
            if linksTab[latestLinkId]["proj_link_pic_add_number"] ~= nil and linksTab[latestLinkId]["proj_link_pic_add_number"] > 0 then
                local newPicJson = linksTab[latestLinkId]["proj_link_pic"]
                for ok, ov in pairs(v["proj_link_pic"]) do
                    newPicJson[#newPicJson + 1] = v["proj_link_pic"][ok]
                end
                for ok, ov in pairs(newPicJson) do
                    newPicJson[ok]["is_add_pic"] = 1
                end
                proj_link_pic = cjson.encode(newPicJson)
            end
        end
        local temp_proj_link_describe = comm_func.sql_singleQuotationMarks(v["proj_link_describe"])
        innerTab[innerTabIndex] = string.format("update tb_proj_link set proj_link_submit_user_name='%s',proj_link_submit_user_code='%s',proj_link_submit_user_id=%d,proj_link_describe='%s',proj_link_status=1,proj_link_submit_time=%d,proj_link_pic='%s',proj_link_submit_nw_type=%d,proj_link_pic_add_number=0, proj_link_review_describe  ='' where proj_link_id=%d  ; ", v["proj_link_submit_user_name"], v["proj_link_submit_user_code"], v["proj_link_submit_user_id"], temp_proj_link_describe, notTime, proj_link_pic, v["proj_link_submit_nw_type"], v["proj_link_id"])
        innerTabIndex = innerTabIndex + 1
        updateCount = updateCount + 1

    end
    innerTab[innerTabIndex] = string.format("update tb_proj set proj_status = 1,proj_submit_time=%d,proj_link_name_ls='%s',proj_module_name_ls='%s',proj_link_id_ls=%s where proj_code='%s'  ;", notTime, linksTab[latestLinkId]["proj_link_name"], linksTab[latestLinkId]["proj_module_name"], latestLinkId, proj_code)
    innerTabIndex = innerTabIndex + 1
    innerTab[innerTabIndex] = string.format("RETURN %d;", updateCount)
    innerTab[innerTabIndex + 1] = "END;"
    innerTab[innerTabIndex + 2] = "$BODY$"
    innerTab[innerTabIndex + 3] = "language plpgsql;"

    local processCall = " select fun_links_update();"
    local processSql = table.concat(innerTab, " ")
    return _M.excute_db_process(processSql, processCall)
end

function _M.projectLink_review(links, proj_code)
    local innerTab = {}
    local innerTabIndex = 1
    local notTime = math.ceil(ngx.now())
    innerTab[1] = "CREATE OR REPLACE FUNCTION fun_links_review() returns text AS $BODY$   DECLARE  temp_count bigint; temp_curs1 refcursor;"
    innerTab[2] = "BEGIN"
    innerTabIndex = 3
    local updateCount = 0
    --ggg
    local l_proj_module_is_demolition = 0
    for k, v in pairs(links) do
        local temp_proj_link_review_describe = comm_func.sql_singleQuotationMarks(v["proj_link_review_describe"])
        innerTab[innerTabIndex] = string.format("update tb_proj_link set proj_link_review_describe='%s',proj_link_reviewer_name='%s',proj_link_reviewer_id=%d,proj_link_reviewer_code='%s',proj_link_status=%d,proj_link_review_time=%d where proj_link_id=%d  ; ", temp_proj_link_review_describe, v["proj_link_reviewer_name"], v["proj_link_reviewer_id"], v["proj_link_reviewer_code"], v["proj_link_status"], notTime, v["proj_link_id"])
        innerTabIndex = innerTabIndex + 1
        if v["proj_link_status"] == 2 then
            local copyStr1 = "insert into tb_proj_link_recod(proj_link_id,proj_name,proj_type_name ,proj_module_name ,proj_link_name  ,proj_link_type  ,"
            local copyStr2 = "proj_link_submit_time ,proj_link_submit_user_code ,proj_link_review_time ,proj_link_reviewer_code ,"
            local copyStr3 = "proj_link_review_describe , proj_link_pic,proj_link_status, proj_link_describe ,proj_code  ,proj_link_submit_user_name, "
            local copyStr4 = "proj_link_submit_user_id, proj_link_reviewer_name, proj_link_reviewer_id ,proj_bu_code , proj_company_code,proj_link_pic_max_num,proj_link_sync_time,proj_link_submit_nw_type,proj_link_fine_value,proj_link_fine_detail_id,proj_link_pic_add_number  )    "
            local copyStr5 = "select proj_link_id,proj_name,proj_type_name ,proj_module_name ,proj_link_name  ,proj_link_type  ,proj_link_submit_time ,proj_link_submit_user_code ,"
            local copyStr6 = " proj_link_review_time ,proj_link_reviewer_code , "
            local copyStr7 = "proj_link_review_describe , proj_link_pic,proj_link_status, proj_link_describe ,proj_code  ,proj_link_submit_user_name, "
            local copyStr8 = "proj_link_submit_user_id, proj_link_reviewer_name, proj_link_reviewer_id ,proj_bu_code , proj_company_code ,proj_link_pic_max_num,proj_link_sync_time,proj_link_submit_nw_type,proj_link_fine_value,proj_link_fine_detail_id,proj_link_pic_add_number "
            local copyStr9 = string.format("  from tb_proj_link where proj_link_id=%d; ", v["proj_link_id"])

            innerTab[innerTabIndex] = string.format("%s %s %s %s %s %s %s %s %s  ", copyStr1, copyStr2, copyStr3, copyStr4, copyStr5, copyStr6, copyStr7, copyStr8, copyStr9);
            innerTabIndex = innerTabIndex + 1
        end
        --ggg
        if type(v["proj_module_is_demolition"]) == "number" and v["proj_module_is_demolition"] == 1 then
            l_proj_module_is_demolition = 1
        end
        updateCount = updateCount + 1
    end
    if l_proj_module_is_demolition == 1 then
        innerTab[innerTabIndex] = string.format(" OPEN temp_curs1 FOR select count(*) from tb_proj_link where proj_code='%s' and proj_link_type=27 and (proj_link_status=0 or proj_link_status=1 or proj_link_status=2); ", proj_code)
    else
        innerTab[innerTabIndex] = string.format(" OPEN temp_curs1 FOR select count(*) from tb_proj_link where proj_code='%s' and (proj_link_status=0 or proj_link_status=1 or proj_link_status=2); ", proj_code)
    end
    innerTabIndex = innerTabIndex + 1
    innerTab[innerTabIndex] = string.format(" FETCH temp_curs1 INTO temp_count;  CLOSE temp_curs1; ")

    innerTabIndex = innerTabIndex + 1
    innerTab[innerTabIndex] = string.format("  if temp_count < 1 then ")
    comm_func.do_dump_value(request_time, 0)
    innerTabIndex = innerTabIndex + 1
    if l_proj_module_is_demolition == 1 then
        comm_func.do_dump_value("------ggg---proj_module_is_demolition:1", 0)
        innerTab[innerTabIndex] = string.format("update tb_proj set proj_status = 4 where proj_code='%s'  ;", proj_code)
    else
        comm_func.do_dump_value("------ggg---proj_module_is_demolition:0 or nil", 0)
        innerTab[innerTabIndex] = string.format("update tb_proj set proj_status = 3 where proj_code='%s' and proj_status != 4 ;", proj_code)
    end
    innerTabIndex = innerTabIndex + 1
    innerTab[innerTabIndex] = string.format("  end if; ")

    innerTabIndex = innerTabIndex + 1
    innerTab[innerTabIndex] = string.format("RETURN %d;", updateCount)
    innerTab[innerTabIndex + 1] = "END;"
    innerTab[innerTabIndex + 2] = "$BODY$"
    innerTab[innerTabIndex + 3] = "language plpgsql;"

    local processCall = " select fun_links_review();"
    local processSql = table.concat(innerTab, " ")
    local status, apps = _M.excute_db_process(processSql, processCall)
    return status, apps
end

--add by zhangjieqiong 20200523 reset review status
function _M.projectLink_review_reset(proj_link_id, proj_code, user_id, user_name, reset_reason)
    local sql = " Update tb_proj_link set proj_link_status = 1 "
    sql = sql .. " where proj_code = '" .. proj_code .. "' and proj_link_id = " .. proj_link_id

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local res2, apps = _M.projectLink_review_reset_save(proj_link_id, proj_code, user_id, user_name, reset_reason)
        if res2 ~= nil then
            return true, res2
        else
            return false, res2
        end
    else
        return false, res
    end
end
--add by zhangjieqiong 20200805 insert reset list
function _M.projectLink_review_reset_save(proj_link_id, proj_code, user_id, user_name, reset_reason)
    local sql = " insert into tb_proj_link_reset (proj_code,user_id,user_name,proj_link_id,reset_time,reset_reason)"
    sql = sql .. "values('" .. proj_code .. "'," .. user_id .. ",'" .. user_name .. "'," .. proj_link_id .. ",CURRENT_TIMESTAMP,'" .. reset_reason .. "')"

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

--add by zhangjieqiong 20200811 select reset list
function _M.projectLink_review_reset_list_get(proj_link_id, proj_code)
    local sql = "select * from tb_proj_link_reset "
    sql = sql .. " where proj_code = '" .. proj_code .. "' and proj_link_id = " .. proj_link_id

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

--add by zhangjieqiong 20200806 select 整体完工初验状态
function _M.projectLink_submit_select_link_status(proj_code, proj_link_type)
    local sql = "select * from tb_proj_link where proj_code= '" .. tostring(proj_code) .. "' and proj_link_type='" .. tostring(proj_link_type) .. "'"
    comm_func.do_dump_value(sql, 0)
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.excute_db_process(porcessSql, processCall)
    local sql = porcessSql

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        if res == true then
            pg = _M.get_new_pgmoon_connection()
            assert(pg:connect())
            res = assert(pg:query(processCall))
            pg:keepalive()

            if res ~= nil then
                return true, res
            end

            return false, res
        end
        return false, res
    else
        return false, res
    end

end

function _M.projectLink_gen(proj_code, proj_type_value, proj_bu_code, proj_company_code)
    local proj_name
    local sql = " select * from tb_proj where proj_code='" .. tostring(proj_code) .. "' "

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    local linkStructure = db_query.projectAllType_get(true)
    local proj_linksStr = linkStructure[proj_type_value + 1]["sub"]
    proj_linksStr = cjson.encode(proj_linksStr)
    if res ~= nil then
        if res[1] ~= nil then
            proj_name = res[1]["proj_name"]
            local processSql
            if proj_type_value == 0 then
                local innerTab = {}
                innerTab[1] = "CREATE OR REPLACE FUNCTION fun_link_default_gen() returns text AS $BODY$"
                innerTab[2] = "BEGIN"
                innerTab[3] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','地质勘探','钻孔照片',0,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[4] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','地质勘探','取土样照片',1,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[5] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','开挖验收',2,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[6] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','材料验收',3,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[7] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','钢筋验收',4,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[8] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','浇筑验收',5,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[9] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','地网验收',6,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[10] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','预埋件验收',7,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[11] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values('%s','%s','落地','土建施工','基槽验收',8,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[12] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','钢筋工序验收',9,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[13] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','混凝土浇筑验收',10,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[14] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','特殊工种上岗证照片',13,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[15] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','铁塔厂家出厂合格证照片',14,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[16] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','铁塔图纸照片',15,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[17] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','基础回弹照片',16,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[18] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','整体完工（初验）照片',17,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[19] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','接电施工','接入点照片',18,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[20] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','接电施工','电表及空开照片',19,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[21] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','接电施工','线缆材质及埋深照片',20,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[22] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','配套安装','底座固定照片',21,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[23] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','配套安装','机房柜布线照片',22,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[24] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','配套安装','整体完工照片（初验）',23,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[25] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','竣工交维','竣工照片',24,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[26] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','施工进场',25,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[27] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','整体验收',26,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[28] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','拆站','拆站照片',27,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[29] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','安装电表','安装电表照片',28,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[30] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','并购','并购照片',29,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[31] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','改造','技术安全交底',30,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[32] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','改造','材料验收',31,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[33] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','改造','关键工序',32,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[34] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','改造','完工整体照片',33,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[35] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','交付验收','交付单',34,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[36] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','交付验收','基站照片',35,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[37] = string.format(" update tb_proj set proj_links='%s' where proj_code='%s'; ", proj_linksStr, proj_code)
                innerTab[38] = "RETURN 35;"
                innerTab[39] = "END;"
                innerTab[40] = "$BODY$"
                innerTab[41] = "language plpgsql;"
                processSql = table.concat(innerTab, " ")
                --comm_func.do_dump_value("------zhangjieqiong----03--processSql:",processSql)
                --fixed by zhangjieqiong for gaizao 20200520
            elseif proj_type_value == 1 then
                local innerTab = {}
                innerTab[1] = "CREATE OR REPLACE FUNCTION fun_link_default_gen() returns text AS $BODY$"
                innerTab[2] = "BEGIN"
                innerTab[3] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','土建施工','基础尺寸',11,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[4] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','土建施工','地网验收',6,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[5] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','塔桅安装','特殊工种上岗证照片',13,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[6] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','塔桅安装','铁塔厂家出厂合格证照片',14,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[7] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','塔桅安装','铁塔图纸照片',15,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[8] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','塔桅安装','基础回弹照片',16,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[9] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','塔桅安装','整体完工（初验）照片',17,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[10] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','接电施工','接入点照片',18,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[11] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','接电施工','电表及空开照片',19,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[12] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','接电施工','线缆材质及埋深照片',20,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[13] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values('%s','%s','楼面（普通）','配套安装','底座固定照片',21,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[14] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','配套安装','机房柜布线照片',22,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[15] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','配套安装','整体完工照片（初验）',23,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[16] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','竣工交维','竣工照片',24,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[17] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','土建施工','施工进场',25,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[18] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','土建施工','整体验收',26,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[19] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','拆站','拆站照片',27,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[20] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','安装电表','安装电表照片',28,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[21] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','并购','并购照片',29,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[22] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','改造','技术安全交底',30,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[23] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','改造','材料验收',31,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[24] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','改造','关键工序',32,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[25] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','改造','完工整体照片',33,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[26] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','交付验收','交付单',34,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[27] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','交付验收','基站照片',35,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[28] = string.format(" update tb_proj set proj_links='%s' where proj_code='%s'; ", proj_linksStr, proj_code)
                innerTab[29] = "RETURN 25;"
                innerTab[30] = "END;"
                innerTab[31] = "$BODY$"
                innerTab[32] = "language plpgsql;"
                processSql = table.concat(innerTab, " ")
                --comm_func.do_dump_value("------zhangjieqiong----03--processSql:",processSql)
                --fixed by zhangjieqiong for gaizao 20200520
            elseif proj_type_value == 2 then
                local innerTab = {}
                innerTab[1] = "CREATE OR REPLACE FUNCTION fun_link_default_gen() returns text AS $BODY$"
                innerTab[2] = "BEGIN"
                innerTab[3] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','土建施工','植筋验收',12,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[4] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','土建施工','预埋件验收',7,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[5] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','土建施工','地网验收',6,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[6] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','塔桅安装','特殊工种上岗证照片',13,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[7] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','塔桅安装','铁塔厂家出厂合格证照片',14,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[8] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','塔桅安装','铁塔图纸照片',15,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[9] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','塔桅安装','基础回弹照片',16,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[10] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','塔桅安装','整体完工（初验）照片',17,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[11] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','接电施工','接入点照片',18,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[12] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','接电施工','电表及空开照片',19,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[13] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','接电施工','线缆材质及埋深照片',20,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[14] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values('%s','%s','楼面（植筋）','配套安装','底座固定照片',21,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[15] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','配套安装','机房柜布线照片',22,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[16] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','配套安装','整体完工照片（初验）',23,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[17] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','竣工交维','竣工照片',24,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[18] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','土建施工','施工进场',25,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[19] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','土建施工','整体验收',26,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[20] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','拆站','拆站照片',27,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[21] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','安装电表','安装电表照片',28,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[22] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','并购','并购照片',29,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[23] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','改造','技术安全交底',30,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[24] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','改造','材料验收',31,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[25] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','改造','关键工序',32,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[26] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','改造','完工整体照片',33,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[27] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','交付验收','交付单',34,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[28] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','交付验收','基站照片',35,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[29] = string.format(" update tb_proj set proj_links='%s' where proj_code='%s'; ", proj_linksStr, proj_code)
                innerTab[30] = "RETURN 27;"
                innerTab[31] = "END;"
                innerTab[32] = "$BODY$"
                innerTab[33] = "language plpgsql;"
                processSql = table.concat(innerTab, " ")
                --comm_func.do_dump_value("------zhangjieqiong----03--processSql:",processSql)
                --fixed by zhangjieqiong for gaizao 20200520
            end
            local processCall = " select fun_link_default_gen();"
            return _M.excute_db_process(processSql, processCall)
        else
            return false, res
        end
    end
    return false, res
end

function _M.projectLinkList_get(proj_code, proj_name, proj_bu_code, proj_company_code, proj_link_status, proj_link_name, proj_module_name, fuzzy_searche_key, isAdmin, limit, offset)
    local whereStr = ""
    local whereFuzzyStr = ""
    local whereTab = {}
    local whereFuzzyTab = {}

    local limitStr = " limit " .. tostring(limit) .. " offset " .. tostring(offset)
    local totalSql = " select count(*) as total from tb_proj_link "

    if proj_code ~= nil then
        table.insert(whereTab, string.format(" proj_code like '%%%s%%'  ", proj_code))
    elseif fuzzy_searche_key ~= nil then
        table.insert(whereFuzzyTab, string.format(" proj_code like '%%%s%%'  ", fuzzy_searche_key))
    end
    if proj_name ~= nil and proj_name ~= "" then
        table.insert(whereTab, string.format(" proj_name like '%%%s%%'  ", proj_name))
    elseif fuzzy_searche_key ~= nil then
        table.insert(whereFuzzyTab, string.format(" proj_name like '%%%s%%'  ", fuzzy_searche_key))
    end

    if proj_bu_code ~= nil and proj_bu_code ~= "" then
        local userBuTab = comm_func.split_string(proj_bu_code, ",")
        if string.len(proj_bu_code) == 2 then
            table.insert(whereTab, string.format(" proj_bu_code like '%s%%'  ", proj_bu_code))
        elseif #userBuTab > 1 then
            local whereBuTab = {}
            for buk, buv in pairs(userBuTab) do
                table.insert(whereBuTab, string.format(" '%s' ", buv))
            end
            local whereBuTabStr = table.concat(whereBuTab, " , ")
            table.insert(whereTab, string.format(" proj_bu_code in ( %s )  ", whereBuTabStr))
        else
            table.insert(whereTab, string.format(" proj_bu_code='%s'  ", proj_bu_code))
        end
    end

    if proj_company_code ~= nil and proj_company_code ~= "" then
        table.insert(whereTab, string.format(" proj_company_code='%s'  ", proj_company_code))
    end

    if proj_link_status ~= nil then
        if proj_link_status == 7 or proj_link_status == 8 then
            table.insert(whereTab, string.format(" proj_link_status in (%d,%d)  ", 7, 8))
        else
            table.insert(whereTab, string.format(" proj_link_status=%d  ", proj_link_status))
        end
    end

    if proj_link_name ~= nil then
        table.insert(whereTab, string.format(" proj_link_name like '%%%s%%'  ", proj_link_name))
    elseif fuzzy_searche_key ~= nil then
        table.insert(whereFuzzyTab, string.format(" proj_link_name like '%%%s%%'  ", fuzzy_searche_key))
    end

    if proj_module_name ~= nil and proj_module_name ~= "" then
        table.insert(whereTab, string.format(" proj_module_name like '%%%s%%'  ", proj_module_name))
    end

    whereStr = table.concat(whereTab, " and ")
    whereFuzzyStr = table.concat(whereFuzzyTab, " or ")

    local sql = " select * from tb_proj_link "
    if string.len(whereStr) > 3 then
        if string.len(whereFuzzyStr) > 3 then
            whereStr = string.format(" %s and ( %s ) ", whereStr, whereFuzzyStr)
        end
        sql = sql .. " where " .. whereStr
        totalSql = totalSql .. " where " .. whereStr
    elseif string.len(whereFuzzyStr) > 3 then
        sql = sql .. " where " .. whereFuzzyStr
        totalSql = totalSql .. " where " .. whereFuzzyStr
    end

    sql = sql .. " order by proj_link_submit_time desc " .. limitStr
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(totalSql)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false, res
    end
end

function _M.projectLinkRecodList_get(proj_code, proj_name, proj_bu_code, proj_company_code, proj_link_id, proj_link_name, proj_module_name, isAdmin, limit, offset)
    local whereStr = ""
    local whereTab = {}

    local limitStr = " limit " .. tostring(limit) .. " offset " .. tostring(offset)
    local totalSql = " select count(*) as total from tb_proj_link_recod "

    if proj_code ~= nil then
        table.insert(whereTab, string.format(" proj_code like '%%%s%%'  ", proj_code))
    end
    if proj_name ~= nil and proj_name ~= "" then
        table.insert(whereTab, string.format(" proj_name like '%%%s%%'  ", proj_name))
    end

    if proj_bu_code ~= nil and proj_bu_code ~= "" then
        if string.len(proj_bu_code) == 2 then
            table.insert(whereTab, string.format(" proj_bu_code like '%s%%'  ", proj_bu_code))
        else
            table.insert(whereTab, string.format(" proj_bu_code='%s'  ", proj_bu_code))
        end
    end

    if proj_company_code ~= nil and proj_company_code ~= "" then
        table.insert(whereTab, string.format(" proj_company_code='%s'  ", proj_company_code))
    end

    if proj_link_id ~= nil then
        table.insert(whereTab, string.format(" proj_link_id=%d  ", proj_link_id))
    end

    if proj_link_name ~= nil then
        table.insert(whereTab, string.format(" proj_link_name like '%%%s%%'  ", proj_link_name))
    end

    if proj_module_name ~= nil and proj_module_name ~= "" then
        table.insert(whereTab, string.format(" proj_module_name like '%%%s%%'  ", proj_module_name))
    end

    whereStr = table.concat(whereTab, " and ")

    local sql = " select * from tb_proj_link_recod "
    if string.len(whereStr) > 3 then
        sql = sql .. " where " .. whereStr
        totalSql = totalSql .. " where " .. whereStr
    end

    sql = sql .. " order by proj_link_submit_time desc " .. limitStr
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(totalSql)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false, res
    end
end

function _M.userOperationLog_add(user_nameT, requestNgx)
    local user_id = 0
    local user_name = user_nameT
    local ip_addr = ""
    local api_name = ""
    local api = ""
    local dev_info = ""
    local dev_type = ""
    local dev_model = ""
    local dev_version = ""
    local dev_app_version = ""
    local time = math.ceil(ngx.now())
    local save_time = time - 15552000

    --if true then
    --	return
    --end
    --comm_func.do_dump_value(requestNgx,0)
    local headers = ngx.req.get_headers()
    if ngx.var.uri ~= "/api/user_login" then
        user_id = headers["user-id"]
        local status, apps = _M.userFromId_get(user_id);
        if status == true and apps ~= nil and apps[1] ~= nil then
            user_name = apps[1]["user_name"]
        end
    end
    ip_addr = comm_func.get_client_ip(requestNgx)
    api = ngx.var.uri
    api_name = comm_func.api_name_get(api)
    if api_name == nil then
        api_name = ""
    end
    dev_info = headers["user-agent"]
    dev_type = headers["dev-request-type"]
    if headers["dev-model"] ~= nil then
        dev_model = headers["dev-model"]
    end
    if headers["dev-version"] ~= nil then
        dev_version = headers["dev-version"]
    end
    if headers["dev-app-version"] ~= nil then
        dev_app_version = headers["dev-app-version"]
    end

    local sql = string.format(" select fun_operation_log_add(%d,'%s','%s','%s','%s','%s','%s','%s','%s','%s',%d,%d) ", user_id, user_name, ip_addr, api, api_name, dev_info, dev_type, dev_model, dev_version, dev_app_version, time, save_time)

    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.userOperationLogList_get(isAdmin, user_id, user_name, api, api_name, fuzzy_searche_key, limit, offset)
    local sqlWhereTab = {}
    local sqlWhereFuzzyTab = {}
    local sqlWhereTabIndex = 1
    local sqlStr
    local sqlFuzzyStr = ""
    local sqlTotal

    sqlStr = " select * from tb_user_operation_log  "
    sqlTotal = " select count(*) as total from tb_user_operation_log "

    sqlWhereTab[sqlWhereTabIndex] = string.format("  where 1=1 ")
    sqlWhereTabIndex = sqlWhereTabIndex + 1

    if user_id ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_id=%d ", user_id)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if user_name ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and user_name  like '%%%s%%' ", user_name)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" user_name like '%%%s%%' ", fuzzy_searche_key))
    end
    if api ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and api  like '%%%s%%' ", api)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" api like '%%%s%%' ", fuzzy_searche_key))
    end
    if api_name ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and api_name  like '%%%s%%' ", api_name)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" api_name like '%%%s%%' ", fuzzy_searche_key))
    end

    local sqlWhereStr = table.concat(sqlWhereTab, " ")
    local sqlWhereFuzzyStr = table.concat(sqlWhereFuzzyTab, " or ")

    if string.len(sqlWhereFuzzyStr) > 3 then
        sqlWhereStr = string.format(" %s and ( %s ) ", sqlWhereStr, sqlWhereFuzzyStr)
        sqlWhereTab[sqlWhereTabIndex] = string.format(" and ( %s  ) ", sqlWhereFuzzyStr)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    sqlTotal = string.format(" %s %s ", sqlTotal, sqlWhereStr)

    sqlWhereTab[sqlWhereTabIndex] = string.format(" order by time desc limit %d offset %d  ", limit, offset)
    sqlWhereTabIndex = sqlWhereTabIndex + 1

    sqlStr = string.format(" %s %s ", sqlStr, table.concat(sqlWhereTab, " "))
    --comm_func.do_dump_value(sqlStr,0)
    --comm_func.do_dump_value(sqlTotal,0)

    local sql = sqlStr
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(sqlTotal)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false, res
    end
end

function _M.meetPic_check(pic)
    local picUrl = pic["pic"]
    if type(picUrl) ~= "string" or string.len(comm_func.trim_string(picUrl)) < 3 then
        return false, "pic必须是string类型"
    end
    if type(pic["time"]) ~= "number" then
        return false, "time必须是整形"
    end
    if type(pic["location"]) ~= "table" or pic["location"]["lat"] == nil or pic["location"]["lon"] == nil then
        return false, "location格式错误"
    end
    -- if type(pic["meeting_links"]) ~= "number" then
    --   return false,"meeting_links必须是整形"
    -- end
end

function _M.meetInfo_check(link)
    if type(link) ~= "table" then
        return false, "必须是JSON格式"
    end
    if type(link["meeting_title"]) ~= "string" or link["meeting_title"] == "" then
        return false, "meeting_title必须是string类型,且不为空"
    end
    if type(link["meeting_addr"]) ~= "string" or link["meeting_addr"] == "" then
        return false, "meeting_addr必须是string类型,且不为空"
    end
    if type(link["meeting_company_code"]) ~= "string" or link["meeting_company_code"] == "" then
        return false, "meeting_company_code必须是string类型,且不为空"
    end
    if type(link["meeting_company_name"]) ~= "string" or link["meeting_company_name"] == "" then
        return false, "meeting_company_name必须是string类型,且不为空"
    end
    if type(link["meeting_bu_code"]) ~= "string" or link["meeting_bu_code"] == "" then
        return false, "meeting_bu_code必须是string类型,且不为空"
    end
    if type(link["meeting_bu_name"]) ~= "string" or link["meeting_bu_name"] == "" then
        return false, "meeting_bu_name必须是string类型,且不为空"
    end
    if type(link["meeting_submit_userid"]) ~= "number" then
        return false, "meeting_submit_userid必须是整型"
    end
    if type(link["meeting_submit_usercode"]) ~= "string" or link["meeting_submit_usercode"] == "" then
        return false, "meeting_submit_usercode必须是string类型,且不为空"
    end
    if type(link["meeting_submit_username"]) ~= "string" or link["meeting_submit_username"] == "" then
        return false, "meeting_submit_username必须是string类型,且不为空"
    end
    if type(link["meeting_dev_info"]) ~= "string" or link["meeting_dev_info"] == "" then
        return false, "meeting_dev_info必须是string类型,且不为空"
    end

    if type(link["meeting_pic"]) ~= "table" or #link["meeting_pic"] < 1 then
        return false, "meeting_pic必须是JSON格式"
    end
    local picHave = false
    for idk, idv in pairs(link["meeting_pic"]) do
        local picCheckResult, msg = _M.meetPic_check(idv)
        if picCheckResult == false then
            return false, msg
        end
        picHave = true
    end
    if picHave == false then
        return false, "至少要有一张照片"
    end
    return true
end

function _M.meeting_get(meeting_id)
    -- local sql = string.format(" select * from tb_meeting_info where meeting_id = %s",tostring(meeting_id))
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(" select * from tb_meeting_info where meeting_id=" .. tostring(meeting_id)))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false
    end
end

function _M.meeting_submit(links, request_time)
    comm_func.do_dump_value(request_time, 0)
    local notTime = math.ceil(ngx.now())
    local meeting_company_code = links["meeting_company_code"]
    local meeting_company_name = links["meeting_company_name"]
    local meeting_bu_code = links["meeting_bu_code"]
    local meeting_bu_name = links["meeting_bu_name"]
    local totalsql
    local meeting_title = links["meeting_title"]
    local meeting_addr = links["meeting_addr"]
    local meeting_submit_userid = links["meeting_submit_userid"]
    local meeting_submit_usercode = links["meeting_submit_usercode"]
    local meeting_submit_username = links["meeting_submit_username"]
    local meeting_submit_time = math.ceil(ngx.now())
    local meeting_dev_info = links["meeting_dev_info"]
    local meeting_pic = links["meeting_pic"]

    local piccnt = 0
    local meeting_start_time = 0
    local meeting_end_time = 0

    for i, j in pairs(meeting_pic) do
        local picindex = j["meeting_links"]
        if type(picindex) ~= nil then
            if picindex == 0 then
                meeting_start_time = j["time"]
                piccnt = piccnt + 1
            elseif picindex == 1 then
                piccnt = piccnt + 1
            elseif picindex == 2 then
                meeting_end_time = j["time"]
                piccnt = piccnt + 1
            end
        end
    end

    local meeting_status
    if piccnt == 3 then
        meeting_status = "true"
    else
        -- meeting_status = "false"
        local tab = {}
        tab["resault"] = "照片信息不全"
        tab["error"] = error_table.get_error("ERROR_PIC_SOURCE")
        ngx.say(cjson.encode(tab))
        return false
    end

    local pic_source = cjson.encode(meeting_pic)

    local copyStr1 = "insert into tb_meeting_info(meeting_title,meeting_addr,meeting_company_code,meeting_company_name,"
    local copyStr2 = "meeting_bu_code,meeting_bu_name,meeting_submit_userid,meeting_submit_usercode,meeting_submit_username,"
    local copyStr3 = nil
    if request_time == nil then
        copyStr3 = "meeting_submit_time,meeting_start_time,meeting_end_time,meeting_pic,meeting_dev_info,meeting_status)"
    else
        copyStr3 = "meeting_submit_time,meeting_start_time,meeting_end_time,meeting_pic,meeting_dev_info,meeting_status,request_time)"
    end
    local copyStr4 = nil
    if request_time == nil then
        copyStr4 = string.format("values('%s','%s','%s','%s','%s','%s',%s,'%s','%s',%s,%s,%s,'%s','%s','%s');", tostring(meeting_title), tostring(meeting_addr), tostring(meeting_company_code), tostring(meeting_company_name), tostring(meeting_bu_code), tostring(meeting_bu_name), tostring(meeting_submit_userid), tostring(meeting_submit_usercode), tostring(meeting_submit_username), tostring(meeting_submit_time), tostring(meeting_start_time), tostring(meeting_end_time), pic_source, tostring(meeting_dev_info), tostring(meeting_status))
    else
        copyStr4 = string.format("values('%s','%s','%s','%s','%s','%s',%s,'%s','%s',%s,%s,%s,'%s','%s','%s',%d);", tostring(meeting_title), tostring(meeting_addr), tostring(meeting_company_code), tostring(meeting_company_name), tostring(meeting_bu_code), tostring(meeting_bu_name), tostring(meeting_submit_userid), tostring(meeting_submit_usercode), tostring(meeting_submit_username), tostring(meeting_submit_time), tostring(meeting_start_time), tostring(meeting_end_time), pic_source, tostring(meeting_dev_info), tostring(meeting_status), request_time)
    end

    local sql = string.format("%s%s%s%s", copyStr1, copyStr2, copyStr3, copyStr4)
    totalsql = sql
    comm_func.do_dump_value(sql, 0)
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(totalsql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false
    end

end

function _M.meetingList_get(meeting_id, meeting_title, meeting_company_code, meeting_bu_code, meeting_submit_time, fuzzy_searche_key, isAdmin, limit, offset, user_bu_code, is_download)
    local sqlWhereTab = {}
    local sqlWhereFuzzyTab = {}
    local sqlWhereTabIndex = 1
    local sqlStr
    local sqlFuzzyStr = ""
    local sqlTotal
    local reportSql

    local meeting_addr = nil

    sqlStr = " select * from tb_meeting_info tmi "
    sqlTotal = " select count(*) as total from tb_meeting_info tmi "
    reportSql = "  select tmi.meeting_company_name,tmi.meeting_bu_name,tmi.meeting_title,tmi.meeting_pic,tma.meeting_annex_url,tmi.meeting_submit_username,tmi.meeting_submit_time,tmi.meeting_id,tmi.meeting_company_code,tmi.meeting_bu_code from tb_meeting_info tmi left join(SELECT meeting_id,COUNT(meeting_id) AS meeting_annex_url FROM tb_meeting_annex GROUP BY meeting_id) tma on tmi.meeting_id=tma.meeting_id "

    sqlWhereTab[sqlWhereTabIndex] = string.format("  where 1=1 ")
    sqlWhereTabIndex = sqlWhereTabIndex + 1

    if meeting_id ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and tmi.meeting_id  = %s ", meeting_id)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if meeting_title ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and tmi.meeting_title  like '%%%s%%' ", meeting_title)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" tmi.meeting_title like '%%%s%%' ", fuzzy_searche_key))
    end
    if meeting_bu_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and tmi.meeting_bu_code  = '%s' ", meeting_bu_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" tmi.meeting_bu_code like '%%%s%%' ", fuzzy_searche_key))
        --if isAdmin == true then
        table.insert(sqlWhereFuzzyTab, string.format(" tmi.meeting_bu_name like '%%%s%%' ", fuzzy_searche_key))
        --end
    end
    if meeting_addr ~= nil then
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" tmi.meeting_addr like '%%%s%%' ", fuzzy_searche_key))
    end

    if user_bu_code ~= nil and user_bu_code ~= "" then
        local userBuWhere = nil
        local userBuTab = comm_func.split_string(user_bu_code, ",")
        if string.len(user_bu_code) == 2 then
            userBuWhere = string.format(" tmi.meeting_bu_code like '%s%%'  ", user_bu_code)
        elseif #userBuTab > 1 then
            local whereBuTab = {}
            for buk, buv in pairs(userBuTab) do
                table.insert(whereBuTab, string.format(" '%s' ", buv))
            end
            local whereBuTabStr = table.concat(whereBuTab, " , ")
            userBuWhere = string.format(" tmi.meeting_bu_code in ( %s )  ", whereBuTabStr)
        else
            userBuWhere = string.format(" tmi.meeting_bu_code='%s'  ", user_bu_code)
        end
        if userBuWhere ~= nil then
            sqlWhereTab[sqlWhereTabIndex] = " and  " .. userBuWhere
            sqlWhereTabIndex = sqlWhereTabIndex + 1
        end
    end

    if meeting_submit_time ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and tmi.meeting_submit_time >= %s and tmi.meeting_submit_time < %s", tostring(meeting_submit_time), tostring(meeting_submit_time + 86400))
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    if meeting_company_code ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  and tmi.meeting_company_code  = '%s' ", meeting_company_code)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    elseif fuzzy_searche_key ~= nil then
        table.insert(sqlWhereFuzzyTab, string.format(" tmi.meeting_company_code like '%%%s%%' ", fuzzy_searche_key))
    end

    local sqlWhereStr = table.concat(sqlWhereTab, " ")
    local sqlWhereFuzzyStr = table.concat(sqlWhereFuzzyTab, " or ")

    if string.len(sqlWhereFuzzyStr) > 3 then
        sqlWhereStr = string.format(" %s and ( %s ) ", sqlWhereStr, sqlWhereFuzzyStr)
        sqlWhereTab[sqlWhereTabIndex] = string.format(" and ( %s  ) ", sqlWhereFuzzyStr)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end
    sqlTotal = string.format(" %s %s ", sqlTotal, sqlWhereStr)
    if is_download == true then
        sqlWhereTab[sqlWhereTabIndex] = string.format(" order by tmi.meeting_submit_time desc ")
    elseif is_download == nil or is_download == false then
        sqlWhereTab[sqlWhereTabIndex] = string.format(" order by tmi.meeting_submit_time desc limit %d offset %d  ", limit, offset)
    end
    sqlWhereTabIndex = sqlWhereTabIndex + 1

    sqlStr = string.format(" %s %s ", sqlStr, table.concat(sqlWhereTab, " "))
    reportSql = string.format(" %s %s ", reportSql, table.concat(sqlWhereTab, " "))

    local sql = sqlStr
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(sqlTotal)
        if totalResult == true then
            return true, res, #res, total, limit, offset, reportSql
        else
            return false, res
        end
    else
        return false, res
    end
end

function _M.meetingAnnex_submit(meetAnnexTab)
    local notTime
    local copyStr1
    local copyStr2
    local copyStr3
    local sql

    if meetAnnexTab["annex_delete_id"] == nil then
        notTime = math.ceil(ngx.now())
        copyStr1 = "insert into tb_meeting_annex(meeting_id,meeting_submit_userid,meeting_submit_username,meeting_company_code,meeting_company_name,"
        copyStr2 = "meeting_bu_code,meeting_bu_name,meeting_submit_time,meeting_annex_name,meeting_annex_url)"
        copyStr3 = string.format("values(%s,%s,'%s','%s','%s','%s','%s',%s,'%s','%s');", tostring(meetAnnexTab["meeting_id"]), tostring(meetAnnexTab["meeting_submit_userid"]), tostring(meetAnnexTab["meeting_submit_username"]), tostring(meetAnnexTab["meeting_company_code"]), tostring(meetAnnexTab["meeting_company_name"]), tostring(meetAnnexTab["meeting_bu_code"]), tostring(meetAnnexTab["meeting_bu_name"]), tostring(notTime), tostring(meetAnnexTab["meeting_annex_name"]), tostring(meetAnnexTab["meeting_annex_url"]))
        sql = string.format("%s%s%s", copyStr1, copyStr2, copyStr3)
    else
        sql = string.format("delete from tb_meeting_annex where meeting_annex_id = %s", tostring(meetAnnexTab["annex_delete_id"]))
    end

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false
    end
end

function _M.meetingAnnexList_get(meeting_id)
    local sqlStr
    local sqlTotal

    local meeting_addr = nil

    sqlStr = string.format("select * from tb_meeting_annex where meeting_id = %s order by meeting_submit_time desc", tostring(meeting_id))
    sqlTotal = string.format("select count(*) as total from tb_meeting_annex where meeting_id = %s", tostring(meeting_id))

    local sql = sqlStr
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _M.listTotal_get(sqlTotal)
        if totalResult == true then
            return true, res, #res, total
        else
            return false, res
        end
    else
        return false, res
    end
end
function _M.meetingRequestTime_get(user_id, request_time)
    local sql = string.format(" select * from tb_meeting_info where meeting_submit_userid = %d and request_time = %d ", user_id, request_time)
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false
    end
end

function _M.msg_erp_test(msg_sender_number, msg_receiver_number, msg_send_time_text, msg_title, msg_content)
    local sql = string.format("insert into tb_sync_push_msg (msg_sender_number,msg_receiver_number,msg_send_time_text,msg_title,msg_content) values('%s','%s','%s','%s','%s');", tostring(msg_sender_number), tostring(msg_receiver_number), tostring(msg_send_time_text), tostring(msg_title), tostring(msg_content))
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false
    end
end

function _M.msg_erp_test_back(msg_sender_number)

    local selsql = string.format("select * from tb_push_msg where cid=(select  max(cid) from tb_push_msg) and sender_number ='%s';", tostring(msg_sender_number))
    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local selres = assert(pg:query(selsql))
    pg:keepalive()

    if selres ~= nil then
        return true, selres
    else
        return false
    end
end


--
--权限控制
--
function _M.user_is_group_jianli(role_value)
    if (role_value >= 1040 and role_value <= 1049) then
        return true
    end
    return false
end
function _M.user_is_group_admin(role_value)
    if role_value == 0 or role_value == 1000 then
        return true
    end
    return false
end

function _M.permission_check_project_review(role_value)
    if role_value == 1 or (role_value >= 1100 and role_value <= 1199) or (role_value >= 1040 and role_value <= 1049) then
        return true
    end
    return false
end

function _M.permission_check_project_fine(role_value)
    if (role_value <= 1199 and role_value >= 1000) or role_value == 0 or role_value == 1 then
        return true
    end
    return false
end

function _M.permission_check_project_submit(role_value)
    if role_value == 2 or (role_value >= 1200 and role_value <= 1299) then
        return true
    end
    return false
end

return _M


