local _SYNC = {}

function _SYNC.get_new_pgmoon_connection()
    local host_value = conf_sys.erp_sync_db["host_value"]
    local port_value = conf_sys.erp_sync_db["port_value"]
    local database_value = conf_sys.erp_sync_db["database_value"]
    local user_value = conf_sys.erp_sync_db["user_value"]
    local password_value = conf_sys.erp_sync_db["password_value"]
    --comm_func.do_dump_value(conf_sys.erp_sync_db,0)
    local pg = pgmoon.new({
        host = host_value,
        port = port_value,
        database = database_value,
        user = user_value,
        password = password_value
    })
    return pg
end

function _SYNC.excute(sql)
    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        return true, res
    else
        return false, res
    end
end

function _SYNC.listTotal_get(sqlStr)

    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res[1]["total"]
    else
        return false, res
    end
end

function _SYNC.linkSynced_delete()
    local sql = " delete from tb_sync_link where read_status = '1' "

    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    --comm_func.do_dump_value(sql,0)
    local res = assert(pg:query(sql))
    pg:keepalive()
    pg = nil

    if res ~= nil then
        return true, res
    else
        return false
    end
end

function _SYNC.linkModuleSyncAdapteERP_exsit(proj_code)
    local sql = string.format(" select * from tb_sync_link where proj_code= '%s' ", proj_code)

    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    --comm_func.do_dump_value(sql,0)
    local res = assert(pg:query(sql))
    pg:keepalive()
    pg = nil
    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] == proj_code then
        return true
    end
    return false
end

function _SYNC.linkSync_add(linkTab)
    local timeReviewed = os.date("%Y-%m-%d %H:%M:%S", linkTab["proj_link_review_time"])
    local sqlAdd = string.format(" insert into tb_sync_link(proj_code,module_name,link_name,reviewed_time)  values('%s','%s','%s','%s') returning  proj_code ", linkTab["proj_code"], linkTab["proj_module_name"], linkTab["proj_link_name"], timeReviewed)
    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlAdd))
    pg:keepalive()
    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        db_project.linkSynced_update(linkTab["proj_link_id"])
        return true, res
    else
        return false
    end
end

function _SYNC.linkModuleSync_add(linkTab)
    local timeReviewed = os.date("%Y-%m-%d %H:%M:%S", linkTab["time"])
    local status, mudleToalCount = db_project.linkModuleCount_get(linkTab["proj_code"], linkTab["proj_module_name"])
    if status == true and linkTab["passed_count"] >= mudleToalCount then
        local module_name = linkTab["proj_module_name"]
        if module_name == "塔桅安装" then
            module_name = "铁塔设备安装完工时间"
            module_name = "vreserve11"
        elseif module_name == "接电施工" then
            module_name = "接电完成时间"
            module_name = "vreserve14"
        elseif module_name == "配套安装" then
            module_name = "配套完成时间"
            module_name = "vreserve15"
        elseif module_name == "竣工交维" then
            module_name = "竣工验收时间"
            module_name = "vreserve16"
        elseif module_name == "拆站" then
            module_name = "拆站完成时间"
            module_name = "vreserve19"
        elseif module_name == "安装电表" then
            module_name = "安装电表完成时间"
            module_name = "vreserve20"
        elseif module_name == "并购" then
            module_name = "并购完成时间"
            module_name = "vreserve21"
        elseif module_name == "改造" then
            module_name = "改造完成时间"
            module_name = "vreserve22"
            --fixed by zhangjieqiong for gaizao 20200523 未验证
        elseif module_name == "交付验收" then
            module_name = "交付验收完成时间"
            module_name = "vreserve23"
            --fixed by zhangjieqiong for gaizao 20200820 未验证
        end
        local sqlAdd = string.format(" insert into tb_sync_link(proj_code,moudle_name,moudle_time)  values('%s','%s','%s') returning  proj_code ", linkTab["proj_code"], module_name, timeReviewed)
        local pg = _SYNC.get_new_pgmoon_connection()

        assert(pg:connect())
        local res = assert(pg:query(sqlAdd))
        pg:keepalive()
        if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
            db_project.linkModuleSynced_update(linkTab["proj_code"], linkTab["proj_module_name"])
            return true, res
        else
            return false
        end
    end
end

