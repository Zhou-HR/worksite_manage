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
function _PROJECT.project_delete(proj_code)
    local sql = " delete from tb_proj where proj_code='" .. proj_code .. "'  returning proj_code "
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

function _PROJECT.project_module_links_add_link(proj_name, proj_type_name, proj_module_name, proj_link_name, proj_link_type, proj_code, proj_bu_code, proj_company_code, proj_link_pic_max_num)
    local projUpdateSql = string.format("insert into tb_proj_link(proj_name,proj_type_name,proj_module_name,proj_link_name,proj_link_type,proj_code,proj_bu_code,proj_company_code,proj_link_pic_max_num)  values('%s','%s','%s','%s',%d,'%s','%s','%s',%d) ", proj_name, proj_type_name, proj_module_name, proj_link_name, proj_link_type, proj_code, proj_bu_code, proj_company_code, proj_link_pic_max_num)
    local pg = _PROJECT.get_new_pgmoon_connection()
    --comm_func.do_dump_value(projUpdateSql,0)
    assert(pg:connect())
    local res = assert(pg:query(projUpdateSql))
    pg:keepalive()
    --comm_func.do_dump_value(res,0)
    if res ~= nil and res["affected_rows"] == 1 then
        return true, res
    else
        return false, res
    end
end

function _PROJECT.project_module_links_only_add(projTab, proj_code, proj_module_name, proj_module_code, proj_link_name, proj_link_type)
    local linkAddStatus, linkAddRes = _PROJECT.project_module_links_add_link(projTab["proj_name"], projTab["proj_station_type"], proj_module_name, proj_link_name, proj_link_type, proj_code, projTab["proj_bu_code"], projTab["proj_company_code"], projTab["proj_link_pic_max_num"])
    if linkAddStatus == true then
        return true, res
    else
        return false, linkAddRes
    end
end

function _PROJECT.project_module_links_name_update(proj_code, proj_links_before, proj_links, proj_module_name, proj_module_code, proj_link_name, proj_link_type)
    local projUpdateSql = string.format(" update tb_proj set proj_links='%s' where proj_code='%s'  returning proj_name,proj_station_type,proj_code,proj_bu_code,proj_company_code ,proj_link_pic_max_num", proj_links, proj_code)
    local pg = _PROJECT.get_new_pgmoon_connection()
    --comm_func.do_dump_value(projUpdateSql,0)
    assert(pg:connect())
    local res = assert(pg:query(projUpdateSql))
    pg:keepalive()
    --comm_func.do_dump_value(res,0)
    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] == proj_code then
        return true, res
    else
        return false, res
    end
end

function _PROJECT.project_module_links_add_recover(proj_code, proj_links_before)
    local projUpdateSql = string.format(" update tb_proj set proj_links='%s' where proj_code='%s'  returning  proj_code ", proj_links_before, proj_code)
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(projUpdateSql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _PROJECT.project_module_links_add(proj_code, proj_links_before, proj_links, proj_module_name, proj_module_code, proj_link_name, proj_link_type)
    local projUpdateSql = string.format(" update tb_proj set proj_links='%s' where proj_code='%s'  returning proj_name,proj_station_type,proj_code,proj_bu_code,proj_company_code ,proj_link_pic_max_num", proj_links, proj_code)
    local pg = _PROJECT.get_new_pgmoon_connection()
    --comm_func.do_dump_value(projUpdateSql,0)
    assert(pg:connect())
    local res = assert(pg:query(projUpdateSql))
    pg:keepalive()
    --comm_func.do_dump_value(res,0)
    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] == proj_code then
        local linkAddStatus, linkAddRes = _PROJECT.project_module_links_add_link(res[1]["proj_name"], res[1]["proj_station_type"], proj_module_name, proj_link_name, proj_link_type, proj_code, res[1]["proj_bu_code"], res[1]["proj_company_code"], res[1]["proj_link_pic_max_num"])
        if linkAddStatus == true then
            return true, res
        else
            _PROJECT.project_module_links_add_recover(proj_code, proj_links_before)
            return false, linkAddRes
        end
    else
        return false, res
    end
end

function _PROJECT.projectLinkType_get(proj_code, proj_link_type)
    local sql = " select * from tb_proj_link where proj_code= '" .. tostring(proj_code) .. "' and proj_link_type = " .. tostring(proj_link_type) .. " order by proj_link_type desc "

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

