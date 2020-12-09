ngx.req.read_body()
local data = ngx.req.get_body_data()

local decode_data = cjson.decode(data)
local project_id = decode_data["project_id"]
local describe = decode_data["describe"]
local typeS = decode_data["type"]
local job_number = decode_data["job_number"]
local job_number_reviewer = decode_data["job_number_reviewer"]

local nowTime = math.ceil(ngx.now())

local sqlStr = " insert into tb_link_debug(project_id,pic1_alt,pic2_alt,pic3_alt,pic4_alt,pic5_alt,pic1_lon,pic2_lon,pic3_lon,pic4_lon,pic5_lon,pic1_lat,pic2_lat,pic3_lat,pic4_lat,pic5_lat,pic1_describe,pic2_describe,pic3_describe,pic4_describe,pic5_describe,describe,type,job_number,job_number_reviewer,pic1_time,pic2_time,pic3_time,pic4_time,pic5_time,pic1_dev_info,pic2_dev_info,pic3_dev_info,pic4_dev_info,pic5_dev_info,pic1_url,pic2_url,pic3_url,pic4_url,pic5_url,submit_time)  values(%d,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s',%d,%d,%d,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s') "

sqlStr = string.format(sqlStr, project_id, decode_data["pic1_alt"], decode_data["pic2_alt"], decode_data["pic3_alt"], decode_data["pic4_alt"], decode_data["pic5_alt"], decode_data["pic1_lon"], decode_data["pic2_lon"], decode_data["pic3_lon"], decode_data["pic4_lon"], decode_data["pic5_lon"], decode_data["pic1_lat"], decode_data["pic2_lat"], decode_data["pic3_lat"], decode_data["pic4_lat"], decode_data["pic5_lat"], decode_data["pic1_describe"], decode_data["pic2_describe"], decode_data["pic3_describe"], decode_data["pic4_describe"], decode_data["pic5_describe"], describe, typeS, job_number, job_number_reviewer, decode_data["pic1_time"], decode_data["pic2_time"], decode_data["pic3_time"], decode_data["pic4_time"], decode_data["pic5_time"], decode_data["pic1_dev_info"], decode_data["pic2_dev_info"], decode_data["pic3_dev_info"], decode_data["pic4_dev_info"], decode_data["pic5_dev_info"], decode_data["pic1_url"], decode_data["pic2_url"], decode_data["pic3_url"], decode_data["pic4_url"], decode_data["pic5_url"], nowTime)

local status, apps = db_query.Link_add(sqlStr)

if status == true then
    local tab = {}
    tab["result"] = apps
    tab["error"] = error_table.get_error("ERROR_NONE")
    ngx.say(cjson.encode(tab))
else
    local tab = {}
    tab["result"] = apps
    tab["error"] = 1
    ngx.say(cjson.encode(tab))
end

