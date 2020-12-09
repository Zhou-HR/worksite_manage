local uri_args = ngx.req.get_uri_args()
--local uploadPolicy = decode_data["uploadPolicy"]


local dir = uri_args["dir"]
local filename = uri_args["filename"]
local namespace = "gdworksite"
local ak = "23249288"
local sk = "383204d206642d5104a2cb97d6d456c5"

local function urlsafe_base64(base64)
    local afterStr = base64
    if string.find(afterStr, "+", 1) ~= nil then
        afterStr = string.gsub(afterStr, "+", "-")
    end
    if string.find(afterStr, "/", 1) ~= nil then
        afterStr = string.gsub(afterStr, "/", "_")
    end
    if string.find(afterStr, "=", 1) ~= nil then
        afterStr = string.gsub(afterStr, "=", "")
    end
    return afterStr
end

local resourceIdBeforeEncoded = string.format("[\"%s\",\"%s\",\"%s\"]", namespace, dir, filename)
local resourceId = ngx.encode_base64(resourceIdBeforeEncoded)
resourceId = urlsafe_base64(resourceId)

local date = ngx.now() * 1000
local urlPath = string.format("/3.0/files/%s/exist", resourceId)

local stringBeforeSign = string.format("%s\n\n%d", urlPath, date)

local sign = comm_func.to_hex(ngx.hmac_sha1(sk, stringBeforeSign))
sign = string.lower(sign)

local preencode = string.format("%s:%s", ak, sign)
local encoded = ngx.encode_base64(preencode)
encoded = urlsafe_base64(encoded)

local manageToken = string.format("ACL_TOP %s", encoded)

local requestHeader = {}
requestHeader["Date"] = date
requestHeader["Authorization"] = manageToken
local statusM, resultM = comm_func.alimedia_getHttpRequestDo("", string.format("http://rs.media.aliyun.com%s", urlPath), requestHeader)

local tab = {}
tab["result"] = resultM
tab["error"] = 0
ngx.say(cjson.encode(tab))