local _PROJECT = {}

function _PROJECT.get_new_pgmoon_connection()
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

function _PROJECT.excute(sql)
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _PROJECT.listTotal_get(sqlStr)

    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res[1]["total"]
    else
        return false, res
    end
end

function _PROJECT.organization_get(o_code)
    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(" select * from tb_organization where o_code='" .. o_code .. "' "))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

--
--"公司编码","公司名称","用户编码","用户名","姓名","是否锁定","变更时间"
--
function _PROJECT.user_import(data)
    local status, apps = db_query.user_get(nil, data[3])
    if status == true and apps ~= nil and apps[1] ~= nil then
        return false, data[3]
    end
    local user_name = nil
    if data[4] ~= nil and data[4] ~= "" then
        user_name = data[4] .. data[3]
    else
        user_name = data[5] .. data[3]
    end

    local user_password = ngx.md5("Gd18Ws")
    local user_role = 3
    local user_number = data[3]
    local user_bu_name = data[2]
    local user_bu_code = data[1]

    local user_job = "职员"
    local user_code = data[3]
    local user_entry_time = data[7]

    local user_company = data[2]
    local user_company_code = nil

    if string.len(data[1]) > 2 then
        user_company_code = string.sub(data[1], 1, 2)
        local status, apps = _PROJECT.organization_get(user_company_code)
        if status == true and apps ~= nil and apps[1] ~= nil then
            user_company = apps[1]["o_name"]
        end
    else
        user_company_code = data[1]
    end

    local userAddSql = " insert into tb_user(user_name,user_password,user_role,user_number,user_bu_name,user_bu_code,user_job,user_code,user_entry_time,user_company,user_company_code) values('%s','%s',%d,'%s','%s','%s','%s','%s','%s','%s','%s') "
    userAddSql = string.format(userAddSql, user_name, user_password, user_role, user_number, user_bu_name, user_bu_code, user_job, user_code, user_entry_time, user_company, user_company_code)

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    --comm_func.do_dump_value(userAddSql,0)
    local res = assert(pg:query(userAddSql))
    pg:keepalive()
    if res ~= nil then

        return true, res
    else
        return false, res
    end
end


--
--"公司编码","公司名称","用户编码","用户名","姓名","是否锁定","变更时间"
--
function _PROJECT.user_import_v0_4(data)
    local isUpdateUser = false
    local status, apps = db_query.user_get(nil, data["user_number"])
    if status == true and apps ~= nil and apps[1] ~= nil then
        if data["user_change_time"] ~= apps[1]["user_entry_time then"] then
            isUpdateUser = true
        else
            return false, apps
        end
    end
    local user_name = data["user_name"]

    local user_password = ngx.md5("Gd18Ws")
    local user_role = 3
    local user_number = data["user_number"]
    local user_bu_name = data["user_company"]
    local user_bu_code = data["user_company_code"]

    local user_job = "职员"
    local user_code = data["user_number"]
    local user_entry_time = data["user_change_time"]
    if user_entry_time == nil then
        user_entry_time = ''
    end

    local user_company = data["user_company"]
    local user_company_code = data["user_company_code"]

    if string.len(data["user_company_code"]) > 2 then
        user_company_code = string.sub(data["user_company_code"], 1, 2)
        local status, apps = _PROJECT.organization_get(user_company_code)
        if status == true and apps ~= nil and apps[1] ~= nil then
            user_company = apps[1]["o_name"]
        end
    end

    local userAddSql = nil
    if isUpdateUser == false then
        userAddSql = " insert into tb_user(user_name,user_password,user_role,user_number,user_bu_name,user_bu_code,user_job,user_code,user_entry_time,user_company,user_company_code) values('%s','%s',%d,'%s','%s','%s','%s','%s','%s','%s','%s') returning user_number "
        userAddSql = string.format(userAddSql, user_name, user_password, user_role, user_number, user_bu_name, user_bu_code, user_job, user_code, user_entry_time, user_company, user_company_code)
    else
        userAddSql = " update tb_user set user_name = '%s',user_bu_name='%s',user_bu_code='%s',user_entry_time='%s',user_company='%s',user_company_code='%s' where user_number='%s'  returning user_number "
        userAddSql = string.format(userAddSql, user_name, user_bu_name, user_bu_code, user_entry_time, user_company, user_company_code, user_number)
    end

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    --comm_func.do_dump_value(userAddSql,0)
    local res = assert(pg:query(userAddSql))
    pg:keepalive()
    if res ~= nil then

        return true, res
    else
        return false, res
    end
