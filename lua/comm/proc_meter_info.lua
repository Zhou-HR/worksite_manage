local log = ngx.log
local ERR = ngx.ERR
local proc_meter_info = {}
local wb = 0

function proc_meter_info.proc_proj_status_info()
    local status_sms, apps = db_meter.proj_status_get_erp()
    if status_sms == true then
        for k, v in pairs(apps) do
            proc_meter_info.proj_record_into_db(apps[k]["proj_code"], apps[k]["proj_name"], apps[k]["module_id"], apps[k]["module_status"])
        end
        ngx.log(ngx.ERR, "db_meter.proj_status_get_erp is ok: ")
    else
        ngx.log(ngx.ERR, "db_meter.proj_status_get_erp no data ")
    end
end

function proc_meter_info.proj_record_into_db(proj_code, proj_name, module_id, module_status)
    db_meter.proj_status_update_erp(proj_code)
    db_meter.proj_status_record_into_db(proj_code, proj_name, module_id, module_status)
end

function proc_meter_info.proc_msg()
    local status_sms, apps = db_meter.msg_get_erp()
    local all_mail_addr = {}
    local content = {}
    content["msg"] = "该电表已经上报消息"
    if status_sms == true then
        for k, v in pairs(apps) do
            title = "电表安装反馈信息"
            content_type = "text"
            content["msg"] = apps[k]["new_meter_number"] .. "：该电表已经上报消息，安装成功。"
            ngx.log(ngx.ERR, "content msg: ", content["msg"])
            ngx.log(ngx.ERR, "title msg: ", title)
            proc_meter_info.send_to_user(apps[k]["proj_code"], 1, apps[k]["user_id"], title, content, content_type)
        end
        ngx.log(ngx.ERR, "db_meter.msg_get is ok: ")
    else
        ngx.log(ngx.ERR, "db_meter.msg_get no data ")
    end
end

function proc_meter_info.send_to_user(proj_code, user_id, user_ids, title, content, content_type)
    local user_ids_info = {}
    user_ids_info[1] = user_ids
    local status, apps, count, total = db_push_msg.usermsgDb_push(user_id, user_ids_info, title, content, content_type)
    if status == true then
        local red = redis:new()
        red:set(conf_sys.sys_user_token["isHaveUnsendMsg"], "true")
        --comm_func.do_dump_value(red:get(conf_sys.sys_user_token["isHaveUnsendMsg"]),0)
        ngx.log(ngx.ERR, "send_to_user is ok: ", proj_code)
        proc_meter_info.update_record(proj_code)
    else
        ngx.log(ngx.ERR, "send_to_user is failed: ", proj_code)
    end

end

function proc_meter_info.update_record(proj_code)

    local status, apps = db_meter.update_record_erp(proj_code)
    if status == true then
        comm_func.do_dump_value(apps, 0)
        if apps ~= nil and apps[1] ~= nil and apps[1]["proj_code"] ~= nil then
            tab["result"] = apps
            tab["error"] = error_table.get_error("ERROR_NONE")
            tab["description"] = "SUCCESS"

            ngx.say(cjson.encode(tab))
            return
        end
    end

end

return proc_meter_info
