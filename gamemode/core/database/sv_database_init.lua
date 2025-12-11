-- SQLite is default; abstracts easily to TMySQL4 / MySQLOO

CybeRp.DB = CybeRp.DB or {}

function CybeRp.DB.Initialize()
    print("[CybeRp] Database Initialized (SQLite)")
end

hook.Add("Initialize", "CybeRp_DB_Init", function()
    CybeRp.DB.Initialize()
end)

