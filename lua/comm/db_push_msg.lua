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

function _PROJECT.msgDb_push(user_id, proj_code, linksTab, linkStatus)
    local user_number = ""
    local user_name = ""
    local user_company_code = ""
    local user_bu_code = ""
    local receivers = ""
    local receiversTab = {}
    local receiversStr = ""
    local receiversTabIndex = 1
    local linkStatusTitleTab = {}
    linkStatusTitleTab[1] = "上传提交"
    linkStatusTitleTab[2] = "审核不通过"
    linkStatusTitleTab[3] = "审核通过"
    linkStatusTitleTab[4] = "审核不通过并且留档"
    linkStatusTitleTab[5] = "条件通过"
    linkStatusTitleTab[7] = "审核通过待扣款"
    linkStatusTitleTab[8] = "条件通过待扣款"

    local status, resultData = db_query.userFromId_get(user_id)
    if status == true and resultData ~= nil and resultData[1] ~= nil then
        user_number = resultData[1]["user_number"]
        user_name = resultData[1]["user_name"]
        user_company_code = resultData[1]["user_company_code"]
        user_bu_code = resultData[1]["user_bu_code"]
    end
    local projstatus, projapps = db_query.projectList_get(proj_code, nil, nil, nil, nil, nil, nil, nil, nil, true, 1, 0)
    if projstatus == true and projapps ~= nil and projapps[1] ~= nil then
        user_bu_code = projapps[1]["proj_bu_code"]
    end

    local receiverStatus, receiverApps = db_user.userMsgReceiverList_get(user_company_code, user_bu_code)
    if receiverStatus == true then
        for appsk, appsv in pairs(receiverApps) do
            local receiver = {}
            receiver["user_id"] = appsv["user_id"]
            receiver["user_number"] = appsv["user_number"]
            receiver["user_name"] = appsv["user_name"]
            receiver["view_status"] = 0
            receiver["view_time"] = 0
            receiversTab[receiversTabIndex] = receiver
            receiversTabIndex = receiversTabIndex + 1
        end
    end
    if true then
        local receiverStatus, receiverApps = db_user.userMsgReceiverListFromJianLi_get()
        if receiverStatus == true then
            for appsk, appsv in pairs(receiverApps) do
                local receiver = {}
                receiver["user_id"] = appsv["user_id"]
                receiver["user_number"] = appsv["user_number"]
                receiver["user_name"] = appsv["user_name"]
                receiver["view_status"] = 0
                receiver["view_time"] = 0
                receiversTab[receiversTabIndex] = receiver
                receiversTabIndex = receiversTabIndex + 1
            end
        end
    end
    receiversStr = cjson.encode(receiversTab)

    for appsk, appsv in pairs(linksTab) do
        local proj_link_name = appsv["proj_link_name"]
        local proj_module_name = appsv["proj_module_name"]
        if proj_module_name == nil or proj_link_name == nil then
            local linkstatus, linkApps = db_project.link_get(appsv["proj_link_id"])
            --comm_func.do_dump_value(linkApps,0)
            if linkApps ~= nil and linkApps[1] ~= nil then
                proj_link_name = linkApps[1]["proj_link_name"]
                proj_module_name = linkApps[1]["proj_module_name"]
            end
            --comm_func.do_dump_value(proj_link_name,0)
        end

        local pg = _PROJECT.get_new_pgmoon_connection()
        assert(pg:connect())
        local notTime = math.ceil(ngx.now())

        local title = nil
        if linkStatus ~= nil then
            title = string.format("%s->%s->%s,%s", proj_code, proj_module_name, proj_link_name, linkStatusTitleTab[linkStatus])
        else
            title = string.format("%s->%s->%s,%s", proj_code, proj_module_name, proj_link_name, linkStatusTitleTab[appsv["proj_link_status"]])
        end
        local content_type = "text"
        local contentTab = {}
        contentTab["msg"] = user_name .. "操作"
        local extras = {}
        if linkStatus == 1 then
            contentTab["user_name"] = user_name
            contentTab["user_id"] = appsv["user_id"]
            contentTab["user_number"] = appsv["user_number"]
            contentTab["proj_link_status"] = linkStatus

            contentTab["proj_code"] = proj_code
            contentTab["proj_module_name"] = proj_module_name
            contentTab["proj_link_name"] = proj_link_name
            contentTab["proj_link_id"] = tonumber(appsk)
            contentTab["type"] = 0

            extras["proj_code"] = proj_code
            extras["proj_module_name"] = proj_module_name
            extras["proj_link_name"] = proj_link_name
            extras["sender_id"] = 0
            extras["send_time"] = notTime
            extras["type"] = 0
            extras = cjson.encode(extras)
        else
            contentTab["user_name"] = user_name
            contentTab["user_id"] = user_id
            contentTab["user_number"] = user_number
            contentTab["proj_link_status"] = linkStatus

            contentTab["proj_code"] = proj_code
            contentTab["proj_module_name"] = proj_module_name
            contentTab["proj_link_name"] = proj_link_name
            contentTab["proj_link_id"] = appsv["proj_link_id"]
            contentTab["type"] = 0

            extras["proj_code"] = proj_code
            extras["proj_module_name"] = proj_module_name
            extras["proj_link_name"] = proj_link_name
            extras["sender_id"] = 0
            extras["send_time"] = notTime
            extras["type"] = 0
            extras = cjson.encode(extras)
        end

        local contentStr = cjson.encode(contentTab)
        local sqlStr = string.format(" insert into tb_push_msg(send_time,sender_id,receivers,title,content_type,content,extras) values(%d,%d,'%s','%s','%s','%s','%s')  ", notTime, 0, receiversStr, title, content_type, contentStr, extras)
        local res = assert(pg:query(sqlStr))
        pg:keepalive()
    end