function _PROJECT.allProjectPicTakeControl_update(proj_link_pic_max_num, proj_link_max_distan)
    local sqlTab = {}
    local sql
    local sqlLink = nil

    table.insert(sqlTab, " update tb_proj set ")
    if proj_link_pic_max_num ~= nil then
        table.insert(sqlTab, string.format(" proj_link_pic_max_num=%d ", proj_link_pic_max_num))
        if proj_link_max_distan ~= nil then
            table.insert(sqlTab, string.format(", proj_link_max_distan=%d ", proj_link_max_distan))
        end
        sqlLink = string.format(" update tb_proj_link set proj_link_pic_max_num=%d  returning proj_link_id ", proj_link_pic_max_num)
    elseif proj_link_max_distan ~= nil then
        table.insert(sqlTab, string.format(" proj_link_max_distan=%d ", proj_link_max_distan))
    end

    table.insert(sqlTab, " returning proj_code ")

    sql = table.concat(sqlTab, "   ")

    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        if sqlLink ~= nil then
            if res[1] ~= nil and res[1]["proj_code"] ~= nil then
                local linkStatus = db_query.projectPicTakeControlLink_update(sqlLink)
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
function _PROJECT.projectGlobalConf_update(proj_link_pic_max_num, proj_link_max_distan)
    local sql

    if proj_link_pic_max_num ~= nil then
        if proj_link_max_distan ~= nil then
            sql = string.format(" update tb_proj_global_config set proj_link_max_distan=%d,proj_link_pic_max_num=%d  ", proj_link_max_distan, proj_link_pic_max_num)
        else
            sql = string.format(" update tb_proj_global_config set proj_link_pic_max_num=%d  ", proj_link_pic_max_num)
        end
    else
        sql = string.format(" update tb_proj_global_config set proj_link_max_distan=%d  ", proj_link_max_distan)
    end

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

function _PROJECT.projectGlobalConf_get()
    local sql = " select * from  tb_proj_global_config  "
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

function _PROJECT.link_get(proj_link_id)
    local sql = string.format(" select * from tb_proj_link where proj_link_id =%d ", proj_link_id)
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return false, res
    else
        return false
    end
end

function _PROJECT.linkUnInitStatusList_get(proj_code)
    local sql = string.format(" select * from tb_proj_link where proj_code ='%s' and proj_link_status !=0 ", proj_code)
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return false, res
    else
        return false
    end
end

function _PROJECT.linkReviewedList_get(limit, offset)
    local sqlTotal = "  select count(proj_code) as total from tb_proj_link  where proj_link_sync_time =0 and proj_code !='GDJZAAAAAAAAAAYD' and (proj_link_status = 3 or proj_link_status = 5 or proj_link_status = 7 or proj_link_status = 8 )  "
    local sql = string.format(" select proj_link_id,proj_code,proj_module_name, proj_link_name,proj_link_review_time,proj_link_type from tb_proj_link where proj_link_sync_time =0  and proj_code !='GDJZAAAAAAAAAAYD' and (proj_link_status = 3 or proj_link_status = 5 or proj_link_status = 7 or proj_link_status = 8) order by  proj_link_review_time asc limit %d offset %d ", limit, offset)

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
        return false
    end
end

function _PROJECT.linkModuleReviewedList_get(limit, offset)
    local sqlTotal = "  select count(*) as total from tb_proj_link where proj_code !='GDJZAAAAAAAAAAYD' and ( proj_link_status=3 or proj_link_status=5 or proj_link_status = 7 or proj_link_status = 8) and proj_link_sync_time =0 and proj_module_name in('塔桅安装','接电施工','配套安装','竣工交维')   group by proj_code,proj_module_name order by proj_link_review_time desc  "
    local sql = string.format(" select proj_code,proj_module_name,count(proj_link_id) as passed_count,max(proj_link_review_time) as time  from tb_proj_link where proj_code !='GDJZAAAAAAAAAAYD' and ( proj_link_status=3 or proj_link_status=5 or proj_link_status = 7 or proj_link_status = 8 ) and proj_link_sync_time =0 and proj_module_name in('塔桅安装','接电施工','配套安装','竣工交维')   group by proj_code,proj_module_name order by proj_link_review_time desc limit %d offset %d ", limit, offset)

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
        return false
    end
end

function _PROJECT.linkTuJianModuleReviewedList_get(limit, offset)
    local sqlTotal = "  select count(*) as total from tb_proj_link where proj_code !='GDJZAAAAAAAAAAYD' and ( proj_link_status=3 or proj_link_status=5 or proj_link_status = 7 or proj_link_status = 8  ) and proj_link_sync_time =0 and proj_module_name ='土建施工' and proj_link_type != 25  group by proj_code,proj_module_name order by proj_code  "
    local sql = string.format(" select proj_code,proj_module_name,count(proj_link_id) as passed_count,max(proj_link_review_time) as time  from tb_proj_link where proj_code !='GDJZAAAAAAAAAAYD' and ( proj_link_status=3 or proj_link_status=5 or proj_link_status = 7 or proj_link_status = 8  ) and proj_link_sync_time =0 and proj_module_name ='土建施工' and proj_link_type != 25  group by proj_code,proj_module_name order by proj_link_review_time desc limit %d offset %d ", limit, offset)

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
        return false
    end
end

function _PROJECT.link1TuJianModuleReviewedList_get(limit, offset)
    local sqlTotal = "  select count(proj_code) as total from tb_proj_link  where proj_link_sync_time =0 and proj_code !='GDJZAAAAAAAAAAYD' and (proj_link_status = 3 or proj_link_status = 5 or proj_link_status = 7 or proj_link_status = 8 )  and proj_link_type=25 "
    local sql = string.format(" select proj_link_id,proj_code,proj_module_name, proj_link_name,proj_link_review_time,proj_link_type from tb_proj_link where proj_link_sync_time =0  and proj_code !='GDJZAAAAAAAAAAYD' and (proj_link_status = 3 or proj_link_status = 5 or proj_link_status = 7 or proj_link_status = 8  )  and proj_link_type=25 order by  proj_link_review_time desc limit %d offset %d ", limit, offset)

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
        return false
    end