function _SYNC.linkModuleSyncAdapteERP_add(linkTab)
    local timeReviewed = os.date("%Y-%m-%d %H:%M:%S", linkTab["time"])
    local status, mudleToalCount = db_project.linkModuleCount_get(linkTab["proj_code"], linkTab["proj_module_name"])
    if status == true and linkTab["passed_count"] >= mudleToalCount then
        local module_name = linkTab["proj_module_name"]
        if module_name == "塔桅安装" then
            module_name = "铁塔设备安装完工时间"
            module_name = "vreserve11"
        elseif module_name == "接电施工" then
            module_name = "接电完成时间"
            module_name = "vreserve14"
        elseif module_name == "配套安装" then
            module_name = "配套完成时间"
            module_name = "vreserve15"
        elseif module_name == "竣工交维" then
            module_name = "竣工验收时间"
            module_name = "vreserve16"
        elseif module_name == "拆站" then
            module_name = "拆站完成时间"
            module_name = "vreserve19"
        elseif module_name == "安装电表" then
            module_name = "安装电表完成时间"
            module_name = "vreserve20"
        elseif module_name == "并购" then
            module_name = "并购完成时间"
            module_name = "vreserve21"
        elseif module_name == "改造" then
            module_name = "改造完成时间"
            module_name = "vreserve22"
            --fixed by zhangjieqiong for gaizao 20200523 未验证
        elseif module_name == "交付验收" then
            module_name = "交付验收完成时间"
            module_name = "vreserve23"
            --fixed by zhangjieqiong for gaizao 20200820 未验证
        end
        local sqlStr
        if _SYNC.linkModuleSyncAdapteERP_exsit(linkTab["proj_code"]) == true then
            sqlStr = string.format(" update tb_sync_link set %s='%s',read_status='0'  where  proj_code='%s'  returning  proj_code ", module_name, timeReviewed, linkTab["proj_code"])
        else
            sqlStr = string.format(" insert into tb_sync_link(proj_code,%s)  values('%s','%s') returning  proj_code ", module_name, linkTab["proj_code"], timeReviewed)
        end
        local pg = _SYNC.get_new_pgmoon_connection()

        assert(pg:connect())
        local res = assert(pg:query(sqlStr))
        pg:keepalive()
        if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
            db_project.linkModuleSynced_update(linkTab["proj_code"], linkTab["proj_module_name"])
            return true, res
        else
            return false
        end
    end
end

function _SYNC.linkTuJianModuleSync_add(linkTab)
    local timeReviewed = os.date("%Y-%m-%d %H:%M:%S", linkTab["time"])
    local status, mudleToalCount = db_project.linkTuJianModuleCount_get(linkTab["proj_code"], linkTab["proj_module_name"])
    if status == true and linkTab["passed_count"] >= mudleToalCount then
        local module_name = linkTab["proj_module_name"]
        if module_name == "土建施工" then
            module_name = "土建完工时间"
            module_name = "vreserve8"
        end
        local sqlAdd = string.format(" insert into tb_sync_link(proj_code,moudle_name,moudle_time)  values('%s','%s','%s') returning  proj_code ", linkTab["proj_code"], module_name, timeReviewed)
        local pg = _SYNC.get_new_pgmoon_connection()

        assert(pg:connect())
        local res = assert(pg:query(sqlAdd))
        pg:keepalive()
        if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
            db_project.linkModuleSynced_update(linkTab["proj_code"], linkTab["proj_module_name"])
            return true, res
        else
            return false
        end
    end
end

function _SYNC.linkTuJianModuleSyncApateERP_add(linkTab)
    local timeReviewed = os.date("%Y-%m-%d %H:%M:%S", linkTab["time"])
    local status, mudleToalCount = db_project.linkTuJianModuleCount_get(linkTab["proj_code"], linkTab["proj_module_name"])
    if status == true and linkTab["passed_count"] >= mudleToalCount then
        local module_name = linkTab["proj_module_name"]
        if module_name == "土建施工" then
            module_name = "土建完工时间"
            module_name = "vreserve8"
        end
        local sqlStr
        if _SYNC.linkModuleSyncAdapteERP_exsit(linkTab["proj_code"]) == true then
            sqlStr = string.format(" update tb_sync_link set %s='%s',read_status='0'  where  proj_code='%s'  returning  proj_code ", module_name, timeReviewed, linkTab["proj_code"])
        else
            sqlStr = string.format(" insert into tb_sync_link(proj_code,%s)  values('%s','%s') returning  proj_code ", module_name, linkTab["proj_code"], timeReviewed)
        end
        local pg = _SYNC.get_new_pgmoon_connection()

        assert(pg:connect())
        local res = assert(pg:query(sqlStr))
        pg:keepalive()
        if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
            db_project.linkModuleSynced_update(linkTab["proj_code"], linkTab["proj_module_name"])
            return true, res
        else
            return false
        end
    end
