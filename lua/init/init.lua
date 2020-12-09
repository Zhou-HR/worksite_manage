--ngx_lua启动执行这里，将一些常用的库直接加载，减少i/o

cjson = require "cjson.safe"    --cjson库
error_table = require "error_code" --错误码定义
db_query = require "db_query"     --数据库请求封装
db_android_version = require "db_android_version"
db_project = require "db_project"
db_user = require "db_user"
db_push_msg = require "db_push_msg"
redis = require "capsule_redis"   --redis请求库
comm_func = require "common_function"  --一些函数封装
pgmoon = require("pgmoon")
client = require "resty.websocket.client"
server = require "resty.websocket.server"
file_uploader = require "resty.upload"
conf_sys = require "conf_sys"
db_sync_erp = require "db_sync_erp"
db_meter = require "db_meter"
proc_meter_info = require "proc_meter_info"