end

function _PROJECT.projectProgressUpdateMsgDb_notify(user_id, proj_code, linksTab, linkStatus)
    _PROJECT.msgDb_push(user_id, proj_code, linksTab, linkStatus)
end

function _PROJECT.projectLinkPicAddFlag_changed(user_id, proj_code, linksTab, proj_link_pic_add_number)
    local user_number = ""
    local user_name = ""
    local user_company_code = ""
    local user_bu_code = ""
    local receivers = ""
    local receiversTab = {}
    local receiversStr = ""
    local receiversTabIndex = 1
    local linkStatusTitleTab = {}
    linkStatusTitleTab[1] = "上传提交"
    linkStatusTitleTab[2] = "审核不通过"
    linkStatusTitleTab[3] = "审核通过"
    linkStatusTitleTab[4] = "审核不通过并且留档"
    linkStatusTitleTab[5] = "条件通过"
    linkStatusTitleTab[7] = "审核通过待扣款"
    linkStatusTitleTab[8] = "条件通过待扣款"

    local linkStatus = linksTab[1]["proj_status"]

    local status, resultData = db_query.userFromId_get(user_id)
    if status == true and resultData ~= nil and resultData[1] ~= nil then
        user_number = resultData[1]["user_number"]
        user_name = resultData[1]["user_name"]
        user_company_code = resultData[1]["user_company_code"]
        user_bu_code = resultData[1]["user_bu_code"]
    end
    local projstatus, projapps = db_query.projectList_get(proj_code, nil, nil, nil, nil, nil, nil, nil, nil, true, 1, 0)
    if projstatus == true and projapps ~= nil and projapps[1] ~= nil then
        user_bu_code = projapps[1]["proj_bu_code"]
    end

    local receiverStatus, receiverApps = db_user.userMsgReceiverList_get(user_company_code, user_bu_code)
    if receiverStatus == true then
        for appsk, appsv in pairs(receiverApps) do
            local receiver = {}
            receiver["user_id"] = appsv["user_id"]
            receiver["user_number"] = appsv["user_number"]
            receiver["user_name"] = appsv["user_name"]
            receiver["view_status"] = 0
            receiver["view_time"] = 0
            receiversTab[receiversTabIndex] = receiver
            receiversTabIndex = receiversTabIndex + 1
        end
    end
    if true then
        local receiverStatus, receiverApps = db_user.userMsgReceiverListFromJianLi_get()
        if receiverStatus == true then
            for appsk, appsv in pairs(receiverApps) do
                local receiver = {}
                receiver["user_id"] = appsv["user_id"]
                receiver["user_number"] = appsv["user_number"]
                receiver["user_name"] = appsv["user_name"]
                receiver["view_status"] = 0
                receiver["view_time"] = 0
                receiversTab[receiversTabIndex] = receiver
                receiversTabIndex = receiversTabIndex + 1
            end
        end
    end
    receiversStr = cjson.encode(receiversTab)

    for appsk, appsv in pairs(linksTab) do
        local proj_link_name = appsv["proj_link_name"]
        local proj_module_name = appsv["proj_module_name"]
        if proj_module_name == nil or proj_link_name == nil then
            local linkstatus, linkApps = db_project.link_get(appsv["proj_link_id"])
            --comm_func.do_dump_value(linkApps,0)
            if linkApps ~= nil and linkApps[1] ~= nil then
                proj_link_name = linkApps[1]["proj_link_name"]
                proj_module_name = linkApps[1]["proj_module_name"]
            end
            --comm_func.do_dump_value(proj_link_name,0)
        end

        local pg = _PROJECT.get_new_pgmoon_connection()
        assert(pg:connect())
        local notTime = math.ceil(ngx.now())

        local title = nil
        if linkStatus ~= nil then
            if proj_link_pic_add_number > 0 then
                title = string.format("%s->%s->%s,%s环节可追加%d张照片", proj_code, proj_module_name, proj_link_name, linkStatusTitleTab[linkStatus], proj_link_pic_add_number)
            else
                title = string.format("%s->%s->%s,%s环节不可追加照片", proj_code, proj_module_name, proj_link_name, linkStatusTitleTab[linkStatus])
            end
        else
            if proj_link_pic_add_number > 0 then
                title = string.format("%s->%s->%s,%s环节可追加%d张照片", proj_code, proj_module_name, proj_link_name, linkStatusTitleTab[appsv["proj_link_status"]], proj_link_pic_add_number)
            else
                title = string.format("%s->%s->%s,%s环节不可追加照片", proj_code, proj_module_name, proj_link_name, linkStatusTitleTab[appsv["proj_link_status"]])
            end
        end
        local content_type = "text"
        local contentTab = {}
        contentTab["msg"] = user_name .. "操作"
        local extras = {}
        if linkStatus == 1 then
            contentTab["user_name"] = user_name
            contentTab["user_id"] = appsv["user_id"]
            contentTab["user_number"] = appsv["user_number"]
            contentTab["proj_link_status"] = linkStatus

            contentTab["proj_code"] = proj_code
            contentTab["proj_module_name"] = proj_module_name
            contentTab["proj_link_name"] = proj_link_name
            contentTab["proj_link_id"] = tonumber(appsk)
            contentTab["type"] = 0

            extras["proj_code"] = proj_code
            extras["proj_module_name"] = proj_module_name
            extras["proj_link_name"] = proj_link_name
            extras["sender_id"] = 0
            extras["send_time"] = notTime
            extras["type"] = 0
            extras = cjson.encode(extras)
        else
            contentTab["user_name"] = user_name
            contentTab["user_id"] = user_id
            contentTab["user_number"] = user_number
            contentTab["proj_link_status"] = linkStatus

            contentTab["proj_code"] = proj_code
            contentTab["proj_module_name"] = proj_module_name
            contentTab["proj_link_name"] = proj_link_name
            contentTab["proj_link_id"] = appsv["proj_link_id"]
            contentTab["type"] = 0

            extras["proj_code"] = proj_code
            extras["proj_module_name"] = proj_module_name
            extras["proj_link_name"] = proj_link_name
            extras["sender_id"] = 0
            extras["send_time"] = notTime
            extras["type"] = 0
            extras = cjson.encode(extras)
        end

        local contentStr = cjson.encode(contentTab)
        local sqlStr = string.format(" insert into tb_push_msg(send_time,sender_id,receivers,title,content_type,content,extras) values(%d,%d,'%s','%s','%s','%s','%s')  ", notTime, 0, receiversStr, title, content_type, contentStr, extras)
        local res = assert(pg:query(sqlStr))
        pg:keepalive()
    end
