local delay = 5  -- in seconds
local new_timer = ngx.timer.at
local log = ngx.log
local ERR = ngx.ERR
local check
local latest_tmst = nil
local proj_user_synced = false
-----------------
-----------------------try/catch
-----------------------

local function __TRACKBACK__(errmsg)
    local track_text = debug.traceback(tostring(errmsg), 6)
    comm_func.do_dump_value("FATAL Exception!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", 0)
    comm_func.do_dump_value(track_text, 0)
    return false
end

local function trycall(func, ...)
    local args = { ... }
    return xpcall(function()
        return func(unpack(args))
    end, __TRACKBACK__)
end

local function JpushMsg(msgData)
    local postData = {}
    --postData["cid"] = tostring(msgData["cid"])
    postData["platform"] = "all"
    postData["audience"] = {}
    postData["audience"]["alias"] = {}

    local receivers = msgData["receivers"]
    local receiverTab = cjson.decode(receivers)
    --for appsk,appsv in pairs(receiverTab) do
    --  table.insert(postData["audience"]["alias"],tostring(appsv["user_id"]) )
    --end

    local androidNotification = {}
    androidNotification["alert"] = msgData["sender_name"]
    androidNotification["title"] = msgData["title"]
    androidNotification["builder_id"] = 1
    androidNotification["extras"] = cjson.decode(msgData["extras"])
    androidNotification["extras"]["cid"] = msgData["cid"]

    local iosNotification = {}
    iosNotification["alert"] = {
        title = msgData["sender_name"],
        body = msgData["title"]
    }
    iosNotification["sound"] = "default"
    iosNotification["badge"] = "+1"
    iosNotification["extras"] = cjson.decode(msgData["extras"])
    iosNotification["extras"]["cid"] = msgData["cid"]

    postData["notification"] = {}
    postData["notification"]["android"] = androidNotification
    postData["notification"]["ios"] = iosNotification
    postData["options"] = {}
    postData["options"]["time_to_live"] = 86400
    if conf_sys.jpush_api_keys["apns_production"] ~= nil and conf_sys.jpush_api_keys["apns_production"] == false then
        postData["options"]["apns_production"] = false
    end
    local aliasLength = 1
    for appsk, appsv in pairs(receiverTab) do
        table.insert(postData["audience"]["alias"], tostring(appsv["user_id"]))
        aliasLength = aliasLength + 1
        if aliasLength > 1000 then
            local postDataTab = cjson.encode(postData)
            local status, result, respon = comm_func.Jpush_to_msg(postDataTab, 3)
            local isSendOk = false
            if status == true then
                if result["msg_id"] ~= nil then
                    db_push_msg.msgPushSent_update(msgData["cid"], result["msg_id"], nil)
                    isSendOk = true
                end
            end
            if isSendOk == false then
                local resultTab = {}
                resultTab["status"] = respon.status
                resultTab["body"] = respon.body
                db_push_msg.msgPushSent_update(msgData["cid"], nil, cjson.encode(resultTab))
            end
            postData["audience"]["alias"] = {}
            aliasLength = 1
        end
    end
    if aliasLength > 1 then
        local postDataTab = cjson.encode(postData)
        local status, result, respon = comm_func.Jpush_to_msg(postDataTab, 3)
        local isSendOk = false
        if status == true then
            if result["msg_id"] ~= nil then
                db_push_msg.msgPushSent_update(msgData["cid"], result["msg_id"], nil)
                isSendOk = true
            end
        end
        if isSendOk == false then
            local resultTab = {}
            resultTab["status"] = respon.status
            resultTab["body"] = respon.body
            db_push_msg.msgPushSent_update(msgData["cid"], nil, cjson.encode(resultTab))
        end
    end
    --[==[
      postData =   cjson.encode(postData)
      local status ,result,respon = comm_func.Jpush_to_msg(postData,3)
      local isSendOk = false
      if status == true then
        if result["msg_id"] ~= nil then
          db_push_msg.msgPushSent_update(msgData["cid"],result["msg_id"],nil)
          isSendOk = true
        end
      end
      if isSendOk == false then
         local resultTab = {}
         resultTab["status"] = respon.status
         resultTab["body"] = respon.body
         db_push_msg.msgPushSent_update(msgData["cid"],nil,cjson.encode(resultTab))
      end
    ]==]--
end

