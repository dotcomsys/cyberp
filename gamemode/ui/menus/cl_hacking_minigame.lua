-- Hacking minigame client UI
net.Receive("cyberp_hack_minigame", function()
    local duration = net.ReadFloat()
    local seqLen = net.ReadUInt(5)
    local seq = {}
    for i = 1, seqLen do
        seq[i] = net.ReadString()
    end
    hook.Run("CybeRp_UI_StartHackMinigame", {
        duration = duration,
        sequence = seq
    })
end)
CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.Hacking = CybeRp.UI.Hacking or {}

local ACTIVE = nil

local function closeUI()
    if IsValid(ACTIVE) then
        ACTIVE:Remove()
    end
    ACTIVE = nil
end

local function buildUI(meta)
    closeUI()
    meta = meta or {}

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Breach Protocol")
    frame:SetSize(360, 200)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(true)

    local timerLabel = vgui.Create("DLabel", frame)
    timerLabel:SetFont("CybeRp.Subheader")
    timerLabel:SetText("Time: --")
    timerLabel:Dock(TOP)
    timerLabel:DockMargin(10, 10, 10, 0)
    timerLabel:SizeToContents()

    local progress = vgui.Create("DProgress", frame)
    progress:Dock(TOP)
    progress:DockMargin(10, 10, 10, 10)
    progress:SetTall(24)

    local keyLabel = vgui.Create("DLabel", frame)
    keyLabel:SetFont("CybeRp.Body")
    keyLabel:SetText("Press the highlighted keys in order.")
    keyLabel:Dock(TOP)
    keyLabel:DockMargin(10, 0, 10, 10)
    keyLabel:SetWrap(true)
    keyLabel:SetTall(40)

    local seq = meta.sequence or {"W", "A", "S", "D"}
    local idx = 1
    local duration = meta.duration or 8
    local endTime = CurTime() + duration
    local failed = false

    local buttons = {}
    local panel = vgui.Create("DPanel", frame)
    panel:Dock(FILL)
    panel:DockMargin(10, 0, 10, 10)
    panel.Paint = function() end

    local function updateButtons()
        for i, btn in ipairs(buttons) do
            btn:SetText(seq[i])
            btn:SetEnabled(i == idx)
            btn:SetAlpha(i < idx and 80 or 255)
        end
    end

    for i = 1, #seq do
        local btn = vgui.Create("DButton", panel)
        btn:SetSize(64, 32)
        btn:SetText(seq[i])
        btn:Dock(LEFT)
        btn:DockMargin(4, 4, 4, 4)
        btn.DoClick = function()
            if i ~= idx then
                failed = true
                closeUI()
                return
            end
            idx = idx + 1
            if idx > #seq then
                closeUI()
                net.Start(CybeRp.NET.HACK_RESULT)
                net.SendToServer()
            else
                updateButtons()
            end
        end
        buttons[#buttons + 1] = btn
    end
    updateButtons()

    frame.Think = function()
        local remaining = math.max(0, endTime - CurTime())
        timerLabel:SetText(string.format("Time: %.1fs", remaining))
        progress:SetFraction(1 - (remaining / duration))
        if remaining <= 0 then
            failed = true
            closeUI()
        end
    end

    frame.OnRemove = function()
        if failed then
            net.Start(CybeRp.NET.HACK_RESULT)
                net.WriteBool(false)
            net.SendToServer()
        end
    end

    ACTIVE = frame
end

hook.Add("CybeRp_Net_HackResult", "CybeRp_UI_HackResultClose", function()
    closeUI()
end)

hook.Add("CybeRp_UI_StartHackMinigame", "CybeRp_UI_HackOpen", function(meta)
    buildUI(meta or {})
end)