end

function _PROJECT.linkModuleCount_get(proj_code, proj_module_name)
    local sql = string.format(" select count(*) as total  from tb_proj_link where proj_code ='%s' and  proj_link_status !=6  and proj_module_name ='%s'  ", proj_code, proj_module_name)
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res[1]["total"]
    else
        return false
    end
end

function _PROJECT.linkTuJianModuleCount_get(proj_code, proj_module_name)
    local sql = string.format(" select count(*) as total  from tb_proj_link where proj_code ='%s' and  proj_link_status !=6  and proj_module_name ='%s' and proj_link_type != 25  ", proj_code, proj_module_name)
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res[1]["total"]
    else
        return false
    end
end

function _PROJECT.linkSynced_update(proj_link_id)
    local nowTime = math.ceil(ngx.now())
    local sql = string.format(" update tb_proj_link set proj_link_sync_time=%d  where proj_link_id = %d ", nowTime, proj_link_id)

    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false
    end
end

function _PROJECT.linkModuleSynced_update(proj_code, proj_module_name)
    local nowTime = math.ceil(ngx.now())
    local sql = string.format(" update tb_proj_link set proj_link_sync_time=%d  where proj_code = '%s' and proj_module_name ='%s' ", nowTime, proj_code, proj_module_name)

    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false
    end
end

function _PROJECT.projectList_search(proj_code, proj_name, proj_addr, proj_establish_time, proj_station_type, proj_tower_type, proj_base_type, proj_bu_code, fuzzy_searche_key, isAdmin, proj_company_code, proj_bu_code_before, proj_module_name_ls, proj_submit_time, limit, offset)
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
    if proj_company_code ~= nil and proj_company_code ~= "" then
        local likeStr = " proj_company_code = '" .. proj_company_code .. "' "
        table.insert(whereTab, likeStr)
    end
    if proj_bu_code_before ~= nil and proj_bu_code_before ~= "" then
        local likeStr = " proj_bu_code = '" .. proj_bu_code_before .. "' "
        table.insert(whereTab, likeStr)
    end
    if proj_module_name_ls ~= nil and proj_module_name_ls ~= "" then
        local likeStr = " proj_module_name_ls = '" .. proj_module_name_ls .. "' "
        table.insert(whereTab, likeStr)
    end
    if proj_submit_time ~= nil and proj_submit_time > 0 then
        local likeStr = " proj_submit_time >= " .. tostring(proj_submit_time) .. " and proj_submit_time <  " .. tostring(proj_submit_time + 86400)
        table.insert(whereTab, likeStr)
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
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _PROJECT.listTotal_get(totalSql)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false, res
    end
end

function _PROJECT.projectInfo_update(proj_code, proj_bu_code, isAdmin, proj_tujian_unit, proj_jiedian_unit)
    local whereStr = ""
    local whereTab = {}
    local whereFuzzyStr = ""
    local whereFuzzyTab = {}
    local totalSql = " select count(proj_code) as total from tb_proj "
    if proj_code ~= nil then
        table.insert(whereTab, string.format(" proj_code='%s'  ", proj_code))
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

    local sql = " update tb_proj  set    "

    if proj_tujian_unit ~= nil then
        if proj_jiedian_unit ~= nil then
            sql = sql .. " proj_tujian_unit='" .. proj_tujian_unit .. "' , proj_jiedian_unit='" .. proj_jiedian_unit .. "' "
        else
            sql = sql .. " proj_tujian_unit='" .. proj_tujian_unit .. "' "
        end
    elseif proj_jiedian_unit ~= nil then
        sql = sql .. " proj_jiedian_unit='" .. proj_jiedian_unit .. "' "
    end

    sql = sql .. " where " .. whereStr .. " returning  proj_code "

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

function _PROJECT.Finelinks_detail_get(proj_link_code, start_time, end_time)
    local sql = " select * from tb_link_fine where 1=1 "
    local likeStr = ""

    if start_time ~= nil and end_time > 0 then
        likeStr = "and fine_time >= " .. tostring(start_time) .. " and fine_time <=  " .. tostring(end_time)
    end

    sql = sql .. likeStr .. " and proj_code = '" .. proj_link_code .. "' order by proj_link_type asc"

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

function _PROJECT.Getproj_module_code(proj_module_name)
    local sql = "select proj_module_code from tb_proj_link_types where proj_module_name = '" .. proj_module_name .. "' group by proj_module_code"

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

function _PROJECT.Finelinks_get(proj_link_ids)
    local ids = table.concat(proj_link_ids, " , ")
    local sql = " select * from tb_proj_link where proj_link_id in ( " .. ids .. ") "

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

