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

function _M.version_new_get(dev_app_version)
    local sql = " select * from tb_android_version order by version desc limit 1"
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

return _M


