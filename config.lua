Config = {}

Config.Processing = {
    debug = {
        enabled     = false, -- enable/disable debug data (default: false)
    },
    showPrompts = {
        enter       = true,
        exit        = true,
        process     = true,
    },
    taskLength      = 15, -- seconds
    locations = {
        table       = vector3(1038.36, -3205.45, -38.88),
        outside     = vector4(-595.15, -1653.05, 20.63, 144.5),
        inside      = vector4(1066.04, -3183.46, -39.16, 94.64),
    }
}


Config.Field = {
    debug = {
        enabled     = false, -- enable/disable debug data (default: false)
    },
    showPrompts = {
        harvest     = false -- Show prompt at plant to tip off that you can harvest it? (default: true)
    },
    radius          = 45.0, -- radius from center of farm we want these plants to be able to grow - MUST BE A FLOAT! (default: 45.0)
    plantsToGrow    = 40, -- how many plants are we going to grow? (default: 40)
    chanceMature    = 75,  -- what % of the plants do we want pickable vs not? (default: 75)
    location        = vector3(290.19, 4316.75, 46.92), -- vector3 coords for center of the farm location (default: vector3(290.19, 4316.75, 46.92))
    growDistance    = 200, -- how far away from the field should the grow funciton run? (default: 200)
    models = {
        mature      = "prop_weed_01", -- grown and ready to pick
        -- mature     = "v_res_d_dildo_f",
        -- mature     = "h4_prop_weed_01_plant", -- grown and ready to pick (from island DLC)
        immature    = "prop_weed_02", -- not ready to pick
        -- immature   = "v_res_d_dildo_f"
    },
    reward = {          -- how many raw cannabis does the player get from each plant picked?
        min         = 1,
        max         = 3
    },
}

Keys = {
    ["ESC"]       = 322,  ["F1"]        = 288,  ["F2"]        = 289,  ["F3"]        = 170,  ["F5"]  = 166,  ["F6"]  = 167,  ["F7"]  = 168,  ["F8"]  = 169,  ["F9"]  = 56,   ["F10"]   = 57,
    ["~"]         = 243,  ["1"]         = 157,  ["2"]         = 158,  ["3"]         = 160,  ["4"]   = 164,  ["5"]   = 165,  ["6"]   = 159,  ["7"]   = 161,  ["8"]   = 162,  ["9"]     = 163,  ["-"]   = 84,   ["="]     = 83,   ["BACKSPACE"]   = 177,
    ["TAB"]       = 37,   ["Q"]         = 44,   ["W"]         = 32,   ["E"]         = 38,   ["R"]   = 45,   ["T"]   = 245,  ["Y"]   = 246,  ["U"]   = 303,  ["P"]   = 199,  ["["]     = 116,  ["]"]   = 40,   ["ENTER"]   = 18,
    ["CAPS"]      = 137,  ["A"]         = 34,   ["S"]         = 8,    ["D"]         = 9,    ["F"]   = 23,   ["G"]   = 47,   ["H"]   = 74,   ["K"]   = 311,  ["L"]   = 182,
    ["LEFTSHIFT"] = 21,   ["Z"]         = 20,   ["X"]         = 73,   ["C"]         = 26,   ["V"]   = 0,    ["B"]   = 29,   ["N"]   = 249,  ["M"]   = 244,  [","]   = 82,   ["."]     = 81,
    ["LEFTCTRL"]  = 36,   ["LEFTALT"]   = 19,   ["SPACE"]     = 22,   ["RIGHTCTRL"] = 70,
    ["HOME"]      = 213,  ["PAGEUP"]    = 10,   ["PAGEDOWN"]  = 11,   ["DELETE"]    = 178,
    ["LEFT"]      = 174,  ["RIGHT"]     = 175,  ["UP"]        = 27,   ["DOWN"]      = 173,
    ["NENTER"]    = 201,  ["N4"]        = 108,  ["N5"]        = 60,   ["N6"]        = 107,  ["N+"]  = 96,   ["N-"]  = 97,   ["N7"]  = 117,  ["N8"]  = 61,   ["N9"]  = 118
  }

local n = 0
function ShowDebugText(text, margin)
    text = text or "No Data"
    margin = 0.12*margin or 0

    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.3)
    SetTextColour(128, 128, 128, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.005, 0.06+margin)
end