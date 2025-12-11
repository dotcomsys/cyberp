CybeRp.Cyberware = CybeRp.Cyberware or {}

function CybeRp.Cyberware.Give(ply, id)
    ply.Cyberware = ply.Cyberware or {}
    ply.Cyberware[id] = true

    net.Start(CybeRp.NET.CYBERWARE_UPDATE)
    net.WriteString(id)
    net.Send(ply)

    print("[CybeRp] Installed Cyberware:", id)
end

