ngx.req.read_body()
local data = ngx.req.get_body_data()
local decode_data = cjson.decode(data)
if decode_data == nil then
    local tab = {}
    tab["result"] = "参数必须是JSON格式"
    tab["error"] = error_table.get_error("ERROR_JSON_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local user_idHeader = comm_func.get_http_header("user_id", ngx)
local decode_params = decode_data["params"]
local proj_link_ids = decode_params["proj_link_ids"]
local proj_link_fine_detail_id = decode_params["proj_link_fine_detail_id"]

if proj_link_ids == nil or (type(proj_link_ids) ~= "table" and #proj_link_ids < 1) then
    local tab = {}
    tab["result"] = "proj_link_ids参数错误"
    tab["error"] = error_table.get_error("ERROR_PARAMS_WRONG")
    ngx.say(cjson.encode(tab))
    return
end

local linkFineTab = {}

linkFineTab[25] = {
    name = "施工进场",
    fine_items = {
        module_name = "隐蔽工程资料",
        module_order = 6,
        link_order = {
            [1] = 0
        }
    }
}

linkFineTab[2] = {
    name = "开挖验收",
    fine_items = {
        module_name = "塔基",
        module_order = 0,
        link_order = {
            [1] = 0
        }
    }
}

linkFineTab[3] = {
    name = "材料验收",
    fine_items = {
        module_name = "隐蔽工程资料",
        module_order = 6,
        link_order = {
            [1] = 1,
            [2] = 2,
            [3] = 3,
            [4] = 4
        }
    }
}
linkFineTab[4] = {
    name = "钢筋验收",
    fine_items = {
        module_name = "塔基",
        module_order = 0,
        link_order = {
            [1] = 1
        }
    }
}
linkFineTab[5] = {
    name = "浇筑验收",
    fine_items = {
        module_name = "塔基",
        module_order = 0,
        link_order = {
            [1] = 2,
            [2] = 3
        }
    }
}
linkFineTab[6] = {
    name = "地网验收",
    fine_items = {
        module_name = "塔基",
        module_order = 0,
        link_order = {
            [1] = 5
        }
    }
}

linkFineTab[7] = {
    name = "预埋件验收",
    fine_items = {
        module_name = "塔基",
        module_order = 0,
        link_order = {
            [1] = 4
        }
    }
}

linkFineTab[8] = {
    name = "基槽验收",
    fine_items = {
        module_name = "机房",
        module_order = 1,
        link_order = {
            [1] = 0
        }
    }
}
linkFineTab[9] = {
    name = "钢筋工序验收",
    fine_items = {
        module_name = "机房",
        module_order = 1,
        link_order = {
            [1] = 1
        }
    }
}

linkFineTab[10] = {
    name = "混凝土浇筑验收",
    fine_items = {
        module_name = "机房",
        module_order = 1,
        link_order = {
            [1] = 2,
            [2] = 3
        }
    }
}
linkFineTab[26] = {
    name = "整体验收",
    fine_items = {
        module_name = "机房",
        module_order = 1,
        link_order = {
            [1] = 4,
            [2] = 5,
            [3] = 6,
            [4] = 7,
            [5] = 8,
            [6] = 9,
            [7] = 10
        }
    }
}
linkFineTab[17] = {
    name = "整体完工（初验）照片",
    fine_items = {
        module_name = "铁塔",
        module_order = 2,
        link_order = {
            [1] = 0,
            [2] = 1,
            [3] = 2,
            [4] = 3,
            [5] = 4,
            [6] = 5,
            [7] = 6
        }
    },
    fine_ext_items = {
        {
            module_name = "环境",
            module_order = 5,
            link_order = {
                [1] = 0
            }
        }
    }
}
linkFineTab[19] = {
    name = "电表及空开照片",
    fine_items = {
        module_name = "市电引入",
        module_order = 3,
        link_order = {
            [1] = 0
        }
    }
}

linkFineTab[20] = {
    name = "线缆材质及埋深照片",
    fine_items = {
        module_name = "市电引入",
        module_order = 3,
        link_order = {
            [1] = 0,
            [2] = 1,
            [3] = 2,
            [4] = 3
        }
    }
}
linkFineTab[21] = {
    name = "底座固定照片",
    fine_items = {
        module_name = "配套",
        module_order = 4,
        link_order = {
            [1] = 0,
            [2] = 1,
            [3] = 2
        }
    }
}
linkFineTab[22] = {
    name = "机房柜布线照片",
    fine_items = {
        module_name = "配套",
        module_order = 4,
        link_order = {
            [1] = 0,
            [2] = 1,
            [3] = 2
        }
    }
}
linkFineTab[23] = {
    name = "整体完工照片（初验）",
    fine_items = {
        module_name = "配套",
        module_order = 4,
        link_order = {
            [1] = 0,
            [2] = 1,
            [3] = 2
        }
    }
}
linkFineTab[24] = {
    name = "竣工照片",
    fine_items = {
        module_name = "环境",
        module_order = 5,
        link_order = {
            [1] = 0
        }
    }
}
linkFineTab[11] = {
    name = "基础尺寸",
    fine_items = {
        module_name = "塔基",
        module_order = 0,
        link_order = {
            [1] = 2,
            [2] = 3
        }
    }
}
linkFineTab[12] = {
    name = "植筋验收",
    fine_items = {
        module_name = "塔基",
        module_order = 0,
        link_order = {
            [1] = 1
        }
    }
}

local isAdmin = false
local userStatus, userApps = db_query.userFromId_get(user_idHeader)
local userInfo
if userStatus == true and userApps ~= nil and userApps[1] ~= nil then
    userApps[1]["user_role_v2"] = db_query.userRoleValue_get(userApps[1]["user_role"])
    userInfo = userApps[1]
else
    local tab = {}
    tab["result"] = "获取扣款信息失败"
    tab["error"] = error_table.get_error("ERROR_LINK_FINED_ITEM_GET_FAILED")
    ngx.say(cjson.encode(tab))
    return
end

local itemIdTab = {}
local selTab = {}
if type(proj_link_fine_detail_id) == "number" then
    local Projstatuschg, Projappschg = db_project.linkFined_get(proj_link_fine_detail_id)
    if Projstatuschg == true and Projappschg ~= nil and Projappschg[1] ~= nil then
        itemIdTab = cjson.decode(Projappschg[1]["fine_item_ids"])
        if itemIdTab ~= nil and #itemIdTab > 0 then
            local fineItemStatuschg, fineItemDatachg = db_project.fineItems_get(itemIdTab, nil, nil)
            if fineItemStatuschg == true and fineItemDatachg ~= nil and fineItemDatachg[1] ~= nil then
                --Projappschg[1]["fine_items"] = fineItemDatachg
            end
        end
    end

    if Projappschg ~= nil and Projappschg[1] ~= nil then
        if type(Projappschg[1]["fine_item_extra"]) ~= nil and type(Projappschg[1]["fine_item_extra_value"]) ~= nil then
            selTab["fine_item_extra"] = Projappschg[1]["fine_item_extra"]
            selTab["fine_item_extra_value"] = Projappschg[1]["fine_item_extra_value"]
        end
    else
        selTab["result"] = "获取扣款信息失败"
        selTab["error"] = error_table.get_error("ERROR_LINK_FINED_ITEM_GET_FAILED")
        ngx.say(cjson.encode(selTab))
        return
    end
end

--local Projstatus, Projapps = db_project.links_get(proj_link_ids)
local Projstatus, Projapps = db_project.Finelinks_get(proj_link_ids)
local linksFineItem = {}
local linksFineItemIndex = 1

if Projstatus == true and Projapps ~= nil and Projapps[1] ~= nil then
    local linkLength = 1
    local olditemTab = {}
    local bkupstatus, backapps = db_project.linkFine_bkup_check(Projapps[1])
    if backapps ~= nil and backapps[1] ~= nil then

        if userInfo["user_role_v2"] < backapps[1]["reviewer_role"] then
            backapps[1]["fine_final"] = 0
        else
            backapps[1]["fine_final"] = 2
        end
    end

    if linkFineTab[Projapps[1]["proj_link_type"]] ~= nil then
        local itemStatus, itemStatusDatas
        if linkFineTab[Projapps[1]["proj_link_type"]]["fine_ext_items"] ~= nil then
            itemStatus, itemStatusDatas = db_project.fineItemsExt_get(nil, linkFineTab[Projapps[1]["proj_link_type"]]["fine_items"]["module_order"], linkFineTab[Projapps[1]["proj_link_type"]]["fine_items"]["link_order"], linkFineTab[Projapps[1]["proj_link_type"]]["fine_ext_items"])
        else
            itemStatus, itemStatusDatas = db_project.fineItems_get(nil, linkFineTab[Projapps[1]["proj_link_type"]]["fine_items"]["module_order"], linkFineTab[Projapps[1]["proj_link_type"]]["fine_items"]["link_order"])
        end

        if itemStatus == true and itemStatusDatas ~= nil and itemStatusDatas[1] ~= nil then
            if type(proj_link_fine_detail_id) == "number" then
                for m, n in pairs(itemIdTab) do
                    for i = 1, table.maxn(itemStatusDatas), 1 do
                        if tonumber(n) == itemStatusDatas[i]["item_id"] then
                            itemStatusDatas[i]["ischecked"] = 'true'
                        end
                    end
                end
            end
            if bkupstatus == true and #backapps > 0 then
                backapps[1]["fine_item_ids"] = cjson.decode(backapps[1]["fine_item_ids"])
                olditemTab = backapps[1]["fine_item_ids"]
                --if backapps[1]["fine_final"] ~= 2 then
                for j, k in pairs(olditemTab) do
                    for i = 1, table.maxn(itemStatusDatas), 1 do
                        if tonumber(k) == itemStatusDatas[i]["item_id"] then
                            itemStatusDatas[i]["ischecked"] = 'true'
                        end
                    end
                end
                --end
            end
            --       local bkupstatus,backapps = db_project.linkFine_bkup_check(Projapps[1])
            linksFineItem[linksFineItemIndex] = {
                proj_link_id = Projapps[1]["proj_link_id"],
                fine_items = itemStatusDatas,
                fine_record = backapps[1]
            }
        end
    else
        linksFineItem[linksFineItemIndex] = {
            fine_record = backapps[1],
        }
    end
    if bkupstatus == true and backapps[1] ~= nil then
        if backapps[1]["fine_item_extra"] ~= nil and backapps[1]["fine_item_extra_value"] ~= nil then
            linksFineItem[linksFineItemIndex]["fine_item_extra"] = backapps[1]["fine_item_extra"]
            linksFineItem[linksFineItemIndex]["fine_item_extra_value"] = backapps[1]["fine_item_extra_value"]
        end
    end

    if type(proj_link_fine_detail_id) == "number" then
        if selTab["fine_item_extra"] ~= nil and selTab["fine_item_extra_value"] ~= nil then
            linksFineItem[linksFineItemIndex]["fine_item_extra"] = selTab["fine_item_extra"]
            linksFineItem[linksFineItemIndex]["fine_item_extra_value"] = selTab["fine_item_extra_value"]
        end
    end
end

local tab = {}
tab["result"] = linksFineItem
tab["error"] = error_table.get_error("ERROR_NONE")
ngx.say(cjson.encode(tab))