end

function _PROJECT.organization_import(data)
    local status, apps = _PROJECT.organization_get(data[1])
    if status == true and apps ~= nil and apps[1] ~= nil then
        return false, data[1]
    end
    local organizationAddSql = string.format(" insert into tb_organization(o_name,o_code,o_parent_code,o_parent_name) values('%s','%s','%s','%s') ", data[2], data[1], "", "")

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(organizationAddSql))
    pg:keepalive()
    if res ~= nil then

        return true, res
    else
        return false, res
    end
end

function _PROJECT.organization_import_v0_4(data)
    local status, apps = _PROJECT.organization_get(data["user_company_code"])
    if status == true and apps ~= nil and apps[1] ~= nil then
        return false, apps[1]
    end
    local organizationAddSql = string.format(" insert into tb_organization(o_name,o_code,o_parent_code,o_parent_name) values('%s','%s','%s','%s')  returning o_code ", data["user_company"], data["user_company_code"], "", "")

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(organizationAddSql))
    pg:keepalive()
    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _PROJECT.userMsgReceiverList_get(user_company_code, user_bu_code)
    local sqlStr = string.format(" select * from tb_user where (strpos(user_bu_code,'%s') > 0 and (user_role = 2 or user_role = 1 )) or (user_bu_code='%s' and user_role=1) order by user_role asc ", user_bu_code, user_company_code)

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()
    if res ~= nil then
        return true, res
    else
        return false, res
    end

end
function _PROJECT.userMsgReceiverListFromJianLi_get()
    local sqlStr = string.format(" select * from tb_user where user_role = 1045 ")

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()
    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _PROJECT.userMsgReceiverListFromIds_get(user_ids)
    local sqlStr = string.format(" select * from tb_user where user_id in ( %s ) order by user_role asc ", user_ids)
    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()
    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _PROJECT.userList_get(isAdmin, user_bu_codeLike, user_id, user_name, user_mail, user_phone, user_role, user_number, user_bu_name, user_bu_code, user_job, user_code, user_entry_time, user_company, user_company_code, fuzzy_searche_key, limit, offset)
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

    sqlWhereTab[sqlWhereTabIndex] = string.format(" order by user_company_code asc, user_bu_code asc, user_number asc   limit %d offset %d  ", limit, offset)
    sqlWhereTabIndex = sqlWhereTabIndex + 1

    sqlStr = string.format(" %s %s ", sqlStr, table.concat(sqlWhereTab, " "))
    --comm_func.do_dump_value(sqlStr,0)
    --comm_func.do_dump_value(sqlTotal,0)

    local sql = sqlStr
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _PROJECT.listTotal_get(sqlTotal)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false, res
    end
end

function _PROJECT.user_update(user_id, user_mail, user_phone, user_role, user_number, user_bu_name, user_bu_code, user_job, user_code, user_entry_time, user_company, user_company_code, user_erp_msg_receive)
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
    if user_erp_msg_receive ~= nil then
        sqlWhereTab[sqlWhereTabIndex] = string.format("  user_erp_msg_receive  = '%d' ", user_erp_msg_receive)
        sqlWhereTabIndex = sqlWhereTabIndex + 1
    end

    local sqlWhereStr = table.concat(sqlWhereTab, " ,")
    sqlStr = string.format(" %s %s where user_id= %d ", " update tb_user set ", sqlWhereStr, user_id)

    local sql = sqlStr
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

return _PROJECT


