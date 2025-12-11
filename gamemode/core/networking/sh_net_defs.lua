-- CybeRp Networking definitions & helpers
-- Message catalog (all traffic runs through these identifiers):
--  * PLAYER_DATA:      Full/partial player stats snapshot.
--  * INVENTORY_UPDATE: Inventory snapshot or partial diff.
--  * CYBERWARE_UPDATE: Cyberware snapshot or partial diff.
--  * JOB_UPDATE:       Job/faction/role changes for a player.
--  * WORLD_EVENT:      Broadcasted world alerts (alarms, wars, police).
--  * RPC:              Server -> client RPC envelope { method, args }.

CybeRp = CybeRp or {}
CybeRp.NET = CybeRp.NET or {}
CybeRp.Networking = CybeRp.Networking or {}

local NET = CybeRp.NET

local function define(name, id)
    NET[name] = NET[name] or id
end

define("PLAYER_DATA", "cyberp_player_data")
define("INVENTORY_UPDATE", "cyberp_inventory_update")
define("CYBERWARE_UPDATE", "cyberp_cyberware_update")
define("JOB_UPDATE", "cyberp_job_update")
define("WORLD_EVENT", "cyberp_world_event")
define("RPC", "cyberp_rpc_call")

-- Payload codecs: default to PON + util.Compress, fallback to JSON.
local CODECS = {
    pon = {
        id = 1,
        encode = function(tbl)
            local ok, encoded = pcall(pon.encode, tbl or {})
            if not ok or not encoded then return false, "pon encode failed" end
            local compressed = util.Compress(encoded)
            if not compressed then return false, "compress failed" end
            return compressed
        end,
        decode = function(data)
            local decompressed = util.Decompress(data or "")
            if not decompressed then return false, "decompress failed" end
            local ok, decoded = pcall(pon.decode, decompressed)
            if not ok then return false, "pon decode failed" end
            return decoded
        end
    },
    json = {
        id = 2,
        encode = function(tbl)
            local ok, encoded = pcall(util.TableToJSON, tbl or {}, false)
            if not ok or not encoded then return false, "json encode failed" end
            local compressed = util.Compress(encoded)
            if not compressed then return false, "compress failed" end
            return compressed
        end,
        decode = function(data)
            local decompressed = util.Decompress(data or "")
            if not decompressed then return false, "decompress failed" end
            local ok, decoded = pcall(util.JSONToTable, decompressed)
            if not ok then return false, "json decode failed" end
            return decoded
        end
    }
}

local CODEC_BY_ID = {
    [1] = "pon",
    [2] = "json"
}

local DEFAULT_CODEC = "pon"
local CODEC_BITS = 3
local LENGTH_BITS = 32 -- bytes

local function chooseCodec(codec)
    if CODECS[codec] then return codec end
    return DEFAULT_CODEC
end

function CybeRp.Networking.EncodeTable(tbl, codec)
    codec = chooseCodec(codec)
    local encoder = CODECS[codec]
    local encoded, err = encoder.encode(tbl)
    if not encoded then return false, err end
    return encoded, #encoded, codec
end

function CybeRp.Networking.DecodeTable(data, codecId)
    local codecName = CODEC_BY_ID[codecId] or codecId or DEFAULT_CODEC
    local decoder = CODECS[codecName]
    if not decoder then return false, "unknown codec" end
    return decoder.decode(data)
end

function CybeRp.Networking.WritePayload(tbl, codec)
    local encoded, len, usedCodec = CybeRp.Networking.EncodeTable(tbl, codec)
    if not encoded then return false end

    net.WriteUInt(CODECS[usedCodec].id, CODEC_BITS)
    net.WriteUInt(len or 0, LENGTH_BITS)
    if len and len > 0 then
        net.WriteData(encoded, len)
    end
    return true
end

function CybeRp.Networking.ReadPayload()
    local codecId = net.ReadUInt(CODEC_BITS)
    local len = net.ReadUInt(LENGTH_BITS)
    if not len or len == 0 then return {} end
    local data = net.ReadData(len)
    local decoded, err = CybeRp.Networking.DecodeTable(data, codecId)
    if decoded == false then
        ErrorNoHalt(string.format("[CybeRp][Net] Failed to decode payload (%s)\n", err or "unknown"))
        return {}
    end
    return decoded or {}
end

if SERVER then
    for _, name in pairs(NET) do
        util.AddNetworkString(name)
    end

    print("[CybeRp] Networking Initialized")
end