function _PROJECT.links_get(proj_link_ids)
    local ids = table.concat(proj_link_ids, " , ")
    local sql = " select * from tb_proj_link where proj_link_id in ( " .. ids .. ") and ( proj_link_status=3 or proj_link_status=5 ) "

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

function _PROJECT.fineItems_get(item_ids, module_order, link_orders)
    local link_ordersStr = nil
    local item_idsStr = nil
    if link_orders ~= nil and #link_orders > 0 then
        link_ordersStr = table.concat(link_orders, " , ")
    end
    if item_ids ~= nil and #item_ids > 0 then
        item_idsStr = table.concat(item_ids, " , ")
    end
    local whereTab = {}
    if item_idsStr ~= nil then
        table.insert(whereTab, " item_id in (" .. item_idsStr .. ") ")
    end
    if link_ordersStr ~= nil then
        table.insert(whereTab, " link_order in (" .. link_ordersStr .. ") ")
    end
    if module_order ~= nil then
        table.insert(whereTab, " module_order = " .. tostring(module_order))
    end
    local whereStr = table.concat(whereTab, " and ")

    local sql = nil
    if whereStr ~= nil and string.len(whereStr) > 0 then
        sql = " select * from tb_fine_item where  " .. whereStr .. " order by module_order asc, link_order asc,item_order asc "
    else
        sql = " select * from tb_fine_item  order by module_order asc, link_order asc,item_order asc "
    end

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

function _PROJECT.fineItemsExt_get(item_ids, module_order, link_orders, fine_ext_items)
    local link_ordersStr = nil
    local item_idsStr = nil
    if link_orders ~= nil and #link_orders > 0 then
        link_ordersStr = table.concat(link_orders, " , ")
    end
    if item_ids ~= nil and #item_ids > 0 then
        item_idsStr = table.concat(item_ids, " , ")
    end
    local whereTab = {}
    if item_idsStr ~= nil then
        table.insert(whereTab, " item_id in (" .. item_idsStr .. ") ")
    end

    --[[
     {
        module_name="环境",
        module_order=5,
        link_order={
                    [1]=0
                  }
      }
    ]]--
    local extItemTab = {}
    if link_ordersStr ~= nil and module_order ~= nil then
        table.insert(extItemTab, string.format(" ( module_order = %d and  link_order in (%s)  ) ", module_order, link_ordersStr))
    end
    for k, v in pairs(fine_ext_items) do
        table.insert(extItemTab, string.format(" ( module_order = %d and  link_order in (%s)  ) ", v["module_order"], table.concat(link_orders, " , ")))
    end
    local extItemStr = table.concat(extItemTab, " or ")
    table.insert(whereTab, string.format("( %s )", extItemStr))

    local whereStr = table.concat(whereTab, " and ")

    local sql = nil
    if whereStr ~= nil and string.len(whereStr) > 0 then
        sql = " select * from tb_fine_item where  " .. whereStr .. " order by module_order asc, link_order asc,item_order asc "
    else
        sql = " select * from tb_fine_item  order by module_order asc, link_order asc,item_order asc "
    end

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

function _PROJECT.linkFined_get(fine_id)
    local sql = " select * from tb_link_fine where  fine_id =" .. tostring(fine_id)

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

function _PROJECT.linksWithId_get(proj_link_id)
    --local ids = table.concat(proj_link_ids," , ")
    local sql = " select * from tb_proj_link where proj_link_id =" .. tostring(proj_link_id)

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