local function pushMsg(red)
    --comm_func.do_dump_value(conf_sys.push_msg,0)
    local isHaveUnsendMsg = red:get(conf_sys.sys_user_token["isHaveUnsendMsg"])
    --comm_func.do_dump_value(isHaveUnsendMsg,0)
    if isHaveUnsendMsg ~= "false" then
        local status, apps = db_push_msg.msgPushUnsend_get()
        if status == true and apps ~= nil and apps[1] ~= nil then
            for appsk, appsv in pairs(apps) do
                JpushMsg(appsv)
            end
        end
        red:set(conf_sys.sys_user_token["isHaveUnsendMsg"], "false")
    end
end
local function requestUserImportAPI(userTab)
    local ipAddr = conf_sys.erp_sync_request_api["ipAddr"]
    local port = conf_sys.erp_sync_request_api["port"]
    local apiStr = "api/user_import_v0_4"
    local header = {}
    header["Content-Type"] = "application/json"
    header["Authorization"] = "sdfsRDfwefw123WEe2ERGr3=r-34t03ERGERt353+t3E6++dfge=-GER34kt3WE4-o3-4-0i1iGD-kkbmjkd22fl"
    header["user-agent"] = "self"
    header["dev-request-type"] = "user_web"
    header["user-id"] = db_query.userId_get("admin")
    if header["user-id"] == nil then
        header["user-id"] = 1
    end

    local requestBody = {}
    requestBody["params"] = userTab

    local status, body = comm_func.postHttpRequestDo(ipAddr, port, apiStr, header, cjson.encode(requestBody))
    if status == true and body["error"] == 0 then
        db_sync_erp.userSynced_update(userTab)
        return true
    end
    return false
end

local function requestProjectImportAPI(projectTab)
    local ipAddr = conf_sys.erp_sync_request_api["ipAddr"]
    local port = conf_sys.erp_sync_request_api["port"]
    local apiStr = "api/project_import_v0_4"
    local header = {}
    header["Content-Type"] = "application/json"
    header["Authorization"] = "sdfsRDfwefw123WEe2ERGr3=r-34t03ERGERt353+t3E6++dfge=-GER34kt3WE4-o3-4-0i1iGD-kkbmjkd22fl"
    header["user-agent"] = "self"
    header["dev-request-type"] = "user_web"
    header["user-id"] = db_query.userId_get("admin")
    if header["user-id"] == nil then
        header["user-id"] = 1
    end

    local requestBody = {}
    requestBody["params"] = projectTab

    local status, body = comm_func.postHttpRequestDo(ipAddr, port, apiStr, header, cjson.encode(requestBody))
    if status == true and body["error"] == 0 then
        db_sync_erp.projectSynced_update(projectTab)
        return true
    end
    return false
end

