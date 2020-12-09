local DATA_KEY = "hate_mid_data_view"

--create connection
local wb, err = server:new{
  timeout = 5000,
  max_payload_len = 65535
}
 
--create success
if not wb then
  ngx.log(ngx.ERR, "client failed to new websocket: ", err)
  return ngx.exit(444)
end


ngx.log(ngx.ERR, "client connecting " )



local push = function()
    -- --create redis
    local red = redis:new()
    while true do
        local rxdata, err = red:blpop(DATA_KEY,1)
		while not err and rxdata ~= nil do
			--comm_func.do_dump_value(rxdata[2],0)
			local bytes, err = wb:send_text(rxdata[2])
			--comm_func.do_dump_value("client sending text",0)
			--comm_func.do_dump_value(rxdata,0)
			if not bytes then
				ngx.log(ngx.ERR, "client  failed to send text: ", err)
			end
			rxdata, err = red:blpop(DATA_KEY,1)
		end
    end
end
 
local co = ngx.thread.spawn(push)

--main loop
while true do
    -- 获取数据
    local data, typ, err0 = wb:recv_frame()
 
    -- 如果连接损坏 退出
    if wb.fatal then
        ngx.log(ngx.ERR, "client failed to receive frame: ", err)
        return ngx.exit(444)
    end

    if not data then
        local bytes, err = wb:send_ping()
        if not bytes then
          ngx.log(ngx.ERR, "client failed to send ping: ", err)
          return ngx.exit(444)
        end
        --ngx.log(ngx.ERR, "send ping: ", data)
    elseif typ == "close" then
        ngx.log(ngx.ERR, "client client send close")
		return ngx.exit(444)
    elseif typ == "ping" then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, "client failed to send pong: ", err)
            return ngx.exit(444)
        end
    elseif typ == "pong" then
        --ngx.log(ngx.ERR, "client ponged")
    elseif typ == "text" then
                
    end
 
end
 
wb:send_close()
ngx.shared.token_cache:delete(appEUI)

ngx.thread.wait(co)