end

function _SYNC.link1TuJianModlueSync_add(linkTab)
    local timeReviewed = os.date("%Y-%m-%d %H:%M:%S", linkTab["proj_link_review_time"])
    local module_name = linkTab["proj_link_name"]
    if module_name == "施工进场" then
        module_name = "施工进场时间"
        module_name = "vreserve7"
    end
    local sqlAdd = string.format(" insert into tb_sync_link(proj_code,moudle_name,moudle_time)  values('%s','%s','%s') returning  proj_code ", linkTab["proj_code"], module_name, timeReviewed)
    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlAdd))
    pg:keepalive()
    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        db_project.linkSynced_update(linkTab["proj_link_id"])
        return true, res
    else
        return false
    end
end

function _SYNC.link1TuJianModlueSyncAdapteERP_add(linkTab)
    local timeReviewed = os.date("%Y-%m-%d %H:%M:%S", linkTab["proj_link_review_time"])
    local module_name = linkTab["proj_link_name"]
    if module_name == "施工进场" then
        module_name = "施工进场时间"
        module_name = "vreserve7"
    end
    local sqlStr
    if _SYNC.linkModuleSyncAdapteERP_exsit(linkTab["proj_code"]) == true then
        sqlStr = string.format(" update tb_sync_link set %s='%s',read_status='0'  where  proj_code='%s'  returning  proj_code ", module_name, timeReviewed, linkTab["proj_code"])
    else
        sqlStr = string.format(" insert into tb_sync_link(proj_code,%s)  values('%s','%s') returning  proj_code ", module_name, linkTab["proj_code"], timeReviewed)
    end
    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()
    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        db_project.linkSynced_update(linkTab["proj_link_id"])
        return true, res
    else
        return false
    end
end

function _SYNC.userSyncList_get(limit, offset)
    local nowTime = ngx.now()
    local now_tmst = os.date("%Y-%m-%d", nowTime - 432000)

    local sqlTotal = "  select count(user_number) as total from tb_sync_user  where read_status ='0'  and user_change_time > '" .. now_tmst .. "' "
    local sql = string.format(" select * from tb_sync_user where read_status ='0' and user_change_time > '" .. now_tmst .. "'  limit %d offset %d ", limit, offset)
    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _SYNC.listTotal_get(sqlTotal)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false
    end
end

function _SYNC.userSynced_update(userTab)
    local sql = string.format(" update tb_sync_user set read_status = '1' where user_number='%s' ", userTab["user_number"])
    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()
    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false
    end
end

function _SYNC.projectSyncList_get(limit, offset)
    local nowTime = ngx.now()
    nowTime = nowTime - 172800

    local sqlTotal = "  select count(proj_code) as total from tb_sync_proj  where (read_status ='0' or read_status ='2')  and insert_time > " .. tostring(nowTime)
    local sql = string.format(" select * from tb_sync_proj where (read_status ='0' or read_status ='2' ) and insert_time > " .. tostring(nowTime) .. " order by insert_time desc   limit %d offset %d ", limit, offset)

    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()

    if res ~= nil then
        local totalResult, total = _SYNC.listTotal_get(sqlTotal)
        if totalResult == true then
            return true, res, #res, total, limit, offset
        else
            return false, res
        end
    else
        return false
    end
end

function _SYNC.projectSynced_update(projectTab)
    local sql = string.format(" update tb_sync_proj set read_status = '1' where proj_code='%s' ", projectTab["proj_code"])
    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sql))
    pg:keepalive()
    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false
    end
end

function _SYNC.projectSynced_delete()
    local sql = " delete from tb_sync_proj where read_status = '1' "

    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    --comm_func.do_dump_value(sql,0)
    local res = assert(pg:query(sql))
    pg:keepalive()
    pg = nil

    if res ~= nil then
        return true, res
    else
        return false
    end