function _PROJECT.linkFine_set(linkTab, userInfo, nowFineData, projInfo, tongjiTab, fine_item_ids, fine_item_extra, fine_item_extra_value, fine_value)
    local sqlTab = {}
    if fine_item_ids == nil or #fine_item_ids < 1 then
        fine_item_ids = "[]"
    else
        fine_item_ids = cjson.encode(fine_item_ids)
    end
    if fine_item_extra == nil then
        fine_item_extra = ""
    end
    if fine_item_extra_value == nil then
        fine_item_extra_value = 0
    end
    local time = math.ceil(ngx.now())

    table.insert(sqlTab, "CREATE OR REPLACE FUNCTION fun_links_fine_update() returns text AS $BODY$")
    table.insert(sqlTab, "BEGIN")
    if nowFineData == nil then
        table.insert(sqlTab, " insert into tb_link_fine(proj_code,proj_module_name,proj_link_name,proj_link_type,proj_link_id,fine_item_ids,fine_item_extra,fine_item_extra_value,fine_time,fine_value ")
        table.insert(sqlTab, ",proj_name, proj_station_type,proj_base_type,proj_tower_type,proj_tujian_unit,proj_jiedian_unit,proj_bu_code,proj_bu_name,proj_company_code,proj_company_name")
        table.insert(sqlTab, ",gc_tj_gj, gc_tj_hnt,gc_tj_dw,gc_tj_qt,gc_jd_cl,gc_jd_gy,gc_yjzl_jd,gc_yjzl_zb,gc_yjzl_zp,cg_tt_cp,cg_tt_az,cg_pt_pt")
        table.insert(sqlTab, ",reviewer_role, reviewer_code,reviewer_name,reviewer_id) values")

        table.insert(sqlTab, string.format("('%s','%s','%s',%d,%d,'%s','%s',%d,%d,%d,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,'%s','%s',%d) ; ", linkTab["proj_code"], linkTab["proj_module_name"], linkTab["proj_link_name"], linkTab["proj_link_type"], linkTab["proj_link_id"], fine_item_ids, fine_item_extra, fine_item_extra_value, time, fine_value, projInfo["proj_name"], projInfo["proj_station_type"], projInfo["proj_base_type"], projInfo["proj_tower_type"], projInfo["proj_tujian_unit"], projInfo["proj_jiedian_unit"], projInfo["proj_bu_code"], projInfo["proj_bu_name"], projInfo["proj_company_code"], projInfo["proj_company_name"], tongjiTab["gc_tj_gj"], tongjiTab["gc_tj_hnt"], tongjiTab["gc_tj_dw"], tongjiTab["gc_tj_qt"], tongjiTab["gc_jd_cl"], tongjiTab["gc_jd_gy"], tongjiTab["gc_yjzl_jd"], tongjiTab["gc_yjzl_zb"], tongjiTab["gc_yjzl_zp"], tongjiTab["cg_tt_cp"], tongjiTab["cg_tt_az"], tongjiTab["cg_pt_pt"], userInfo["user_role_v2"], userInfo["user_code"], userInfo["user_name"], userInfo["user_id"]))
    else
        local copyStr1 = "insert into tb_link_fine_recod(fine_id,proj_code,proj_module_name ,proj_link_name ,proj_link_type  ,proj_link_id  , fine_item_ids,fine_item_extra,fine_item_extra_value,fine_time,fine_value,proj_name,proj_station_type,proj_base_type,proj_tower_type,proj_tujian_unit,proj_jiedian_unit,proj_bu_code,proj_bu_name,proj_company_code,proj_company_name,gc_tj_gj,gc_tj_hnt,gc_tj_dw,gc_tj_qt,gc_jd_cl,gc_jd_gy,gc_yjzl_jd,gc_yjzl_zb,gc_yjzl_zp,cg_tt_cp,cg_tt_az,cg_pt_pt,reviewer_role,reviewer_code,reviewer_name,reviewer_id)"

        local copyStr2 = "select fine_id,proj_code,proj_module_name ,proj_link_name ,proj_link_type  ,proj_link_id  , fine_item_ids,fine_item_extra,fine_item_extra_value,fine_time,fine_value,proj_name,proj_station_type,proj_base_type,proj_tower_type,proj_tujian_unit,proj_jiedian_unit,proj_bu_code,proj_bu_name,proj_company_code,proj_company_name,gc_tj_gj,gc_tj_hnt,gc_tj_dw,gc_tj_qt,gc_jd_cl,gc_jd_gy,gc_yjzl_jd,gc_yjzl_zb,gc_yjzl_zp,cg_tt_cp,cg_tt_az,cg_pt_pt,reviewer_role,reviewer_code,reviewer_name,reviewer_id  from tb_link_fine where fine_id=" .. tostring(nowFineData["fine_id"]) .. ";"
        table.insert(sqlTab, string.format("%s %s", copyStr1, copyStr2))

        table.insert(sqlTab, string.format(" update tb_link_fine set proj_code='%s' ", linkTab["proj_code"]))
        table.insert(sqlTab, string.format(",proj_module_name='%s' ", linkTab["proj_module_name"]))
        table.insert(sqlTab, string.format(",proj_link_name='%s' ", linkTab["proj_link_name"]))
        table.insert(sqlTab, string.format(",proj_link_type=%d ", linkTab["proj_link_type"]))
        table.insert(sqlTab, string.format(",proj_link_id=%d ", linkTab["proj_link_id"]))
        table.insert(sqlTab, string.format(",fine_item_ids='%s' ", fine_item_ids))
        table.insert(sqlTab, string.format(",fine_item_extra='%s' ", fine_item_extra))
        table.insert(sqlTab, string.format(",fine_item_extra_value=%d ", fine_item_extra_value))
        table.insert(sqlTab, string.format(",fine_time=%d ", time))
        table.insert(sqlTab, string.format(",fine_value=%d ", fine_value))
        table.insert(sqlTab, string.format(",proj_name='%s' ", projInfo["proj_name"]))
        table.insert(sqlTab, string.format(",proj_station_type='%s' ", projInfo["proj_station_type"]))
        table.insert(sqlTab, string.format(",proj_base_type='%s' ", projInfo["proj_base_type"]))
        table.insert(sqlTab, string.format(",proj_tower_type='%s' ", projInfo["proj_tower_type"]))
        table.insert(sqlTab, string.format(",proj_tujian_unit='%s' ", projInfo["proj_tujian_unit"]))
        table.insert(sqlTab, string.format(",proj_jiedian_unit='%s' ", projInfo["proj_jiedian_unit"]))
        table.insert(sqlTab, string.format(",proj_bu_code='%s' ", projInfo["proj_bu_code"]))
        table.insert(sqlTab, string.format(",proj_bu_name='%s' ", projInfo["proj_bu_name"]))
        table.insert(sqlTab, string.format(",proj_company_code='%s' ", projInfo["proj_company_code"]))
        table.insert(sqlTab, string.format(",proj_company_name='%s' ", projInfo["proj_company_name"]))
        table.insert(sqlTab, string.format(",gc_tj_gj=%d ", tongjiTab["gc_tj_gj"]))
        table.insert(sqlTab, string.format(",gc_tj_hnt=%d ", tongjiTab["gc_tj_hnt"]))
        table.insert(sqlTab, string.format(",gc_tj_dw=%d ", tongjiTab["gc_tj_dw"]))
        table.insert(sqlTab, string.format(",gc_tj_qt=%d ", tongjiTab["gc_tj_qt"]))
        table.insert(sqlTab, string.format(",gc_jd_cl=%d ", tongjiTab["gc_jd_cl"]))
        table.insert(sqlTab, string.format(",gc_jd_gy=%d ", tongjiTab["gc_jd_gy"]))
        table.insert(sqlTab, string.format(",gc_yjzl_jd=%d ", tongjiTab["gc_yjzl_jd"]))
        table.insert(sqlTab, string.format(",gc_yjzl_zb=%d ", tongjiTab["gc_yjzl_zb"]))
        table.insert(sqlTab, string.format(",gc_yjzl_zp=%d ", tongjiTab["gc_yjzl_zp"]))
        table.insert(sqlTab, string.format(",cg_tt_az=%d ", tongjiTab["cg_tt_az"]))
        table.insert(sqlTab, string.format(",cg_pt_pt=%d ", tongjiTab["cg_pt_pt"]))
        table.insert(sqlTab, string.format(",reviewer_role=%d ", userInfo["user_role_v2"]))
        table.insert(sqlTab, string.format(",reviewer_code='%s' ", userInfo["user_code"]))
        table.insert(sqlTab, string.format(",reviewer_name='%s' ", userInfo["user_name"]))
        table.insert(sqlTab, string.format(",reviewer_id=%d ", userInfo["user_id"]))
        table.insert(sqlTab, string.format(" where fine_id=%d ;", nowFineData["fine_id"]))
    end
    table.insert(sqlTab, "RETURN 1;")
    table.insert(sqlTab, "END;")
    table.insert(sqlTab, "$BODY$")
    table.insert(sqlTab, "language plpgsql;")

    local processCall = " select fun_links_fine_update();"
    local processSql = table.concat(sqlTab, " ")
    return db_query.excute_db_process(processSql, processCall)
