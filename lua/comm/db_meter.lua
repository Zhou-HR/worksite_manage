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

function _M.get_erp_pgmoon_connection()
    local host_value = conf_sys.erp_sync_db["host_value"]
    local port_value = conf_sys.erp_sync_db["port_value"]
    local database_value = conf_sys.erp_sync_db["database_value"]
    local user_value = conf_sys.erp_sync_db["user_value"]
    local password_value = conf_sys.erp_sync_db["password_value"]

    --local host_value = "127.0.0.1"
    --local port_value = "5434"
    --local database_value = "sync_db"
    --local user_value = "gd_erp"
    --local password_value = "worksIte@gd"

    local pg_erp = pgmoon.new({
        host = host_value,
        port = port_value,
        database = database_value,
        user = user_value,
        password = password_value
    })
    return pg_erp
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

function _M.meter_update(proj_code, old_meter_number, old_meter_value, new_meter_number, new_meter_value, if_receive_msg, if_use_new_box, if_state_grid, user_id)

    local strsql = "select func_record_meter_update('" .. proj_code .. "','"
            .. old_meter_number .. "','" .. old_meter_value .. "','" .. new_meter_number .. "','" .. new_meter_value .. "',"
            .. if_receive_msg .. "," .. if_use_new_box .. "," .. if_state_grid .. "," .. user_id .. ")  returnvalue"

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(strsql))
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.meter_update_erp(proj_code, old_meter_number, old_meter_value, new_meter_number, new_meter_value, if_receive_msg, if_use_new_box, if_state_grid, user_id)

    local strsql = "select func_record_meter_update_erp('" .. proj_code .. "','"
            .. old_meter_number .. "','" .. old_meter_value .. "','" .. new_meter_number .. "','" .. new_meter_value .. "',"
            .. if_receive_msg .. "," .. if_use_new_box .. "," .. if_state_grid .. "," .. user_id .. ")  returnvalue"

    local pg_erp = _M.get_erp_pgmoon_connection()
    assert(pg_erp:connect())
    local res = assert(pg_erp:query(strsql))
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg_erp:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.meter_query(proj_code, view_status)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local strsql = "select * from tb_meter_info where proj_code ='" .. proj_code .. "' order by id desc"
    if view_status == 1 then
        strsql = "select * from tb_meter_info where proj_code ='" .. proj_code .. "' and view_status = 1 order by id desc"
    elseif view_status == 2 then
        strsql = "select * from tb_meter_info where proj_code ='" .. proj_code .. "' and view_status = 2 order by id desc"
    elseif view_status == 3 then
        strsql = "select * from tb_meter_info where proj_code ='" .. proj_code .. "' and view_status in(1,2) order by id desc"
    end

    local res = pg:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()

    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.meter_query_info(proj_code)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local strsql = "select * from tb_meter_info where proj_code ='" .. proj_code .. "' order by id desc  limit 1"

    local res = pg:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()

    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.meter_update_info(proj_code, old_meter_number, old_meter_value, new_meter_number, new_meter_value, if_receive_msg, if_use_new_box, if_state_grid, user_id)

    local strsql = "select func_record_meter_update_info('" .. proj_code .. "','"
            .. old_meter_number .. "','" .. old_meter_value .. "','" .. new_meter_number .. "','" .. new_meter_value .. "',"
            .. if_receive_msg .. "," .. if_use_new_box .. "," .. if_state_grid .. "," .. user_id .. ")  returnvalue"

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(strsql))
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.check_meter_number_if_used(proj_code, new_meter_number)
    local pg_erp = _M.get_erp_pgmoon_connection()

    assert(pg_erp:connect())
    local strsql = "select count(*) totalcount from tb_meter_info where proj_code <> '" .. proj_code .. "' and new_meter_number = '" .. new_meter_number .. "'"
    local res = pg_erp:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg_erp:keepalive()
    comm_func.do_dump_value(res, 0)

    if res ~= nil and res[1] ~= nil and res[1]["totalcount"] ~= nil and res[1]["totalcount"] == 1 then
        return true
    else
        return false
    end

end

