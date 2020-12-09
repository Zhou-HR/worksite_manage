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

--
--For HaTe
--
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
        if userInfo["user_role"] == 0 then
            return true
        end
    else
        local pg = _M.get_new_pgmoon_connection()

        assert(pg:connect())
        local res = assert(pg:query(" select * from tb_user where user_id=" .. tostring(user_id)))
        pg:keepalive()

        if res ~= nil and res[1] ~= nil then
            if res[1]["user_role"] == 0 then
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
        return false, data[1]
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
            else
                proj_type_value = 2
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
                                        name = "钢筋笼验收",
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
                                        name = "地圈梁（柱）验收",
                                        proj_link_type = 9
                                    },
                                    [3] = {
                                        name = "屋面（结顶）验收",
                                        proj_link_type = 10
                                    }
                                }
                            },
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
                                name = "表箱安装位置照片",
                                proj_link_type = 19
                            },
                            [3] = {
                                name = "线缆规格照片",
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
                                name = "机柜布线照片",
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
                                name = "表箱安装位置照片",
                                proj_link_type = 19
                            },
                            [3] = {
                                name = "线缆规格照片",
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
                                name = "机柜布线照片",
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
                                name = "表箱安装位置照片",
                                proj_link_type = 19
                            },
                            [3] = {
                                name = "线缆规格照片",
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
                                name = "机柜布线照片",
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
                                    [3] = "钢筋笼验收",
                                    [4] = "浇筑验收",
                                    [5] = "地网验收",
                                    [6] = "预埋件验收"
                                }
                            },
                            [3] = {
                                name = "落地机房",
                                sub = {
                                    [1] = "基槽验收",
                                    [2] = "地圈梁（柱）验收",
                                    [3] = "屋面（结顶）验收"
                                }
                            },
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
                            [2] = "表箱安装位置照片",
                            [3] = "线缆规格照片"
                        }
                    },
                    [5] = {
                        name = "配套安装",
                        sub = {
                            [1] = "底座固定照片",
                            [2] = "机柜布线照片",
                            [3] = "整体完工照片（初验）"
                        }
                    },
                    [6] = {
                        name = "竣工交维",
                        sub = {
                            [1] = "竣工照片"
                        }
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
                            [2] = "表箱安装位置照片",
                            [3] = "线缆规格照片"
                        }
                    },
                    [4] = {
                        name = "配套安装",
                        sub = {
                            [1] = "底座固定照片",
                            [2] = "机柜布线照片",
                            [3] = "整体完工照片（初验）"
                        }
                    },
                    [5] = {
                        name = "竣工交维",
                        sub = {
                            [1] = "竣工照片"
                        }
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
                            [4] = "地网验收"
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
                            [2] = "表箱安装位置照片",
                            [3] = "线缆规格照片"
                        }
                    },
                    [4] = {
                        name = "配套安装",
                        sub = {
                            [1] = "底座固定照片",
                            [2] = "机柜布线照片",
                            [3] = "整体完工照片（初验）"
                        }
                    },
                    [5] = {
                        name = "竣工交维",
                        sub = {
                            [1] = "竣工照片"
                        }
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
        if linksTab[latestLinkId]["proj_link_status"] == 2 then
            local copyStr1 = "insert into tb_proj_link_recod(proj_link_id,proj_name,proj_type_name ,proj_module_name ,proj_link_name  ,proj_link_type  ,"
            local copyStr2 = "proj_link_submit_time ,proj_link_submit_user_code ,proj_link_review_time ,proj_link_reviewer_code ,"
            local copyStr3 = "proj_link_review_describe , proj_link_pic,proj_link_status, proj_link_describe ,proj_code  ,proj_link_submit_user_name, "
            local copyStr4 = "proj_link_submit_user_id, proj_link_reviewer_name, proj_link_reviewer_id ,proj_bu_code , proj_company_code  )    "
            local copyStr5 = "select proj_link_id,proj_name,proj_type_name ,proj_module_name ,proj_link_name  ,proj_link_type  ,proj_link_submit_time ,proj_link_submit_user_code ,"
            local copyStr6 = " proj_link_review_time ,proj_link_reviewer_code , "
            local copyStr7 = "proj_link_review_describe , proj_link_pic,proj_link_status, proj_link_describe ,proj_code  ,proj_link_submit_user_name, "
            local copyStr8 = "proj_link_submit_user_id, proj_link_reviewer_name, proj_link_reviewer_id ,proj_bu_code , proj_company_code  "
            local copyStr9 = string.format("  from tb_proj_link where proj_link_id=%d; ", v["proj_link_id"])

            innerTab[innerTabIndex] = string.format("%s %s %s %s %s %s %s %s %s  ", copyStr1, copyStr2, copyStr3, copyStr4, copyStr5, copyStr6, copyStr7, copyStr8, copyStr9);
            innerTabIndex = innerTabIndex + 1
        end
        local temp_proj_link_describe = comm_func.sql_singleQuotationMarks(v["proj_link_describe"])
        innerTab[innerTabIndex] = string.format("update tb_proj_link set proj_link_submit_user_name='%s',proj_link_submit_user_code='%s',proj_link_submit_user_id=%d,proj_link_describe='%s',proj_link_status=1,proj_link_submit_time=%d,proj_link_pic='%s' where proj_link_id=%d  ; ", v["proj_link_submit_user_name"], v["proj_link_submit_user_code"], v["proj_link_submit_user_id"], temp_proj_link_describe, notTime, proj_link_pic, v["proj_link_id"])
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
    for k, v in pairs(links) do
        local temp_proj_link_review_describe = comm_func.sql_singleQuotationMarks(v["proj_link_review_describe"])
        innerTab[innerTabIndex] = string.format("update tb_proj_link set proj_link_review_describe='%s',proj_link_reviewer_name='%s',proj_link_reviewer_id=%d,proj_link_reviewer_code='%s',proj_link_status=%d,proj_link_review_time=%d where proj_link_id=%d  ; ", temp_proj_link_review_describe, v["proj_link_reviewer_name"], v["proj_link_reviewer_id"], v["proj_link_reviewer_code"], v["proj_link_status"], notTime, v["proj_link_id"])
        innerTabIndex = innerTabIndex + 1
        updateCount = updateCount + 1
    end
    innerTab[innerTabIndex] = string.format(" OPEN temp_curs1 FOR select count(*) from tb_proj_link where proj_code='%s' and (proj_link_status=0 or proj_link_status=1 or proj_link_status=2); ", proj_code)
    innerTabIndex = innerTabIndex + 1
    innerTab[innerTabIndex] = string.format(" FETCH temp_curs1 INTO temp_count;  CLOSE temp_curs1; ")
    innerTabIndex = innerTabIndex + 1
    innerTab[innerTabIndex] = string.format("  if temp_count < 1 then ")
    innerTabIndex = innerTabIndex + 1
    innerTab[innerTabIndex] = string.format("update tb_proj set proj_status = 3 where proj_code='%s'  ;", proj_code)
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
                innerTab[7] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','钢筋笼验收',4,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[8] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','浇筑验收',5,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[9] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','地网验收',6,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[10] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','预埋件验收',7,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[11] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values('%s','%s','落地','土建施工','基槽验收',8,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[12] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','地圈梁（柱）验收',9,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[13] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','屋面（结顶）验收',10,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[14] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','特殊工种上岗证照片',13,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[15] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','铁塔厂家出厂合格证照片',14,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[16] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','铁塔图纸照片',15,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[17] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','基础回弹照片',16,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[18] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','塔桅安装','整体完工（初验）照片',17,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[19] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','接电施工','接入点照片',18,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[20] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','接电施工','表箱安装位置照片',19,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[21] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','接电施工','线缆规格照片',20,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[22] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','配套安装','底座固定照片',21,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[23] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','配套安装','机柜布线照片',22,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[24] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','配套安装','整体完工照片（初验）',23,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[25] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','竣工交维','竣工照片',24,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[26] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','落地','土建施工','施工进场',25,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[27] = string.format(" update tb_proj set proj_links='%s' where proj_code='%s'; ", proj_linksStr, proj_code)
                innerTab[28] = "RETURN 23;"
                innerTab[29] = "END;"
                innerTab[30] = "$BODY$"
                innerTab[31] = "language plpgsql;"
                processSql = table.concat(innerTab, " ")
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
                innerTab[11] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','接电施工','表箱安装位置照片',19,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[12] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','接电施工','线缆规格照片',20,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[13] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values('%s','%s','楼面（普通）','配套安装','底座固定照片',21,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[14] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','配套安装','机柜布线照片',22,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[15] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','配套安装','整体完工照片（初验）',23,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[16] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','竣工交维','竣工照片',24,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[17] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（普通）','土建施工','施工进场',25,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[18] = string.format(" update tb_proj set proj_links='%s' where proj_code='%s'; ", proj_linksStr, proj_code)
                innerTab[19] = "RETURN 14;"
                innerTab[20] = "END;"
                innerTab[21] = "$BODY$"
                innerTab[22] = "language plpgsql;"
                processSql = table.concat(innerTab, " ")
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
                innerTab[12] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','接电施工','表箱安装位置照片',19,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[13] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','接电施工','线缆规格照片',20,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[14] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values('%s','%s','楼面（植筋）','配套安装','底座固定照片',21,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[15] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','配套安装','机柜布线照片',22,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[16] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','配套安装','整体完工照片（初验）',23,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[17] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','竣工交维','竣工照片',24,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[18] = string.format("insert into tb_proj_link(proj_code,proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_bu_code,proj_company_code) values( '%s','%s','楼面（植筋）','土建施工','施工进场',25,'%s','%s');", proj_code, proj_name, proj_bu_code, proj_company_code)
                innerTab[19] = string.format(" update tb_proj set proj_links='%s' where proj_code='%s'; ", proj_linksStr, proj_code)
                innerTab[20] = "RETURN 15;"
                innerTab[21] = "END;"
                innerTab[22] = "$BODY$"
                innerTab[23] = "language plpgsql;"
                processSql = table.concat(innerTab, " ")
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
        table.insert(whereTab, string.format(" proj_link_status=%d  ", proj_link_status))
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
    local save_time = time - 5184000

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

return _M