end

function _PROJECT.msgPushUnsend_get()
    local pg = _PROJECT.get_new_pgmoon_connection()
    local sqlStr = "select * from tb_push_msg where sent_time = 0   and  call_api_result = ''  order by send_time asc limit 1000 "
    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end
function _PROJECT.msgPushSent_update(cid, msg_id, resultApi)
    local pg = _PROJECT.get_new_pgmoon_connection()
    local notTime = math.ceil(ngx.now())
    local sqlStr = nil
    if resultApi == nil then
        sqlStr = string.format(" update tb_push_msg set msg_id='%s', sent_time =%d where cid=%d ", msg_id, notTime, cid)
    else
        sqlStr = string.format(" update tb_push_msg set  call_api_result ='%s'  where cid=%d ", resultApi, cid)
    end
    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _PROJECT.msgPushList_get(user_id, cids, cid_max, limit, offset)
    local pg = _PROJECT.get_new_pgmoon_connection()
    local whereTab = {}
    table.insert(whereTab, string.format(" receivers like '%%\"user_id\":%s,\"view_time\":0,\"view_status\":0%%'  ", tostring(user_id)))
    --comm_func.do_dump_value(cid_max,0)
    --comm_func.do_dump_value(cids,0)
    if cids ~= nil then
        if cid_max ~= nil then
            table.insert(whereTab, string.format(" ( cid in ( %s ) or cid > %d ) ", cids, cid_max))
        else
            table.insert(whereTab, string.format(" cid in ( %s )  ", cids))
        end
    elseif cid_max ~= nil then
        table.insert(whereTab, string.format(" cid > %d  ", cid_max))
    end

    local sqlStr = string.format(" select cid,msg_id,sent_time,send_time,sender_id,sender_number,sender_name,title,content_type,content,extras,receivers from tb_push_msg where %s order by send_time asc limit %d  offset %d ", table.concat(whereTab, " and "), limit, offset)
    local totalSql = string.format(" select count(*) as total from tb_push_msg where %s  ", table.concat(whereTab, " and "))
    --comm_func.do_dump_value(cid_max,0)
    --comm_func.do_dump_value(totalSql,0)
    local pg = _PROJECT.get_new_pgmoon_connection()

    assert(pg:connect())
    local res = assert(pg:query(sqlStr))
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