function _M.msg_get_erp()
    local pg_erp = _M.get_erp_pgmoon_connection()

    assert(pg_erp:connect())
    local strsql = "select * from tb_meter_info where if_receive_msg = 1 and if_send_msg = 0 limit 3 "
    local res = pg_erp:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg_erp:keepalive()

    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.update_record_erp(proj_code)
    local pg_erp = _M.get_erp_pgmoon_connection()

    assert(pg_erp:connect())
    local strsql = "update tb_meter_info set if_send_msg = 1 where proj_code ='" .. proj_code .. "' "
    local res = pg_erp:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg_erp:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.get_record_info()
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local strsql = "select proj_code,proj_link_pic from tb_proj_link where (floor(extract(epoch from now())) - proj_link_review_time ) < 36000 "
    local res = pg:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()

    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.update_view_status(proj_code, view_status)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local strsql = "update tb_meter_info set view_status = " .. view_status .. " where id = "
            .. " (select max(id) from tb_meter_info where proj_code ='" .. proj_code .. "') "
    local res = pg:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.update_tb_proj_lon_lat_info(proj_code, lon, lat, proj_link_type)
    local pg_erp = _M.get_erp_pgmoon_connection()
    --comm_func.do_dump_value(pg_erp,0)
    local aa = pg_erp:connect()
    --comm_func.do_dump_value(aa,0)
    local strsql = ""

    if proj_link_type == 28 then
        strsql = "update tb_proj_lon_lat_erp set merter_lon = '" .. lon .. "',merter_lat = '" .. lat .. "',update_time = now() where proj_code ='" .. proj_code .. "' "
    elseif proj_link_type == 23 then
        strsql = "update tb_proj_lon_lat_erp set install_lon = '" .. lon .. "',install_lat = '" .. lat .. "',update_time = now() where proj_code ='" .. proj_code .. "' "
    else
        strsql = "update tb_proj_lon_lat_erp set picture_lon = '" .. lon .. "',picture_lat = '" .. lat .. "',update_time = now() where proj_code ='" .. proj_code .. "' "
    end

    local res = pg_erp:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg_erp:keepalive()
    --comm_func.do_dump_value(res,0)
    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.project_status_query(proj_code, module_id)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local strsql = "select module_status from tb_project_module_status where proj_code ='" .. proj_code .. "' and module_id = " .. module_id

    local res = pg:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()

    comm_func.do_dump_value(res, 0)

    if res ~= nil and res[1] ~= nil and res[1]["module_status"] ~= nil then
        return true, res[1]["module_status"]
    else
        return true, 0
    end

end

--fixed by zhangjieqiong at 20200520  重置审核状态
function _M.project_status_set(proj_code)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local strsql = "upadte tb_proj_link set proj_link_status = 0 where proj_code = '" .. proj_code .. "' and proj_link_type = 28 "

    local res = pg:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()

    comm_func.do_dump_value(res, 0)

    if res ~= nil and res[1] ~= nil then
        return true, 0
    else
        return false, 0
    end

end

function _M.proj_status_record_into_db(proj_code, proj_name, module_id, module_status)

    local strsql = "select func_record_proj_status_into_db('"
            .. proj_code .. "','" .. proj_name .. "'," .. module_id .. "," .. module_status .. ") returnvalue "

    local pg = _M.get_new_pgmoon_connection()
    assert(pg:connect())
    local res = assert(pg:query(strsql))
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()
    comm_func.do_dump_value(res, 0)

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end
end

function _M.proj_status_get_erp()
    local pg_erp = _M.get_erp_pgmoon_connection()

    assert(pg_erp:connect())
    local strsql = "select * from tb_project_module_status where flag = 0 limit 30 "
    local res = pg_erp:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg_erp:keepalive()

    if res ~= nil and res[1] ~= nil and res[1]["proj_code"] ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.proj_status_update_erp(proj_code)
    local pg_erp = _M.get_erp_pgmoon_connection()

    assert(pg_erp:connect())
    local strsql = "update tb_project_module_status set flag = 1 ,update_time = now() where proj_code ='" .. proj_code .. "' "
    local res = pg_erp:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg_erp:keepalive()

    if res ~= nil and res[1] ~= nil then
        return true, res
    else
        return false, res
    end

end

function _M.acquisition_query(proj_code)
    local pg = _M.get_new_pgmoon_connection()

    assert(pg:connect())
    local strsql = "select acquisition from tb_proj where proj_code ='" .. proj_code .. "' "

    local res = pg:query(strsql)
    ngx.log(ngx.ERR, "strsql: ", strsql)
    pg:keepalive()

    if res ~= nil and res[1] ~= nil and res[1]["acquisition"] ~= nil then
        return true, res
    else
        return false, res
    end

end

return _M


