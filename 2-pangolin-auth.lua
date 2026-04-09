-- 2-pangolin-auth.lua
-- Pangolin Custom Header Authentication Patch
-- Injects P-Access-Token-Id and P-Access-Token headers into all HTTP/HTTPS requests

local logger = require("logger")

-- CREDENTIALS
local P_TOKEN_ID = "<your-token-id-here>"
local P_TOKEN = "<your-token-here>"

logger.info("Pangolin-Auth: Initializing...")

-- We need to hook at the package level BEFORE modules get local references
-- Get the actual module tables from package.loaded
local http_module = package.loaded["socket.http"]
local https_module = package.loaded["ssl.https"]

if not http_module then
    logger.warn("Pangolin-Auth: socket.http not loaded yet, loading now...")
    http_module = require("socket.http")
end

if not https_module then
    logger.warn("Pangolin-Auth: ssl.https not loaded yet, loading now...")
    https_module = require("ssl.https")
end

-- Store original functions
local original_http_request = http_module.request
local original_https_request = https_module.request

-- Helper to inject headers into request table
local function inject_pangolin_headers(request)
    if type(request) == "table" then
        -- Initialize headers table if it doesn't exist
        if not request.headers then
            request.headers = {}
        end
        -- Inject Pangolin headers (only if not already present)
        if not request.headers["P-Access-Token-Id"] then
            request.headers["P-Access-Token-Id"] = P_TOKEN_ID
            request.headers["P-Access-Token"] = P_TOKEN
            logger.info("Pangolin-Auth: ✓ Injected headers for URL:", request.url or "unknown")
        else
            logger.info("Pangolin-Auth: Headers already present for:", request.url or "unknown")
        end
    end
    return request
end

-- Replace the functions in the actual module table
-- This way ALL references (including local ones in other files) will use our hooked version
http_module.request = function(req, body)
    logger.info("Pangolin-Auth: >>> http.request intercepted, type=" .. type(req))
    if type(req) == "table" then
        logger.info("Pangolin-Auth: Request URL:", req.url or "no url")
        inject_pangolin_headers(req)
    elseif type(req) == "string" then
        logger.info("Pangolin-Auth: String URL request:", req)
    end

    -- Call original and capture results
    local result1, result2, result3, result4 = original_http_request(req, body)

    -- Log the response
    logger.info("Pangolin-Auth: Response code:", result2 or "nil")
    logger.info("Pangolin-Auth: Response status:", result4 or "nil")
    if type(result3) == "table" and result3.location then
        logger.info("Pangolin-Auth: Redirect location:", result3.location)
    end

    return result1, result2, result3, result4
end

https_module.request = function(req, body)
    logger.info("Pangolin-Auth: >>> https.request intercepted, type=" .. type(req))
    if type(req) == "table" then
        logger.info("Pangolin-Auth: Request URL:", req.url or "no url")
        inject_pangolin_headers(req)
    elseif type(req) == "string" then
        logger.info("Pangolin-Auth: String URL request:", req)
    end

    -- Call original and capture results
    local result1, result2, result3, result4 = original_https_request(req, body)

    -- Log the response
    logger.info("Pangolin-Auth: Response code:", result2 or "nil")
    logger.info("Pangolin-Auth: Response status:", result4 or "nil")
    if type(result3) == "table" and result3.location then
        logger.info("Pangolin-Auth: Redirect location:", result3.location)
    end

    return result1, result2, result3, result4
end

logger.info("Pangolin-Auth: ✓✓✓ Hooks installed successfully ✓✓✓")