local function syncDataWithERP(red)
    local nowTime = ngx.now()
    local start_time = nil
    if latest_tmst == nil then
        latest_tmst = os.date("%Y-%m-%d", nowTime - 86400)
        --latest_tmst = os.date("%Y-%m-%d",nowTime-10)
        start_time = 1524153599
    else
        start_time = math.ceil(nowTime - 262800)
    end

    local now_tmst = os.date("%Y-%m-%d", nowTime)
    local hour = os.date("%H", nowTime)
    local limit = 100000
    local offset = 0
    --comm_func.do_dump_value(now_tmst,0)
    if now_tmst > latest_tmst then
        --if false then
        --local status,apps,count,total = db_sync_erp.linkSynced_delete()

        --    local status,apps,count,total = db_project.linkModuleReviewedList_get(limit,offset)
        --
        --    while status == true and apps ~= nil and apps[1] ~= nil do
        --      for appsk,appsv in pairs(apps) do
        --        --db_sync_erp.linkModuleSyncAdapteERP_add(appsv)
        --        db_sync_erp.linkModuleSync_add(appsv)
        --      end
        --      status = false
        --[==[
        if offset  + count < total then
          status,apps,count,total = db_project.linkReviewedList_get(limit,offset)
        end
        ]==]--
        --    end

        --    local status,apps,count,total = db_project.link1TuJianModuleReviewedList_get(limit,offset)
        --    while status == true and apps ~= nil and apps[1] ~= nil do
        --      for appsk,appsv in pairs(apps) do
        --db_sync_erp.link1TuJianModlueSyncAdapteERP_add(appsv)
        --        db_sync_erp.link1TuJianModlueSync_add(appsv)
        --      end
        --      status = false
        --[==[
        if offset  + count < total then
          status,apps,count,total = db_project.linkReviewedList_get(limit,offset)
        end
        ]==]--
        --    end

        --    local status,apps,count,total = db_project.linkTuJianModuleReviewedList_get(limit,offset)
        --    while status == true and apps ~= nil and apps[1] ~= nil do
        --      for appsk,appsv in pairs(apps) do
        --db_sync_erp.linkTuJianModuleSyncApateERP_add(appsv)
        --        db_sync_erp.linkTuJianModuleSync_add(appsv)
        --      end
        --      status = false
        --[==[
        if offset  + count < total then
          status,apps,count,total = db_project.linkReviewedList_get(limit,offset)
        end
        ]==]--
        --    end



        local status, apps, count, total = db_project.linkModuleReviewedOkList_get(start_time, limit, offset)

        while status == true and apps ~= nil and apps[1] ~= nil do
            for appsk, appsv in pairs(apps) do
                --db_sync_erp.linkModuleSyncAdapteERP_add(appsv)
                db_sync_erp.linkModuleOkSync_add(appsv)
            end
            status = false
            --[==[
            if offset  + count < total then
              status,apps,count,total = db_project.linkReviewedList_get(limit,offset)
            end
            ]==]--
        end

        local status, apps, count, total = db_project.linkModuleReviewedOkJieDianList_get(start_time, limit, offset)
        while status == true and apps ~= nil and apps[1] ~= nil do
            for appsk, appsv in pairs(apps) do
                --db_sync_erp.linkModuleSyncAdapteERP_add(appsv)
                db_sync_erp.linkModuleJieDianOkSync_add(appsv)
            end
            status = false
            --[==[
            if offset  + count < total then
              status,apps,count,total = db_project.linkReviewedList_get(limit,offset)
            end
            ]==]--
        end

        latest_tmst = now_tmst
        proj_user_synced = false
    end

    if proj_user_synced == false and hour > "00" then
        --local status,apps,count,total = db_sync_erp.projectSynced_delete()
        --local status,apps,count,total = db_sync_erp.userSynced_delete()

        local status, apps, count, total = db_sync_erp.userSyncList_get(limit, offset)
        while status == true and apps ~= nil and apps[1] ~= nil do
            for appsk, appsv in pairs(apps) do
                local result = requestUserImportAPI(appsv)
            end
            status = false
            --[==[
            if offset  + count < total then
              status,apps,count,total = db_sync_erp.userSyncList_get(limit,offset)
            end
            ]==]--
        end

        local status, apps, count, total = db_sync_erp.projectSyncList_get(limit, offset)
        while status == true and apps ~= nil and apps[1] ~= nil do
            for appsk, appsv in pairs(apps) do
                local result = requestProjectImportAPI(appsv)
            end
            status = false
            --[==[
            if offset  + count < total then
              status,apps,count,total = db_sync_erp.projectSyncList_get(limit,offset)
            end
            ]==]--
        end

        red:set(conf_sys.sys_userListWithOrganization["isUpdate"], "false")
        proj_user_synced = true
    end

end

local function prepareUserOrganization(red)
    local isUpdate = red:get(conf_sys.sys_userListWithOrganization["isUpdate"])
    if isUpdate ~= "true" then

        local ipAddr = conf_sys.erp_sync_request_api["ipAddr"]
        local port = conf_sys.erp_sync_request_api["port"]
        local apiStr = "api/userListWithOrganizationOneProvince_get"
        local header = {}
        header["Content-Type"] = "application/json"
        header["Authorization"] = "sdfsRDfwefw123WEe2ERGr3=r-34t03ERGERt353+t3E6++dfge=-GER34kt3WE4-o3-4-0i1iGD-kkbmjkd22fl"
        header["user-agent"] = "self"
        header["dev-request-type"] = "user_web"

        header["user-id"] = db_query.userId_get("admin")
        if header["user-id"] == nil then
            header["user-id"] = 1
        end

        local requestBody = {}
        requestBody["params"] = {
            fromSysRequest = "true"
        }
        local status, body = comm_func.postHttpRequestDo(ipAddr, port, apiStr, header, cjson.encode(requestBody))

        red:set(conf_sys.sys_userListWithOrganization["isUpdate"], "true")
    end
end

