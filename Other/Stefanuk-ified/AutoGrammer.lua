-- // Information
--[[
    Original by: eos (https://v3rmillion.net/showthread.php?tid=1156181)
    Edited by: Stefanuk12

    Note: I know that the iterations of Output can be combined but for the sake of seperating stuff out and such, I did it the way I did.
]]

-- // Configuration
local Configuration = {
    UseReplaceMethod = true,
    ReplaceDelay = 1 -- // (seconds) This is used for the "replace method",
}

-- // Services
local Players = game:GetService("Players")

-- // Vars
local CapitaliseI = true
local ReplaceDictionary = {
    ["i"] = "I",
    ["im"] = "I am",
    ["ive"] = "I've",
    ["dont"] = "don't",
    ["doesnt"] = "doesn't",
    ["cant"] = "can't",
    ["youre"] = "you're",
    ["ur"] = "your",
    ["u"] = "you",
    ["its"] = "it's",
    ["oh"] = "oh,",
    ["thnks"] = "thanks",
    ["thx"] = "thanks",
    ["git"] = "get",
    ["gud"] = "good",
    ["gramer"] = "grammar",
    ["grammer"] = "grammar",
    ["anymor"] = "anymore",
}
local QuestionPrompts = {
    "mean",
    "ask",
    "you",
    "care",
    "script",
    "is",
    "what",
    "how"
}
local Punctuation = {
    "!",
    ".",
    "?"
}

-- // Replace words
local function ReplaceWords(Output)
    -- // Loop through output
    for i, Word in ipairs(Output) do
        -- // Vars
        Word = Word:lower()
        local Replace = ReplaceDictionary[Word]

        -- // Make sure exists within our replace dictionary
        if (Replace) then
            -- // Replace the word
            Output[i] = Replace
        end
    end

    -- // Return
    return Output
end

-- // Capitalise
local function Capitalise(Output)
    -- // Make the first letter capital
    local FirstLetter = Output[1]:sub(1, 1)
    Output[1] = FirstLetter:upper() .. Output[1]:sub(2)

    -- // Capitalise all I's
    if (CapitaliseI) then
        -- // Loop through output
        for i, Word in ipairs(Output) do
            -- // Check if single i
            if (Word == "i") then
                -- // Make uppercase
                Output[i] = "I"
            end
        end
    end

    -- // Return
    return Output
end

-- // Add punctuation
local function Punctuate(Output)
    -- // Vars
    local LastWordI = #Output
    local LastWord = Output[LastWordI]

    local LastLetterI = #LastWord
    local LastLetter = LastWord:sub(LastLetterI, LastLetterI)

    -- // Make sure we have not already added punctuation to the last word
    if not (table.find(Punctuation, LastLetter)) then
        -- // Add a question mark or full stop, depending if it starts with a question prompt
        local Punctation = table.find(QuestionPrompts, Output[1]:lower()) and "?" or "."
        Output[LastWordI] = LastWord .. Punctation
    end

    -- // Return
    return Output
end

-- // Improves it all
local function Improve(Input)
    -- // Check if it is just empty space
    if (Input:match("^%s*$")) then
        return Input
    end

    -- // Vars
    local Output = Input:split(" ")

    -- // Do grammer
    Output = ReplaceWords(Output)
    Output = Capitalise(Output)
    Output = Punctuate(Output)

    -- // Return
    return table.concat(Output, " ")
end

-- // This handles the hook process
local function ReplaceHook(Old, ReplaceI, ...)
    -- // Vars
    local args = {...}

    -- // Replace the content of the message
    args[ReplaceI] = Improve(args[ReplaceI])

    -- // Return
    return Old(unpack(args))
end

-- // Initialises this script by using "replace method" - replaces the textbox text
local function InitialiseReplace(ChatScript)
    -- // Vars
    local ChatMain = require(ChatScript:WaitForChild("ChatMain"))
    local ChatBar = debug.getupvalue(ChatMain.FocusChatBar, 1)
    local TextBox = ChatBar:GetTextBox()
    local LastChangedText = tick()

    -- // See whenever the text changes
    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        LastChangedText = tick()
    end)

    -- //
    local Checker = coroutine.create(function()
        -- // Constant loop
        while (Configuration.UseReplaceMethod) do wait()
            -- // See if it has been since
            if not (tick() - LastChangedText >= Configuration.ReplaceDelay) then
                continue
            end

            -- // Improve text
            TextBox.Text = Improve(TextBox.Text)
        end
    end)
    coroutine.resume(Checker)

    -- // Return
    return Checker
end

-- // Initialises this script by using "hook method" - intercepts text when being sent
local function InitialiseHook()
    -- // Loop through GC
    for _, v in ipairs(getgc(true)) do
        -- // Make sure it is the table we are looking for
        if (typeof(v) == "table" and rawget(v, "SendMessage") and rawget(v, "RegisterSayMessageFunction")) then
            -- // Replace the function with our modified version
            local SendMessage = rawget(v, "SendMessage")
            rawset(v, "SendMessage", function(...)
                return ReplaceHook(SendMessage, 2, ...)
            end)
        end
    end
end


-- // Initialises for current spawn
if (Configuration.UseReplaceMethod) then
    InitialiseReplace(Players.LocalPlayer.PlayerScripts.ChatScript)
else
    InitialiseHook()
end