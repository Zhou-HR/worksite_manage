local _CONF = {}

_CONF.sys_db = {
    host_value = "127.0.0.1",
    port_value = "5432",
    database_value = "gd_worksite_manage_trial",
    user_value = "hate_mid",
    password_value = "guodong_for_hate",
}
_CONF.sys_redis = {
    host_value = "127.0.0.1",
    port_value = 6379
}

--
--
--redis
--debug
--worksite_token

--beta
--worksite_token_beta

--trial
--worksite_token_trial

_CONF.sys_user_token = {
    worksite_token = "worksite_token_trial",
    isHaveUnsendMsg = "worksite_have_unsend_msg_trial"
}

_CONF.sys_userListWithOrganization = {
    isUpdate = "worksite_user_isupdate_trial",
    userOrganization = "worksite_user_organization_trial"
}

--
--sync with ERP 
--trial

_CONF.erp_sync_db = {
    host_value = "127.0.0.1",
    port_value = "5434",
    database_value = "sync_db",
    user_value = "gd_erp",
    password_value = "worksIte@gd",
}


--debug
--[==[
_CONF.erp_sync_db = {
                  host_value = "127.0.0.1",
                  port_value = "5432",
                  database_value = "gd_worksite_manage_demo",
                  user_value = "hate_mid",
                  password_value = "guodong_for_hate",
                }
]==]--
_CONF.push_msg = {
    isHaveUnsent = true
}
_CONF.erp_sync_request_api = {
    ipAddr = "127.0.0.1",
    port = "2114"
}
--release version

_CONF.jpush_api_keys = {
    AppKey = "27e7f053767d54d143b2b1b6",
    MasterSecret = "00926e32478e04c92134c622"
}

--debug version
--[==[
_CONF.jpush_api_keys = {
                  AppKey = "502d7279d9476a0f9b42bfe7",
                  MasterSecret = "79f954fbc9a2305cc08e0242",
		  apns_production = false
                }
]==]--
_CONF.fuzzy_searche_key_length_min = 1

--fined_statistics_sql_demo_
--fined_statistics_sql_beta_
--fined_statistics_sql_trial_
_CONF.project_fined_list_excel_sql = "fined_statistics_sql_trial_"
_CONF.province_fined_list_excel_sql = "province_fined_statistics_sql_trial_"
_CONF.project_fined_list_excel_file_dir = "/home/gqh_workspace/project/gd_worksite_manage_web/html/excel_dir/"
_CONF.project_fined_list_excel_file_url_path = "http://120.27.216.49:1800/excel_dir/"
return _CONF