end
function _PROJECT.linkFine_get(proj_code, proj_link_type)
    local sql = " select * from tb_link_fine where proj_code='" .. proj_code .. "' and proj_link_type= " .. tostring(proj_link_type)
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

function _PROJECT.linkDescribe_get()
    local sql = "select * from tb_link_describe order by describe_time desc limit 1 "
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

function _PROJECT.linkFine_proj_updata(linkTab, review_status, add_pic_status)
    local time = math.ceil(ngx.now())
    local selsql = nil

    if review_status ~= nil and review_status == true then
        if linkTab["proj_link_status"] == 7 then
            selsql = string.format("update tb_proj_link set proj_link_status = 3 where proj_code = '%s' and proj_link_id = %d;", linkTab["proj_code"], linkTab["proj_link_id"])
        else
            selsql = string.format("update tb_proj_link set proj_link_status = 5 where proj_code = '%s' and proj_link_id = %d;", linkTab["proj_code"], linkTab["proj_link_id"])
        end
    end

    if add_pic_status ~= nil and add_pic_status == true then
        selsql = string.format("update tb_link_fine set reviewer_role = 1299 where proj_code = '%s' and proj_link_id = %d;", linkTab["proj_code"], linkTab["proj_link_id"])
    end


    --comm_func.do_dump_value("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",0)
    comm_func.do_dump_value(selsql, 0)

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local selres = assert(pg:query(selsql))
    pg:keepalive()

    if selres ~= nil then
        return true, selres
    else
        return false
    end
end
function _PROJECT.linkFine_bkup_set(linkTab, fine_item_ids, fine_item_extra, fine_item_extra_value, fine_value, fine_final, review_status)
    if fine_item_ids == nil or #fine_item_ids < 1 then
        fine_item_ids = "[]"
    else
        fine_item_ids = cjson.encode(fine_item_ids)
    end
    if fine_item_extra == nil then
        fine_item_extra = ""
    end
    if fine_item_extra_value == nil then
        fine_item_extra_value = 0
    end
    if fine_value == nil then
        fine_value = 0
    end
    local time = math.ceil(ngx.now())

    local selsql = string.format(" insert into tb_link_fine_bkup(proj_code,proj_module_name,proj_link_name,proj_link_type,proj_link_id,fine_item_ids,fine_item_extra,fine_item_extra_value,fine_time,fine_value,fine_final)values('%s','%s','%s',%d,%d,'%s','%s',%d,%d,%d,%d);", linkTab["proj_code"], linkTab["proj_module_name"], linkTab["proj_link_name"], linkTab["proj_link_type"], linkTab["proj_link_id"], fine_item_ids, fine_item_extra, fine_item_extra_value, time, fine_value, fine_final)
    if review_status ~= nil and review_status == true then
        local upsql = nil
        if linkTab["proj_link_status"] == 7 then
            upsql = string.format("update tb_proj_link set proj_link_status = 3 where proj_code = '%s' and proj_link_id = %d;", linkTab["proj_code"], linkTab["proj_link_id"])
        else
            upsql = string.format("update tb_proj_link set proj_link_status = 5 where proj_code = '%s' and proj_link_id = %d;", linkTab["proj_code"], linkTab["proj_link_id"])
        end
        selsql = selsql .. upsql
    end

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local selres = assert(pg:query(selsql))
    pg:keepalive()

    if selres ~= nil then
        return true, selres
    else
        return false
    end