end
function _SYNC.userSynced_delete()
    local sql = " delete from tb_sync_user where read_status = '1' "

    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    --comm_func.do_dump_value(sql,0)
    local res = assert(pg:query(sql))
    pg:keepalive()
    pg = nil

    if res ~= nil then
        return true, res
    else
        return false
    end
end

function _SYNC.pushMsgList_get()
    local sql = " select * from tb_sync_push_msg where read_status ='0' order by msg_send_time asc limit 100  "

    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    --comm_func.do_dump_value(sql,0)
    local res = assert(pg:query(sql))
    pg:keepalive()
    pg = nil

    if res ~= nil then
        return true, res
    else
        return false
    end
end
function _SYNC.pushMsgReadStatus_update(pk_msg)
    local sql = " update  tb_sync_push_msg set read_status='1' where pk_msg= " .. tostring(pk_msg)

    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    --comm_func.do_dump_value(sql,0)
    local res = assert(pg:query(sql))
    pg:keepalive()
    pg = nil

    if res ~= nil then
        return true, res
    else
        return false
    end
end

function _SYNC.pushMsgReadStatus_updateNotSend(pk_msg)
    local sql = " update  tb_sync_push_msg set read_status='2' where pk_msg= " .. tostring(pk_msg)

    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    --comm_func.do_dump_value(sql,0)
    local res = assert(pg:query(sql))
    pg:keepalive()
    pg = nil

    if res ~= nil then
        return true, res
    else
        return false
    end
end

--add by gu.qinghuan@gd-iot.com 20180423
function _SYNC.linkModuleOkSync_add(linkTab)
    local module_name = linkTab["proj_module_name"]
    local timeReviewed = os.date("%Y-%m-%d %H:%M:%S", linkTab["proj_link_review_time"])
    if linkTab["proj_link_type"] == 25 then
        module_name = "施工进场时间"
        module_name = "vreserve7"
    elseif linkTab["proj_link_type"] == 26 then
        module_name = "土建完工时间"
        module_name = "vreserve8"
    elseif linkTab["proj_link_type"] == 17 then
        module_name = "铁塔设备安装完工时间"
        module_name = "vreserve11"
    elseif linkTab["proj_link_type"] == 23 then
        module_name = "配套完成时间"
        module_name = "vreserve15"
    elseif linkTab["proj_link_type"] == 24 then
        module_name = "竣工验收时间"
        module_name = "vreserve16"
    elseif linkTab["proj_link_type"] == 27 then
        module_name = "拆站完成时间"
        module_name = "vreserve19"
    elseif linkTab["proj_link_type"] == 28 then
        module_name = "安装电表完成时间"
        module_name = "vreserve20"
    elseif linkTab["proj_link_type"] == 29 then
        module_name = "并购完成时间"
        module_name = "vreserve21"
    elseif linkTab["proj_link_type"] == 33 then
        module_name = "改造完成时间"
        module_name = "vreserve22"
    elseif linkTab["proj_link_type"] == 35 then
        module_name = "交付验收完成时间"
        module_name = "vreserve23"
    end

    local sqlAdd = string.format(" insert into tb_sync_link(proj_code,moudle_name,moudle_time)  values('%s','%s','%s') returning  proj_code ", linkTab["proj_code"], module_name, timeReviewed)
    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlAdd))
    pg:keepalive()
    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        db_project.linkModuleLinkSynced_update(linkTab["proj_link_id"])
        return true, res
    else
        return false
    end
end
function _SYNC.linkModuleJieDianOkSync_add(linkTab)
    local module_name = linkTab["proj_module_name"]
    local timeReviewed = os.date("%Y-%m-%d %H:%M:%S", linkTab["proj_link_review_time"])
    if linkTab["proj_module_name_count"] > 1 then
        module_name = "接电完成时间"
        module_name = "vreserve14"
    else
        return false
    end

    local sqlAdd = string.format(" insert into tb_sync_link(proj_code,moudle_name,moudle_time)  values('%s','%s','%s') returning  proj_code ", linkTab["proj_code"], module_name, timeReviewed)
    local pg = _SYNC.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlAdd))
    pg:keepalive()
    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        db_project.linkModuleSynced_update(linkTab["proj_code"], linkTab["proj_module_name"])
        return true, res
    else
        return false
    end
end
--end

return _SYNC


