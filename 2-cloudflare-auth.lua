-- 2-cloudflare-auth.lua
-- Cloudflare Access Service Token Authentication Patch
-- Injects CF-Access-Client-Id and CF-Access-Client-Secret headers into all HTTP/HTTPS requests

local logger = require("logger")

-- CREDENTIALS
local CF_ID = "<your-client-id-here>"
local CF_SECRET = "<your-client-secret-here>"

logger.info("CF-Auth: Initializing...")

-- We need to hook at the package level BEFORE modules get local references
-- Get the actual module tables from package.loaded
local http_module = package.loaded["socket.http"]
local https_module = package.loaded["ssl.https"]

if not http_module then
    logger.warn("CF-Auth: socket.http not loaded yet, loading now...")
    http_module = require("socket.http")
end

if not https_module then
    logger.warn("CF-Auth: ssl.https not loaded yet, loading now...")
    https_module = require("ssl.https")
end

-- Store original functions
local original_http_request = http_module.request
local original_https_request = https_module.request

-- Helper to inject headers into request table
local function inject_cf_headers(request)
    if type(request) == "table" then
        -- Initialize headers table if it doesn't exist
        if not request.headers then
            request.headers = {}
        end
        -- Inject Cloudflare headers (only if not already present)
        if not request.headers["CF-Access-Client-Id"] then
            request.headers["CF-Access-Client-Id"] = CF_ID
            request.headers["CF-Access-Client-Secret"] = CF_SECRET
            logger.info("CF-Auth: ✓ Injected headers for URL:", request.url or "unknown")
        else
            logger.info("CF-Auth: Headers already present for:", request.url or "unknown")
        end
    end
    return request
end

-- Replace the functions in the actual module table
-- This way ALL references (including local ones in other files) will use our hooked version
http_module.request = function(req, body)
    logger.info("CF-Auth: >>> http.request intercepted, type=" .. type(req))
    if type(req) == "table" then
        logger.info("CF-Auth: Request URL:", req.url or "no url")
        inject_cf_headers(req)
    elseif type(req) == "string" then
        logger.info("CF-Auth: String URL request:", req)
    end
    
    -- Call original and capture results
    local result1, result2, result3, result4 = original_http_request(req, body)
    
    -- Log the response
    logger.info("CF-Auth: Response code:", result2 or "nil")
    logger.info("CF-Auth: Response status:", result4 or "nil")
    if type(result3) == "table" and result3.location then
        logger.info("CF-Auth: Redirect location:", result3.location)
    end
    
    return result1, result2, result3, result4
end

https_module.request = function(req, body)
    logger.info("CF-Auth: >>> https.request intercepted, type=" .. type(req))
    if type(req) == "table" then
        logger.info("CF-Auth: Request URL:", req.url or "no url")
        inject_cf_headers(req)
    elseif type(req) == "string" then
        logger.info("CF-Auth: String URL request:", req)
    end
    
    -- Call original and capture results
    local result1, result2, result3, result4 = original_https_request(req, body)
    
    -- Log the response
    logger.info("CF-Auth: Response code:", result2 or "nil")
    logger.info("CF-Auth: Response status:", result4 or "nil")
    if type(result3) == "table" and result3.location then
        logger.info("CF-Auth: Redirect location:", result3.location)
    end
    
    return result1, result2, result3, result4
end

logger.info("CF-Auth: ✓✓✓ Hooks installed successfully ✓✓✓")