end
function _PROJECT.linkFine_bkup_check(linkTab)
    local selsql = string.format("select * from tb_link_fine where proj_code = '%s' and proj_link_id = %d;", linkTab["proj_code"], linkTab["proj_link_id"])
    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local selres = assert(pg:query(selsql))
    pg:keepalive()

    if selres ~= nil then
        return true, selres
    else
        return false
    end
end

function _PROJECT.linkFine_bkup_update(proj_code, proj_link_id, add_role_value)
    local selsql = string.format("update tb_link_fine set reviewer_role = %d where proj_code = '%s' and proj_link_id = %d;", add_role_value, proj_code, proj_link_id)
    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local selres = assert(pg:query(selsql))
    pg:keepalive()

    if selres ~= nil then
        return true, selres
    else
        return false
    end
end

function _PROJECT.linkFine_reviewer_role_update(proj_code, proj_link_ids, add_role_value)
    local selsql = string.format("update tb_link_fine set reviewer_role = %d where proj_code = '%s' and proj_link_id in ( %s );", add_role_value, proj_code, proj_link_ids)
    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local selres = assert(pg:query(selsql))
    pg:keepalive()

    if selres ~= nil then
        return true, selres
    else
        return false
    end
end

function _PROJECT.projectFinedList_get(proj_code, proj_bu_code, isAdmin, proj_company_code, proj_bu_code_before, start_time, end_time, limit, offset)
    local whereStr = ""
    local whereTab = {}
    local limitStr = " limit " .. tostring(limit) .. " offset " .. tostring(offset)
    local totalSql = " select count(proj_code) as total from (select proj_code from tb_link_fine  where %s  group by proj_code  )a "

    if proj_code ~= nil then
        table.insert(whereTab, string.format(" proj_code='%s'  ", proj_code))
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
        local likeStr = " proj_company_code = '" .. proj_company_code .. "' "
        table.insert(whereTab, likeStr)
    end
    if proj_bu_code_before ~= nil and proj_bu_code_before ~= "" then
        local likeStr = " proj_bu_code = '" .. proj_bu_code_before .. "' "
        table.insert(whereTab, likeStr)
    end

    if start_time ~= nil and end_time > 0 then
        local likeStr = " fine_time >= " .. tostring(start_time) .. " and fine_time <=  " .. tostring(end_time)
        table.insert(whereTab, likeStr)
    end

    whereStr = table.concat(whereTab, " and ")
    local sql = " select proj_code,min(proj_company_name) as proj_company_name,min(proj_bu_name) as proj_bu_name,min(proj_name) as proj_name,min(proj_station_type) as proj_station_type,min(proj_base_type) as proj_base_type ,min(proj_tower_type) as proj_tower_type ,max(proj_tujian_unit) as proj_tujian_unit,max(proj_jiedian_unit) as proj_jiedian_unit,sum( case when gc_tj_gj<0 then 0 else gc_tj_gj end) as gc_tj_gj,max(gc_tj_gj) as gc_tj_gj_max  ,sum( case when gc_tj_hnt<0 then 0 else gc_tj_hnt end) as gc_tj_hnt,max(gc_tj_hnt) as gc_tj_hnt_max ,sum( case when gc_tj_dw<0 then 0 else gc_tj_dw end) as gc_tj_dw, max(gc_tj_dw) as gc_tj_dw_max,sum( case when gc_tj_qt<0 then 0 else gc_tj_qt end) as gc_tj_qt, max(gc_tj_qt) as gc_tj_qt_max,sum( case when gc_jd_cl<0 then 0 else gc_jd_cl end) as gc_jd_cl, max(gc_jd_cl) as gc_jd_cl_max,sum( case when gc_jd_gy<0 then 0 else gc_jd_gy end) as gc_jd_gy , max(gc_jd_gy) as gc_jd_gy_max,sum( case when gc_yjzl_jd<0 then 0 else gc_yjzl_jd end) as gc_yjzl_jd,max(gc_yjzl_jd) as gc_yjzl_jd_max,sum( case when gc_yjzl_zb<0 then 0 else gc_yjzl_zb end) as gc_yjzl_zb,max(gc_yjzl_zb) as gc_yjzl_zb_max,sum( case when gc_yjzl_zp<0 then 0 else gc_yjzl_zp end) as gc_yjzl_zp,max(gc_yjzl_zp) as gc_yjzl_zp_max,sum( case when cg_tt_cp<0 then 0 else cg_tt_cp end) as cg_tt_cp,max(cg_tt_cp) as cg_tt_cp_max,sum(case when cg_tt_az<0 then 0 else cg_tt_az end ) as cg_tt_az,max(cg_tt_az) as cg_tt_az_max,sum(case  when cg_pt_pt<0 then 0 else cg_pt_pt  end ) as cg_pt_pt,max(cg_pt_pt) as cg_pt_pt_max from tb_link_fine "
    if string.len(whereStr) > 3 then
        sql = sql .. " where " .. whereStr
        totalSql = string.format(totalSql, whereStr)
    end
    local excelSql = sql .. " group by proj_code order by proj_code asc "
    sql = sql .. " group by proj_code order by proj_code asc " .. limitStr
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()
    --comm_func.do_dump_value(whereStr,0)
    --comm_func.do_dump_value(sql,0)
    --comm_func.do_dump_value(totalSql,0)
    if res ~= nil then
        local totalResult, total = _PROJECT.listTotal_get(totalSql)
        if totalResult == true then
            return true, res, #res, total, limit, offset, excelSql
        else
            return false, res
        end
    else
        return false, res
    end