function _PROJECT.usermsgDb_push(user_id, user_ids, title, content, content_type)
    local user_number = ""
    local user_name = ""
    local user_company_code = ""
    local user_bu_code = ""
    local receivers = ""
    local receiversTab = {}
    local receiversStr = ""
    local receiversTabIndex = 1
    title = comm_func.sql_singleQuotationMarks(title)

    local status, resultData = db_query.userFromId_get(user_id)
    if status == true and resultData ~= nil and resultData[1] ~= nil then
        user_number = resultData[1]["user_number"]
        user_name = resultData[1]["user_name"]
        user_company_code = resultData[1]["user_company_code"]
        user_bu_code = resultData[1]["user_bu_code"]
    end

    local receiverStatus, receiverApps = db_user.userMsgReceiverListFromIds_get(table.concat(user_ids, ","))
    if receiverStatus == true then
        for appsk, appsv in pairs(receiverApps) do
            local receiver = {}
            receiver["user_id"] = appsv["user_id"]
            receiver["user_number"] = appsv["user_number"]
            receiver["user_name"] = appsv["user_name"]
            receiver["view_status"] = 0
            receiver["view_time"] = 0
            receiversTab[receiversTabIndex] = receiver
            receiversTabIndex = receiversTabIndex + 1
        end
    end
    receiversStr = cjson.encode(receiversTab)

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local notTime = math.ceil(ngx.now())

    local contentTab = comm_func.table_clone(content)
    local extras = {}

    if content_type == "text" then
        contentTab["type"] = 10
        extras["type"] = 10
    else
        contentTab["type"] = 11
        extras["type"] = 11
    end
    extras["title"] = title

    extras["sender_id"] = user_id
    extras["send_time"] = notTime

    extras = cjson.encode(extras)

    local contentStr = cjson.encode(contentTab)
    contentStr = comm_func.sql_singleQuotationMarks(contentStr)
    local sqlStr = string.format(" insert into tb_push_msg(send_time,sender_id,sender_number,sender_name,receivers,title,content_type,content,extras) values(%d,%d,'%s','%s','%s','%s','%s','%s','%s')  ", notTime, user_id, user_number, user_name, receiversStr, title, content_type, contentStr, extras)
    local res = assert(pg:query(sqlStr))
    pg:keepalive()
    return true