local function syncPushMsgWithERP(red)
    local status, apps = db_sync_erp.pushMsgList_get()
    if status == true and apps ~= nil and apps[1] ~= nil then
        for appsk, appsv in pairs(apps) do
            local ipAddr = conf_sys.erp_sync_request_api["ipAddr"]
            local port = conf_sys.erp_sync_request_api["port"]
            local apiStr = "api/erpMessage_send"
            local header = {}
            header["Content-Type"] = "application/json"
            header["Authorization"] = "sdfsRDfwefw123WEe2ERGr3=r-34t03ERGERt353+t3E6++dfge=-GER34kt3WE4-o3-4-0i1iGD-kkbmjkd22fl"
            header["user-agent"] = "self"
            header["dev-request-type"] = "user_web"

            header["user-id"] = db_query.userId_get("admin")
            if header["user-id"] == nil then
                header["user-id"] = 1
            end

            local requestBody = {}
            requestBody["params"] = {
                receiver_number = appsv["msg_receiver_number"],
                title = appsv["msg_title"],
                content = {
                    msg = appsv["msg_content"]
                },
                content_type = "text",
                user_number = appsv["msg_sender_number"],
                send_time = appsv["msg_send_time"],
                pk_msg = appsv["pk_msg"]
            }
            local status, body = comm_func.postHttpRequestDo(ipAddr, port, apiStr, header, cjson.encode(requestBody))

        end
    end
end

check = function(premature)
    local red = redis:new()
    trycall(syncPushMsgWithERP, red)
    trycall(pushMsg, red)
    trycall(syncDataWithERP, red)
    trycall(prepareUserOrganization, red)
    local ok, err = new_timer(delay, check)
    if not ok then
        log(ERR, "failed to create timer: ", err)
        return
    end
end

if ngx.worker.id() == 0 then
    local ok, err = ngx.timer.at(delay, check)
    if not ok then
        log(ERR, "failed to create timer: ", err)
        return
    end

end

proc_time = function(premature)
    ngx.log(ngx.ERR, "proc_meter_info.proc_msg is begin ....... ")
    proc_meter_info.proc_msg();

    local ok, err = new_timer(30, proc_time)
    if not ok then
        log(ERR, "failed to create timer proc_time: ", err)
        return
    end
end

if ngx.worker.id() == 0 then
    local ok, err = new_timer(30, proc_time)
    if not ok then
        log(ERR, "failed to create timer proc_time: ", err)
        return
    end
end

proc_proj_status_time = function(premature)
    ngx.log(ngx.ERR, "proc_meter_info.proc_proj_status_info is begin ....... ")
    proc_meter_info.proc_proj_status_info();

    local ok, err = new_timer(30, proc_proj_status_time)
    if not ok then
        log(ERR, "failed to create timer proc_proj_status_time: ", err)
        return
    end
end

if ngx.worker.id() == 0 then
    local ok, err = new_timer(30, proc_proj_status_time)
    if not ok then
        log(ERR, "failed to create timer proc_proj_status_time: ", err)
        return
    end
end

local function update_erp_info()
    local nowTime = ngx.now()
    local hour = os.date("%H", nowTime)
    ngx.log(ngx.ERR, "update_erp_info: ", hour)
    --if hour ~= "15" then
    --	return
    --end

    local status, apps = db_meter.get_record_info()
    if status ~= true then
        return
    end
    comm_func.do_dump_value(apps, 0)
    for k, v in pairs(apps) do
        local aa = cjson.decode(apps[k]["proj_link_pic"])
        local proj_link_type = cjson.decode(apps[k]["proj_link_type"])
        --ngx.log(ngx.ERR, "proj_link_type: ", proj_link_type)
        --tab["result"] = aa
        --ngx.log(ngx.ERR, "222: ",aa[1]["location"])
        local proj_code = apps[k]["proj_code"]
        local lon = aa[1]["location"]["lon"]
        local lat = aa[1]["location"]["lat"]

        db_meter.update_tb_proj_lon_lat_info(proj_code, lon, lat, proj_link_type)
    end
end

proc_updateProjectLonLatToErp = function(premature)
    ngx.log(ngx.ERR, "proc_updateProjectLonLatToErp is begin ....... ")
    update_erp_info();

    local ok, err = new_timer(3599, proc_updateProjectLonLatToErp)
    if not ok then
        log(ERR, "failed to create timer proc_updateProjectLonLatToErp: ", err)
        return
    end
end
if ngx.worker.id() == 0 then
    local ok, err = new_timer(60, proc_updateProjectLonLatToErp)
    if not ok then
        log(ERR, "failed to create timer proc_time: ", err)
        return
    end
end