end

function _PROJECT.provinceFinedList_get(proj_bu_code, isAdmin, proj_company_code, start_time, end_time, limit, offset)
    local whereStr = ""
    local whereTab = {}
    local limitStr = " limit " .. tostring(limit) .. " offset " .. tostring(offset)
    local totalSql = " select count(proj_company_code) as total from (select proj_company_code from tb_link_fine  where %s  group by proj_company_code  )a "

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
        local likeStr = " proj_company_code = '" .. proj_company_code .. "' "
        table.insert(whereTab, likeStr)
    end

    if start_time ~= nil and end_time > 0 then
        local likeStr = " fine_time >= " .. tostring(start_time) .. " and fine_time <=  " .. tostring(end_time)
        table.insert(whereTab, likeStr)
    end

    whereStr = table.concat(whereTab, " and ")

    local sql = " select min(proj_company_name) as proj_company_name,sum( case when gc_tj_gj<0 then 0 else gc_tj_gj end) as gc_tj_gj,max(gc_tj_gj) as gc_tj_gj_max  ,sum( case when gc_tj_hnt<0 then 0 else gc_tj_hnt end) as gc_tj_hnt,max(gc_tj_hnt) as gc_tj_hnt_max ,sum( case when gc_tj_dw<0 then 0 else gc_tj_dw end) as gc_tj_dw, max(gc_tj_dw) as gc_tj_dw_max,sum( case when gc_tj_qt<0 then 0 else gc_tj_qt end) as gc_tj_qt, max(gc_tj_qt) as gc_tj_qt_max,sum( case when gc_jd_cl<0 then 0 else gc_jd_cl end) as gc_jd_cl, max(gc_jd_cl) as gc_jd_cl_max,sum( case when gc_jd_gy<0 then 0 else gc_jd_gy end) as gc_jd_gy , max(gc_jd_gy) as gc_jd_gy_max,sum( case when gc_yjzl_jd<0 then 0 else gc_yjzl_jd end) as gc_yjzl_jd,max(gc_yjzl_jd) as gc_yjzl_jd_max,sum( case when gc_yjzl_zb<0 then 0 else gc_yjzl_zb end) as gc_yjzl_zb,max(gc_yjzl_zb) as gc_yjzl_zb_max,sum( case when gc_yjzl_zp<0 then 0 else gc_yjzl_zp end) as gc_yjzl_zp,max(gc_yjzl_zp) as gc_yjzl_zp_max,sum( case when cg_tt_cp<0 then 0 else cg_tt_cp end) as cg_tt_cp,max(cg_tt_cp) as cg_tt_cp_max,sum(case when cg_tt_az<0 then 0 else cg_tt_az end ) as cg_tt_az,max(cg_tt_az) as cg_tt_az_max,sum(case  when cg_pt_pt<0 then 0 else cg_pt_pt  end ) as cg_pt_pt,max(cg_pt_pt) as cg_pt_pt_max from tb_link_fine "
    if string.len(whereStr) > 3 then
        sql = sql .. " where " .. whereStr
        totalSql = string.format(totalSql, whereStr)
    end
    local excelSql = sql .. " group by proj_company_code order by proj_company_code asc "
    sql = sql .. " group by proj_company_code order by proj_company_code asc " .. limitStr
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _PROJECT.listTotal_get(totalSql)
        if totalResult == true then
            return true, res, #res, total, limit, offset, excelSql
        else
            return false, res
        end
    else
        return false, res
    end
end

function _PROJECT.projectLinkPicAddFlag_set(proj_link_id, number)
    local selsql = string.format(" update tb_proj_link set proj_link_pic_add_number=%d where proj_link_id=%d returning tb_proj_link ", number, proj_link_id)
    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local selres = assert(pg:query(selsql))
    pg:keepalive()

    if selres ~= nil then
        return true, selres
    else
        return false
    end
end

return _PROJECT