end

function _PROJECT.erpUsermsgDb_push(user_number, receiver_number, title, content, content_type, send_time)

    local user_name = ""
    local user_company_code = ""
    local user_bu_code = ""
    local receivers = ""
    local receiversTab = {}
    local receiversStr = ""
    local receiversTabIndex = 1
    local user_id
    title = comm_func.sql_singleQuotationMarks(title)
    local userExist = false

    local status, resultData = db_query.user_get(nil, user_number)
    if status == true and resultData ~= nil and resultData[1] ~= nil then
        user_number = resultData[1]["user_number"]
        user_name = resultData[1]["user_name"]
        user_company_code = resultData[1]["user_company_code"]
        user_bu_code = resultData[1]["user_bu_code"]
        user_id = resultData[1]["user_id"]
        userExist = true
    end
    if userExist == false then
        return false, "发送者" .. user_number .. "不存在"
    end
    local isUserReceiveMsg = false
    userExist = false
    local receiverStatus, receiverApps = db_query.user_get(nil, receiver_number)
    if receiverStatus == true then
        for appsk, appsv in pairs(receiverApps) do
            isUserReceiveMsg = true
            if appsv["user_erp_msg_receive"] == 0 then
                isUserReceiveMsg = false
            else
                local receiver = {}
                receiver["user_id"] = appsv["user_id"]
                receiver["user_number"] = appsv["user_number"]
                receiver["user_name"] = appsv["user_name"]
                receiver["view_status"] = 0
                receiver["view_time"] = 0
                receiversTab[receiversTabIndex] = receiver
                receiversTabIndex = receiversTabIndex + 1
                userExist = true
            end
        end
    end
    if isUserReceiveMsg == false and #receiversTab < 1 then
        return false, "ERPMsgReceiveClosed"
    end
    if userExist == false then
        return false, "接收者" .. receiver_number .. "不存在"
    end

    receiversStr = cjson.encode(receiversTab)

    local pg = _PROJECT.get_new_pgmoon_connection()
    assert(pg:connect())
    local notTime = send_time

    local contentTab = comm_func.table_clone(content)
    local extras = {}

    if content_type == "text" then
        contentTab["type"] = 10
        extras["type"] = 10
    else
        contentTab["type"] = 11
        extras["type"] = 11
    end
    extras["title"] = title

    extras["sender_id"] = user_id
    extras["send_time"] = notTime

    extras = cjson.encode(extras)

    local contentStr = cjson.encode(contentTab)
    contentStr = comm_func.sql_singleQuotationMarks(contentStr)
    local sqlStr = string.format(" insert into tb_push_msg(send_time,sender_id,sender_number,sender_name,receivers,title,content_type,content,extras) values(%d,%d,'%s','%s','%s','%s','%s','%s','%s')  ", notTime, user_id, user_number, user_name, receiversStr, title, content_type, contentStr, extras)
    local res = assert(pg:query(sqlStr))
    pg:keepalive()
    return true

end

function _PROJECT.msgPushStatus_update(cid, receivers)
    local pg = _PROJECT.get_new_pgmoon_connection()

    local sqlStr = string.format(" update tb_push_msg set receivers='%s' where cid=%s  returning cid ", receivers, tostring(cid))

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

return _PROJECT


