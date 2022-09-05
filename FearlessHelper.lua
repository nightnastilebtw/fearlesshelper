script_name('FearlessHelper')
script_author('night')
script_version(0.4)


local keys = require "vkeys"
local imgui = require("imgui")
local sw, sh = getScreenResolution()
local encoding = require ("encoding")
local inicfg = require("inicfg")
local sampev = require('lib.samp.events')
local dlstatus = require('moonloader').download_status
local mem = require "memory"
local window = imgui.ImBool(false)
local tag = '{9461FF}[FearlessHelper] {FFFFFF}'
local adsend = false

update_state = false

tableguns = {
    ['de'] = 348,
    ['m4'] = 356,
    ['uz'] = 352,
    ['ak'] = 355,
    ['mp5'] = 353,
	['shg'] = 349,
	['rfl'] = 357
}
gname, ammoclip, findedgun = 'nothing', -1, false
local active = true
local click_delay = 120 
local tds = {
    ['prev'] = {id = -1, text = 'LD_BEAT:chit', x = 233, y = 215},  -- default id: 131
    ['next'] = {id = -1, text = 'LD_BEAT:chit', x = 390, y = 215},  -- default id: 130
    ['max'] = {id = -1, text = '0', x = 320, y = 199},              -- default id: 2064
    ['fill'] = {id = -1, text = 'FILL', x = 375, y = 243},          -- default id: 144
    ['fuel_name'] = {id = -1, text = 'DIESEL', x = 301, y = 218}    -- default id: 2063
}
local clists = {
	-- Advance RP
	{
		0xFF009900, -- grove.
		0xFFCC00FF, -- ballas.
		0xFFFFCD00, -- vagos.
		0xFF6666FF, -- rifa.
		0xFF00CCFF, -- aztec.
		0xFF993366, -- lcn.
		0xFFBB0000, -- yakuza.
		0xFF007575, -- russian mafia.
		0x00222222, -- masked.
		0x11FFFFFF, -- bomj.
	},
	-- Samp RP
	{
		0xAA09A400, -- grove.
		0xAAC515FF, -- ballas.
		0xAAFFDE24, -- vagos.
		0xAA2EA07B, -- rifa.
		0xAA0DEDFF, -- aztec.
		0xAAF4B800, -- lcn.
		0xAAFF0606, -- yakuza.
		0xAAB8B6B6, -- russian mafia.
		0xAA383838, -- masked.
		0x00FFFFFF, -- bomj.
	},
	-- Pears Project
	{
		0xAA00CC00, -- grove.
		0xAA9900CC, -- ballas.
		0xAAFFCC33, -- vagos.
		0xAA00FFFF, -- aztecas.
		0xAACCCC00, -- lcn.
		0xAA990000, -- yakuza.
		0xAA333333, -- russian mafia.
		0xAA663300, -- arabian mafia.
		0xAA003366, -- triada mafia.
		0x00FFFFFF, -- hitmans.
		0x20FFFFFF -- bomj.
	},
	-- Arizona RP
	{
		0x99009327, -- grove.
		0x99CC00CC, -- ballas.
		0x996666FF, -- rifa.
		0x99D1DB1C, -- vagos.
		0x9900FFE2, -- aztecas.
		0x80993366, -- lcn.
		0x80298CB7, -- russian mafia.
		0x80960202, -- yakuza.
		0x80BA541D, -- warlock.
		0x807F6464, -- night wolfs.
		0x1665E5E, -- masked.
		0x15FDFCFC -- bomj.
	},
	-- Diamond RP
	{
		0xAA009900, -- grove.
		0xAACC00FF, -- ballas.
		0xAAFBD400, -- vagos.
		0xAA6666FF, -- rifa.
		0xAA1060AC, -- aztec.
		0xAA9EFF4F, -- mexican mafia.
		0xAAFF0000, -- yakuza.
		0xFF5C1ACC, -- columbian mafia
		0x7A7667, -- masked.
		0x11FFFFFF, -- bomj.
	},
	-- Evolve RP
	{
		0xAA009F00, -- grove.
		0xFFB313E7, -- ballas.
		0xFFFFDE24, -- vagos.
		0xFF2A9170, -- rifa.
		0xC801FCFF, -- aztec.
		0xFFDDA701, -- lcn.
		0xAAFF0000, -- yakuza.
		0xFF114D71, -- russian mafia.
		0xFF333333, -- masked.
		0x00FFFFFF, -- bomj.
	}
}
local texts = {
	-- advance rp
	'Grove: {$CLR}$CNT {FFFFFF}| Ballas: {$CLR}$CNT {FFFFFF}| Vagos: {$CLR}$CNT {FFFFFF}| Rifa: {$CLR}$CNT {FFFFFF}| Aztecas: {$CLR}$CNT\nLCN: {$CLR}$CNT {FFFFFF}| Yakuza: {$CLR}$CNT {FFFFFF}| Russian Mafia: {$CLR}$CNT\nMasked: {$CLR}$CNT {FFFFFF}| Bomj: {$CLR}$CNT',
	-- samp rp
	'Grove: {$CLR}$CNT {FFFFFF}| Ballas: {$CLR}$CNT {FFFFFF}| Vagos: {$CLR}$CNT {FFFFFF}| Rifa: {$CLR}$CNT {FFFFFF}| Aztecas: {$CLR}$CNT\nLCN: {$CLR}$CNT {FFFFFF}| Yakuza: {$CLR}$CNT {FFFFFF}| Russian Mafia: {$CLR}$CNT\nMasked: {$CLR}$CNT {FFFFFF}| Bomj: {$CLR}$CNT',
	-- pears project
	'Grove: {$CLR}$CNT {FFFFFF}| Ballas: {$CLR}$CNT {FFFFFF}| Vagos: {$CLR}$CNT {FFFFFF}| Aztecas: {$CLR}$CNT {FFFFFF}\nLCN: {$CLR}$CNT {FFFFFF}| Yakuza: {$CLR}$CNT {FFFFFF}| Russian Mafia: {$CLR}$CNT {FFFFFF}| Arabian Mafia: {$CLR}$CNT\nTriada Mafia: {$CLR}$CNT {FFFFFF}| Hitmans: {$CLR}$CNT {FFFFFF}| Bomj: {$CLR}$CNT',
	-- arizona rp
	'Grove: {$CLR}$CNT {FFFFFF}| Ballas: {$CLR}$CNT {FFFFFF}| Rifa: {$CLR}$CNT {FFFFFF}| Vagos: {$CLR}$CNT {FFFFFF}| Aztecas: {$CLR}$CNT {FFFFFF}\nLCN: {$CLR}$CNT {FFFFFF}| Russian Mafia: {$CLR}$CNT {FFFFFF}| Yakuza: {$CLR}$CNT {FFFFFF}| Warlock MC: {$CLR}$CNT {FFFFFF}\nNight Wolfs: {$CLR}$CNT {FFFFFF}| Masked: {$CLR}$CNT {FFFFFF}| Bomj: {$CLR}$CNT',
	-- diamond rp
	'Grove: {$CLR}$CNT {FFFFFF}| Ballas: {$CLR}$CNT {FFFFFF}| Vagos: {$CLR}$CNT {FFFFFF}| Rifa: {$CLR}$CNT {FFFFFF}| Aztecas: {$CLR}$CNT\nMexican Mafia: {$CLR}$CNT {FFFFFF}| Yakuza: {$CLR}$CNT {FFFFFF}| Columbian Mafia: {$CLR}$CNT\nMasked: {$CLR}$CNT {FFFFFF}| Bomj: {$CLR}$CNT',
	-- evolve rp
	'Grove: {$CLR}$CNT {FFFFFF}| Ballas: {$CLR}$CNT {FFFFFF}| Vagos: {$CLR}$CNT {FFFFFF}| Rifa: {$CLR}$CNT {FFFFFF}| Aztecas: {$CLR}$CNT\nLCN: {$CLR}$CNT {FFFFFF}| Yakuza: {$CLR}$CNT {FFFFFF}| Russian Mafia: {$CLR}$CNT\nMasked: {$CLR}$CNT {FFFFFF}| Bomj: {$CLR}$CNT'
}
local ALL_MENU_TDS = { {id = 2062, x = 245, y = 187}, {id = 115, x = 331, y = 257}, {id = 2063, x = 301, y = 218}, {id = 116, x = 223, y = 257}, {id = 2064, x = 320, y = 199}, {id = 117, x = 387, y = 177}, {id = 118, x = 235, y = 183}, {id = 119, x = 234, y = 192}, {id = 120, x = 222, y = 176}, {id = 121, x = 229, y = 210}, {id = 122, x = 387, y = 210}, {id = 123, x = 243, y = 203}, {id = 124, x = 223, y = 178}, {id = 125, x = 228, y = 183}, {id = 126, x = 234, y = 195}, {id = 127, x = 229, y = 190}, {id = 128, x = 232, y = 198}, {id = 129, x = 244, y = 186}, {id = 130, x = 390, y = 215}, {id = 131, x = 233, y = 215}, {id = 132, x = 397, y = 217}, {id = 133, x = 239, y = 217}, {id = 134, x = 301, y = 199}, {id = 135, x = 350, y = 197}, {id = 136, x = 289, y = 197}, {id = 137, x = 388, y = 234}, {id = 138, x = 338, y = 234}, {id = 139, x = 229, y = 235}, {id = 140, x = 276, y = 235}, {id = 141, x = 243, y = 241}, {id = 142, x = 353, y = 241}, {id = 143, x = 266, y = 243}, {id = 144, x = 375, y = 243}, {id = 2062, x = 245, y = 187}, {id = 2062, x = 245, y = 187}, {id = 2062, x = 245, y = 187}, {id = 2062, x = 245, y = 187}, {id = 2062, x = 245, y = 187} }

encoding.default = "CP1251"
u8 = encoding.UTF8

defaultState = false
bike = {[481] = true, [509] = true, [510] = true, [15882] = true}
moto = {[448] = true, [461] = true, [462] = true, [463] = true, [468] = true, [471] = true, [521] = true, [522] = true, [523] = true, [581] = true,}

local mainIni = inicfg.load({ -- CFG
    mode = 1, 
    settings = {
        rp_invite = false,
        prospammer = false,
        spawn_cars = true,
        fill_cars = true, 
		sklad = true,
        skins = true,
        rank = true,
        fastmute = false,
        fastuval = false,
        muteminutes = 1,
        famint = 1,
        orgint = 1,
        orgint2 = 1,
        nabint = 1,
        inv_ranks = 1,
        mutetext = 'Помехи в рацию.',
        uvaltext = 'Выселен.',
        prospamtext1 = 'Тут может быть ваш текст.',
        prospamtext2 = 'Тут может быть ваш текст.',
        prospamtext3 = 'Тут может быть ваш текст.',
        CmdM4 = true,
        CmdDe = true,
        nabor = false,
        bankparol = true,
        famflood = false,
        parolbank = 'Ваш пароль',
        nabortext1 = 'Ваш текст',
        nabortext2 = 'Ваш текст2',
        nabortext3 = 'Ваш текст3',
        famtext3 = 'Ваш текст3',
        blacklist = ''
    }
}, "fearlesshelper")
local mutetext = imgui.ImBuffer(u8(mainIni.settings.mutetext), 256)
local uvaltext = imgui.ImBuffer(u8(mainIni.settings.uvaltext), 256)
local prospamtext1 = imgui.ImBuffer(u8(mainIni.settings.prospamtext1), 256)
local prospamtext2 = imgui.ImBuffer(u8(mainIni.settings.prospamtext2), 256)
local prospamtext3 = imgui.ImBuffer(u8(mainIni.settings.prospamtext3), 256)
local nabortext1 = imgui.ImBuffer(u8(mainIni.settings.nabortext1), 256)
local nabortext2 = imgui.ImBuffer(u8(mainIni.settings.nabortext2), 256)
local nabortext3 = imgui.ImBuffer(u8(mainIni.settings.nabortext3), 256)
local famtext3 = imgui.ImBuffer(u8(mainIni.settings.famtext3), 256)
local parolbank = imgui.ImBuffer(u8(mainIni.settings.parolbank), 256)
local nabor = imgui.ImBool(mainIni.settings.nabor)
local famflood = imgui.ImBool(mainIni.settings.famflood)
local bankparol = imgui.ImBool(mainIni.settings.bankparol)
local blacklist = imgui.ImBuffer(u8(mainIni.settings.blacklist), 256)
local rp_invite = imgui.ImBool(mainIni.settings.rp_invite)
local inv_ranks = imgui.ImInt(mainIni.settings.inv_ranks)
local muteminutes = imgui.ImInt(mainIni.settings.muteminutes)
local famint = imgui.ImInt(mainIni.settings.famint)
local orgint = imgui.ImInt(mainIni.settings.orgint)
local orgint2 = imgui.ImInt(mainIni.settings.orgint2)
local nabint = imgui.ImInt(mainIni.settings.nabint)
local skins = imgui.ImBool(mainIni.settings.skins)
local rank = imgui.ImBool(mainIni.settings.rank)
local prospammer = imgui.ImBool(mainIni.settings.prospammer)
local spawn_cars = imgui.ImBool(mainIni.settings.spawn_cars)
local fill_cars = imgui.ImBool(mainIni.settings.fill_cars)
local sklad = imgui.ImBool(mainIni.settings.sklad)
local fastmute = imgui.ImBool(mainIni.settings.fastmute)
local fastuval = imgui.ImBool(mainIni.settings.fastuval)


--------------АВТООБНОВА


local script_vers = 1
local script_vers_text = "1.0"
local script_path = thisScript().path
local script_url = "https://raw.githubusercontent.com/nightnastilebtw/fearlesshelper/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"
local update_url = ""



--------------------------


local status = inicfg.load(mainIni, 'fearlesshelper.ini')
if not doesFileExist('moonloader/config/fearlesshelper.ini') then inicfg.save(mainIni, 'fearlesshelper.ini') end

local functionslist = [[
    Функции Fearless Helper:
    /sc - Быстрый спавн транспорта банды
    /fc - Быстрая заправка транспорта банды
    /sk - Открытие/закрытие склада банды
    /spamm - Запустить флуд в чат банды
    /fspam - Запустить флуд в чат фамы
    /fm [ID] - Быстрый мут
    /fu [ID] - Быстрое увольнение
    /gs [ID] [SkinID] - Быстрая выдача скина
    /gr [ID] [Rank] - Быстрая выдача ранга
    /bcl - Очистить буфер памяти
    /cb - Показать онлайн банд
    /cde [amount] - Сделать дигла [Из Материалов]
    /cm4 [amount] - Сделать эмки  [Из Материалов]
    /de [amount] - Взять Deagle из Инвентаря
    /m4 [amount] - Взять M4 из Инвентаря
    /uz [amount] - Взять Uzi из Инвентаря
    /rfl [amount] - Взять Country Rifle из Инвентаря
    /ak [amount] - Взять AK-47 из Инвентаря
    /shg [amount] - Взять Shotgun из Инвентаря
    
    Зажимаете shift + w - Ускоряетесь на мото или вело
    За основу был взят Ghetto Helper]]
----------------------------------------------------------------------
--РЕГИСТРИРОВАНИЕ КОМАНД СНИЗУ
----------------------------------------------------------------------
function main()
    while not isSampAvailable() do wait(200) end
    local font = renderCreateFont("Arial", 10, 5)
	sampAddChatMessage(tag..'Успешно загружен! Настройка: {9461FF}/fh(elper) или же с помощью клавиши F3!', -1)
    sampRegisterChatCommand('fh', ghelper)
	sampRegisterChatCommand('fhelper', ghelper)

    downloadUrlToFile(update_url, update_path, function (id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage(tag.."Есть новое доступное обновление! Версия" .. updateIni.vers.text_text)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
    
    sampRegisterChatCommand('spamm', prospam)
    sampRegisterChatCommand('sc', sc)
    sampRegisterChatCommand('fc', fc)
	sampRegisterChatCommand('sk', sk)
	sampRegisterChatCommand("fm", fm)
    sampRegisterChatCommand("fu", fu)
    sampRegisterChatCommand("gs", skins)
    sampRegisterChatCommand('gr', rank)
    sampRegisterChatCommand('nlomka', nlomka)
    sampRegisterChatCommand('vra', function(text) 
        adsend = true
        sampSendChat('/vr '..text)
    end)
    sampRegisterChatCommand('vr', function(text)
        adsend = false
        sampSendChat('/vr '..text)
    end)
    current_server = getCurrentServer(sampGetCurrentServerName())
	assert(current_server, 'Server not found.')
	sampRegisterChatCommand('cb', function()
		local text = texts[current_server]
		for i = 1, #clists[current_server] do
			local online = 0
			for l = 0, 1004 do
				if sampIsPlayerConnected(l) then
					if sampGetPlayerColor(l) == clists[current_server][i] then online = online + 1 end
				end
			end
			text = text:gsub('$CLR', ('%06X'):format(bit.band(clists[current_server][i], 0xFFFFFF)), 1)
			text = text:gsub('$CNT', online, 1)
		end
		for w in text:gmatch('[^\r\n]+') do sampAddChatMessage(w, -1)end
	end)
    sampRegisterChatCommand('de',function(arg) getguninvent('de',arg) end)
    sampRegisterChatCommand('m4',function(arg) getguninvent('m4',arg) end)
    sampRegisterChatCommand('uz',function(arg) getguninvent('uz',arg) end)
    sampRegisterChatCommand('aafk', afk)
    sampRegisterChatCommand('ak',function(arg) getguninvent('ak',arg) end)
    sampRegisterChatCommand('mp5',function(arg) getguninvent('mp5',arg) end)
    sampRegisterChatCommand('nab', naborspam)
    sampRegisterChatCommand('shg',function(arg) getguninvent('shg',arg) end)
    sampRegisterChatCommand('rfl',function(arg) getguninvent('rfl',arg) end)
    sampRegisterChatCommand('probiv', cmd_probiv)
    sampRegisterChatCommand('fspam', famchatflooder)
    sampRegisterChatCommand("update", cmd_update)
    sampRegisterChatCommand('pb', autobankparol)
    sampRegisterChatCommand("bcl", _con)
    sampRegisterChatCommand("cde", function(arg)
        if mainIni.settings.CmdDe then
            lua_thread.create(function()
                if arg == '' or arg == nil or arg == 0 then
                    sampAddChatMessage(tag..'Введите кол-во патрон', -1)
                else
                    ptde = arg
                    sampSendChat('/creategun')
                    wait(100)
                    sampSendDialogResponse(7546, 1, 0, _)
                    wait(100)
                    sampSetCurrentDialogEditboxText(ptde)
                    wait(100)
                    sampCloseCurrentDialogWithButton(1)
                end
            end)
        else 
            sampSendChat('/1')
        end
     end)
     sampRegisterChatCommand("cm4", function(arg)
        if mainIni.settings.CmdM4 then
            lua_thread.create(function()
                if arg == '' or arg == nil or arg == 0 then
                    sampAddChatMessage(tag..'Введите кол-во патрон', -1)
                else
                    ptm4 = arg
                    sampSendChat('/creategun')
                    wait(100)
                    sampSendDialogResponse(7546, 1, 3, _)
                    wait(100)
                    sampSetCurrentDialogEditboxText(ptm4)
                    wait(100)
                    sampCloseCurrentDialogWithButton(1)
                end
            end)
        else 
            sampSendChat('/1')
        end
    end)
    sampRegisterChatCommand('agfill', function()
        active = not active
        sampAddChatMessage(tag..'[AutoGasFill]: {ffffff}'..(active and 'включен' or 'выключен'), 0xFFff004d)
    end)

----------------------------------------------------------------------
--РЕГИСТРИРОВАНИЕ КОМАНД СВЕРХУ
----------------------------------------------------------------------


    while true do --БЕСК ЦИКЛ
        wait(0)
        imgui.Process = window.v


        if update_state then
            downloadUrlToFile(update_url, update_path, function (id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage(tag.."Скрипт успешно обновлен!", -1)
                    thisScript():reload()
          
                end
            end)
            break
        end



        wait(0)
        if isKeyDown(0x12) and isKeyJustPressed(0x31) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("/usedrugs 3")
            wait(100)
            sampSendChat("FearlessHelper top!")
        
        end
        wait(0)
        if isKeyDown(0x12) and isKeyJustPressed(0x32) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("/usedrugs 3")
            
        
        end
        wait(0)
        if isKeyDown(0x12) and isKeyJustPressed(0x33) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("/armour")
            
        
            
        end
        wait(0)
        if isKeyDown(0x12) and isKeyJustPressed(0x34) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("/mask")
            
        end
        wait(0)
        if isKeyJustPressed(0x52) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("q") 
        
        end
        wait(0)
        if isKeyDown(0x12) and isKeyJustPressed(0x35) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampProcessChatInput("/de 50")
            
        end
        wait(0)
        if isKeyDown(0x12) and isKeyJustPressed(0x36) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampProcessChatInput("/m4 100")
            
        end
        if isKeyJustPressed(0x4C) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("/lock")
            
        end
        if isKeyJustPressed(0x4C) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("/lock")
            
        end
        if isKeyJustPressed(0x30) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("/point")
            
        end
        if isKeyJustPressed(0x72) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampProcessChatInput("/fh")
            
        end
  
        if isCharOnAnyBike(playerPed) and isKeyCheckAvailable() and isKeyDown(0xA0) then	-- onBike&onMoto SpeedUP [[LSHIFT]] --
			if bike[getCarModel(storeCarCharIsInNoSave(playerPed))] then
				setGameKeyState(16, 255)
				wait(10)
				setGameKeyState(16, 0)
			elseif moto[getCarModel(storeCarCharIsInNoSave(playerPed))] then
				setGameKeyState(1, -128)
				wait(10)
				setGameKeyState(1, 0)
			end
		end
		
		if isCharOnFoot(playerPed) and isKeyDown(0x31) and isKeyCheckAvailable() then -- onFoot&inWater SpeedUP [[1]] --
			setGameKeyState(16, 256)
			wait(10)
			setGameKeyState(16, 0)
		elseif isCharInWater(playerPed) and isKeyDown(0x31) and isKeyCheckAvailable() then
			setGameKeyState(16, 256)
			wait(10)
			setGameKeyState(16, 0)
		end

        if rp_invite.v then
            local result, target = getCharPlayerIsTargeting(playerHandle)
            if result then result, playerid = sampGetPlayerIdByCharHandle(target) end 
            if result and isKeyDown(0x5A) then 
                name = sampGetPlayerNickname(playerid) 
                sampSendChat('/me передал бандану')
                wait(1000)
                sampSendChat('/invite '..playerid)
                    wait(3500)
                    setVirtualKeyDown(0x1B, true)
                    setVirtualKeyDown(0x1B, false)

                    if inv_ranks.v ~= 1 and inv_ranks.v ~= nil then
                    sampSendChat('/giverank '..playerid..' '..inv_ranks.v)
                    end
                    wait(250)
                    sampAddChatMessage(tag..'Вы приняли игрока с ником: '..name..' | Ранг: '..inv_ranks.v, -1)
                    end
                end
            end
        end
    
                
                
            
              
  
function encda()
    commandslist.v = u8:encode(functionslist)
end

commandslist = imgui.ImBuffer(65536)

function fc()
	if fill_cars.v then
	sampSendChat('/lmenu')
	sampSendDialogResponse(1214, 1, 5, -1)
    return false
    end
end

function sc()
	if spawn_cars.v then
    sampSendChat('/lmenu')
    sampSendDialogResponse(1214, 1, 4, -1)
    return false
	end
end

function sk()
	if sklad.v then 
    sampSendChat('/lmenu')
    sampSendDialogResponse(1214, 1, 3, -1)
    return false
	end
end

function skins(param)
	if state then
		state = false
	elseif not param:match('%d+') then
		sampAddChatMessage(tag..'Правильный ввод: /gs [ID] [SkinID]', -1)
	else
			id = tonumber(param)
			state = true
			sampSendChat('/giveskin '..param..' '..param..'')
            sampSendDialogResponse(9188, 1, 0, -1)
            sampCloseCurrentDialogWithButton(0)
			state = false
	end
end

function rank(param)
	if state then
		state = false
	elseif not param:match('%d+') then
		sampAddChatMessage(tag..'Правильный ввод: /gr [ID] [Rank]', -1)
	else
			id = tonumber(param)
			state = true
			sampSendChat('/giverank '..param..' '..param..'')
			state = false
	end
end

function fm(param)
    if fastmute.v then
	if state then
		state = false
	elseif not param:match('%d+') then
		sampAddChatMessage(tag..'Правильный ввод: /fm [ID]', -1)
	else
			id = tonumber(param)
			state = true
			sampSendChat('/fmute '..param..' '..muteminutes.v..' '..u8:decode(mutetext.v), -1)
			state = false
    end
	end
end

function fu(param)
	if state then
		state = false
	elseif not param:match('%d+') then
		sampAddChatMessage(tag..'Правильный ввод: /fu [ID]', -1)
	else
			id = tonumber(param)
			state = true
			sampSendChat('/uninvite '..param..' '..u8:decode(uvaltext.v), -1)
			state = false
	end
end


function nameTagOn()
    local pStSet = sampGetServerSettingsPtr();
    NTdist = mem.getfloat(pStSet + 39)
    NTwalls = mem.getint8(pStSet + 47)
    NTshow = mem.getint8(pStSet + 56)
    mem.setfloat(pStSet + 39, 1488.0)
    mem.setint8(pStSet + 47, 0)
    mem.setint8(pStSet + 56, 1)
    nameTag = true
end
  
function nameTagOff()
    local pStSet = sampGetServerSettingsPtr();
    mem.setfloat(pStSet + 39, NTdist)
    mem.setint8(pStSet + 47, NTwalls)
    mem.setint8(pStSet + 56, NTshow)
    nameTag = false
end

function ghelper()
    window.v = not window.v 
end

function imgui.OnDrawFrame()
    if window.v then  
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(1024, 420), imgui.Cond.FirstUseEver)
        imgui.Begin('Fearless Helper', window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize )  
        imgui.BeginChild("##MainWindow", imgui.ImVec2(580, 320), true)
            switch(mainIni.mode)
            {
                function ()
                    imgui.TextQuestion(u8'Полезные функции, которые вам облегчат игру!')
                    imgui.SameLine()
                    imgui.Text(u8'Для лидеров или их заместителей')
                    imgui.PushItemWidth(85.5)
                    imgui.TextQuestion(u8'Автоматически будет отправлять инвайт с отыгровкой. Активация: ПКМ + Z')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Быстрый инвайт', rp_invite)
                    if rp_invite.v then
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputInt(u8'Ранг при инвайте', inv_ranks)
                    end
                        if inv_ranks.v <= 0 or inv_ranks.v >= 9 then
                            inv_ranks.v = 1
                    end
                        
                    
                    
                    
                    imgui.PushItemWidth(120)
                    imgui.TextQuestion(u8'Быстрая выдача мута члену банды. Активация: /fm [ID]')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Быстрый мут', fastmute)
                    if fastmute.v then
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.SliderInt(u8"Кол-во минут мута", muteminutes, 1, 60, 1.0)
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'Причина мута', mutetext)
                    end
                    imgui.TextQuestion(u8'Быстрое увольнение члена банды. Активация: /fu [ID]')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Быстрое увольнение', fastuval)
                    if fastuval.v then
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'Причина увольнения', uvaltext)
                    end
                    imgui.PushItemWidth(290)
                    imgui.TextQuestion(u8'Проспамить правилами/информацией. Значение устанавливайте в секундах. Активация: /spamm')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Флудер организации', prospammer)
                    if prospammer.v then
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'##1', prospamtext1)
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'##2', prospamtext2)
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'##3', prospamtext3)
                        imgui.TextQuestion(u8'Устанавливает КД между вашими сообщениями в секунде. Если поставили допустим секунды - тогда отправиться первое сообщение и спустя 3 секунды уже второе')
                        imgui.SameLine()
                        imgui.SliderInt(u8"КД между сообщениями ", orgint, 1, 180, 1.0)
                        imgui.TextQuestion(u8'Устанавливает задержку между срабатываением флудера')
                        imgui.SameLine()
                        imgui.SliderInt(u8"КД между работой флудера", orgint2, 1, 300, 1.0)
                    end
                    
                    imgui.TextQuestion(u8'Флудер о наборе. /nab - активация. Пишет ваш текст каждые N-ое кол-во секунд которые вы поставили. Если не хотите что-бы он отправлялся куда-то, оставьте поле пустым')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Флудер набора', nabor)
                    if nabor.v then
                        imgui.NullText()
                        imgui.SameLine()                        
                        imgui.InputText(u8'Отправка в вип чат', nabortext1)                                              
                        imgui.NullText()
                        imgui.SameLine()                   
                        imgui.InputText(u8'Отправка в семейный чат', nabortext2)                        
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'Отправка в радиостанцию', nabortext3) 
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.SliderInt(u8"КД отправки", nabint, 1, 300, 1.0)
                        imgui.SameLine()
                        imgui.TextQuestion(u8'Ставьте не менее 60, что-бы не получить мут от бота. Значения устанавливаются в секундах!')                   
                    end
                    imgui.TextQuestion(u8'Флудер семьи. /fspam - активация. Пишет ваш текст в чат семьи. Устанавливайте кд в СЕКУНДАХ')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Флудер семьи.', famflood)
                    if famflood.v then
                        
                        
                        imgui.TextQuestion(u8'КД между вашими сообщениями в секундах')
                        imgui.SameLine()
                        imgui.SliderInt(u8"##", famint, 1, 180, 1.0)
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'Пишет данный текст в чат вашей фамы', famtext3)
                    end
    
                    
    
                    imgui.Separator()
                    imgui.Text(u8'Полезные команды в нашем хелпере')
                    

                    imgui.TextQuestion(u8'Используйте на свой страх и риск!')
                    imgui.SameLine()
                    imgui.Text(u8'/nlomka - Прокачивать ломку наркотиками')
                    imgui.TextQuestion(u8'Используйте на свой страх и риск! Пробивает все кроме таба, консоли и обвесов')
                    imgui.SameLine()
                    imgui.Text(u8'/probiv - Автопробив')
                    
                    imgui.TextQuestion(u8'По дефолту включена, заправляет автоматически')
                    imgui.SameLine()
                    imgui.Text(u8'/agfill - Автозаправка')
                    imgui.Separator()
                    imgui.Text(u8' Автоввод пароля в банке')  
                    imgui.TextQuestion(u8'/pb - Активация автопароля')
                    imgui.SameLine()                
                    imgui.Checkbox(u8'- Ваш пароль. ', bankparol)
                    if bankparol.v then  
                        imgui.NullText()
                        imgui.SameLine()  
                        imgui.InputText(u8'Введите сюда ваш пароль', parolbank)                                                                                                                                                
                    end
                    
                   

                    
                    
                    
                    
                    imgui.Text(u8'/vr - Обычная отправка сообщения [В ВипЧат]')
                    imgui.Text(u8'/vra - Рекламная отправка сообщения [В ВипЧат]')
                   
                    
                    
                    
                    
                    imgui.Separator()
                    imgui.Text(u8'Полезные бинды в нашем хелпере')
                    imgui.SameLine()
                    imgui.TextQuestion(u8'Для корректной работы подержите сочетание клавиш около 1 секунды')
                    
                    imgui.Text(u8'ALT + 1 = Использовать нарко и сбить его')
                    imgui.Text(u8'ALT + 2 = Использовать наркотики')
                    imgui.Text(u8'ALT + 3 = Использовать броник')
                    imgui.Text(u8'ALT + 4 = Использовать маску')
                    imgui.Text(u8'Alt + 5 = Зарядить 50 дигла')
                    imgui.Text(u8'Alt + 6 = Зарядить 100 м4')
                    imgui.Text(u8'Alt + 0 = Поставить /point')
                    imgui.Text(u8'L = Открыть/Закрыть Т/С')
                    imgui.Text(u8'R = Показать распальцовку')
                    
 
                    imgui.Separator()

                    imgui.Text(u8'ВСЕ НАХОДИТЬСЯ НА СТАДИИ РАЗРАБОТКИ И ТЕСТА')
                    imgui.Text(u8'ЕСЛИ У ВАС БАГИ ИЛИ ВЫЛЕТЫ ПИШИТЕ В ВК')
                    
                    
                   
                    imgui.Text(u8'Если у вас есть идеи по улучшению так-же пишите в вк(ссылка снизу)')
                    if imgui.Button(u8'Night[VK]',imgui.ImVec2(170,30)) then
                        os.execute('start https://vk.com/danilo_chernov')
                    end
                    imgui.SameLine()
                    if imgui.Button(u8'Vanya[VK]',imgui.ImVec2(170,30)) then
                        os.execute('start https://vk.com/sugar_person')
                    end
                    if imgui.Button(u8'Group[VK]') then
                        os.execute('start https://vk.com/fearlessqd')
                    end
                   
                    

                end,
                function ()			
                    mainIni.settings.rp_invite = rp_invite.v 
                    mainIni.settings.inv_ranks = inv_ranks.v  
                    mainIni.settings.fastmute = fastmute.v
                    mainIni.settings.fastuval = fastuval.v
                    mainIni.settings.muteminutes = muteminutes.v
                    mainIni.settings.prospammer = prospammer.v
                    mainIni.settings.prospamtext1 = u8:decode(prospamtext1.v)
                    mainIni.settings.prospamtext2 = u8:decode(prospamtext2.v)
                    mainIni.settings.prospamtext3 = u8:decode(prospamtext3.v)
                    mainIni.settings.mutetext = u8:decode(mutetext.v)
                    mainIni.settings.nabortext1 = u8:decode(nabortext1.v)
                    mainIni.settings.nabortext2 = u8:decode(nabortext2.v)
                    mainIni.settings.nabortext3 = u8:decode(nabortext3.v)
                    mainIni.settings.parolbank = u8:decode(parolbank.v)
                    mainIni.settings.nabor = nabor.v
                    mainIni.settings.nabint = nabint.v
                    mainIni.settings.orgint = orgint.v
                    mainIni.settings.orgint2 = orgint2.v
                    mainIni.settings.famflood = famflood.v
                    mainIni.settings.bankparol = bankparol.v
                    mainIni.settings.blacklist = blacklist.v
                    mainIni.settings.uvaltext = u8:decode(uvaltext.v)
                    inicfg.save(mainIni, 'fearlesshelper.ini')
                    sampAddChatMessage(tag.."Настройки успешно сохранены.", -1)
                    addOneOffSound(0.0, 0.0, 0.0, 1138)
                    mainIni.mode = 1
                end
            }
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("##bindercommand", imgui.ImVec2(-1, 320), true)
        imgui.InputTextMultiline("##infocommand", commandslist, imgui.ImVec2(-1, 150), imgui.InputTextFlags.AutoSelectAll + imgui.InputTextFlags.ReadOnly)
        imgui.PushItemWidth(100)
        imgui.Separator()
        imgui.Text(u8'Fearless Helper')
        imgui.Text(u8'Версия скрипта: 0.4')
        imgui.Text(u8'Авторы: Night & Vanya')
        imgui.Separator()
        

        
        imgui.Separator()
        imgui.Text(u8'Лог Обновлений')
        imgui.Separator()
        imgui.Text(u8'0.1')
        imgui.SameLine()
        imgui.TextQuestion(u8'Добавил ФПСАпы, карту закладок В гетто, убрал дождь(тоже фпс бустит), убрал лишние функции, новых 8 стилей интерфейса, быстрый крафт оружия и автопрокачку ломки, автопробив, скип бесполезных диалогов, випчат хелпер, ускорение на шифт для мотоциклов или велосипедов')
        imgui.Text(u8'0.2')
        imgui.SameLine()
        imgui.TextQuestion(u8'Убрал карту закладок, оптимизировал код, добавил FastGun,добавил AutoGasFill')
        imgui.Text(u8'0.3')
        imgui.SameLine()
        imgui.TextQuestion(u8'Добавлен чекер онлайна банд, изменено название хелпера, добавлены новые бинды, оптимизирован код, фикс биндов - теперь при открытом чате не работают, добавлен флудер о наборе')
        imgui.Text(u8'0.4')
        imgui.SameLine()
        imgui.TextQuestion(u8'Поправлено imgui, замена бинда на alt+1[Было: /usemed - Стало: /usedrugs 3 + сбив], добавлены новые бинды, добавлена возможность открывать меню на F3, в Флудер набора добавлена возможность писать в радиостанцию(/ad), добавлен автоматический ввод пароля в банке/банкомате [/pb], добавлена функция включить флудер в фамчат, изменена система флудера в организацию(достаточно теперь один раз написать команду и скрипт запустит флудер) добавлена возможность выбирать самому КД набора/флуда в банду/фамчат')

        imgui.Separator()
        if imgui.Button(u8'click me') then
            os.execute('start https://www.youtube.com/watch?v=dQw4w9WgXcQ&ab_channel=RickAstley')
        end
        

        
        imgui.EndChild()
        if imgui.Button(u8"Сохранить настройки", imgui.ImVec2(350, 45)) then mainIni.mode = 2 end
        imgui.SameLine()
        if imgui.Button(u8'Перезагрузить скрипт',imgui.ImVec2(350,45)) then
            lua_thread.create(function ()
                wait(100)
                sampAddChatMessage(tag..'Скрипт перезагружается..', -1)
                thisScript():reload()
            end)
        end
        imgui.SameLine()
        if imgui.Button(u8'Закрыть',imgui.ImVec2(300,45)) then
            window.v = false
        end
        imgui.End()
        encda()
    end
end

function imgui.TextQuestion(text)
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.NullText(text)
    imgui.TextDisabled('    ')
    end

function switch(key)
    return function(tab)
        local current = tab[key] or tab['default']
        if type(current) == 'function' then current() end
    end
end

w, h = getScreenResolution()
imgui.Process = false

function black_purple()
	imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		style.WindowRounding = 10
		style.ChildWindowRounding = 10
		style.FrameRounding = 6.0

		style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
		style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 17.0
		style.GrabRounding = 16.0

		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
    colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
    colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
    colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
    colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
black_purple()

function nlomka()
    active = not active
sampAddChatMessage(tag.."Прокачка ломки: "..(active and "{32CD32}работает" or "{FF0000}остановлена"), -1)
lua_thread.create(function() 
    while active do 
        wait(0) 
        sampSendChat('/usedrugs 3')
        wait(6 * 1000)
    
    end
end)
end
function sampev.onShowDialog(id, style, title, button1, button2, text)
    if text:find('Стоимость рекламного сообщения:') then
        if not adsend then
			sampSendDialogResponse(id, 0, 0, '')
        	return false
		elseif adsend then
			sampSendDialogResponse(id, 1, 0, '')
        	return false
		end
    end
end


function getguninvent(gunname, ammo)
    if ammo:len() > 0 and tonumber(ammo) > 0 then
      gname, ammoclip, findedgun = gunname, ammo, false
        sampSendChat('/invent')
    else
        sampAddChatMessage(tag..'{7FFFD4}[FastGun] Введите кол-во патрон! ', -1)
    
  end
  
  function sampev.onShowTextDraw(id,data)
  if gname ~= 'nothing' then
    if not findedgun  then
      if data.modelId == tableguns[gname] then
        findedgun = true
        sampSendClickTextdraw(id)
      end
    else
      if id == 2302 then
        sampSendClickTextdraw(id)
      end
    end
  end
  end
  
  function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)
  if findedgun and gname ~= 'nothing' and dialogId == 3011 then
    sampSendDialogResponse(3011,1,0,ammoclip)
    sampSendClickTextdraw(2110)
    sampSendClickTextdraw(2111)
    gname = 'nothing'
    return false
    end
 end
end
function cmd_probiv(id)
    lua_thread.create(function()
    _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    wait(2000)
    sampSendChat("/time")
    wait(500)
    sampSendChat("/id "..id.."")
    wait(600)
    setVirtualKeyDown(VK_TAB, false) -- пїЅпїЅпїЅпїЅ пїЅпїЅпїЅ
    wait(1000)
    setVirtualKeyDown(VK_TAB, false) -- пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ
    wait(500)
    setVirtualKeyDown(116, true) -- F5 пїЅпїЅпїЅпїЅпїЅ
    wait(3100)
    setVirtualKeyDown(116, false) -- F5 пїЅпїЅпїЅпїЅпїЅ
    wait(600)
    sampSendChat("/skill")
    wait(600)
    sampSendChat("/stats")
    wait(600)
    sampSendChat("/donate")
    wait(600)
    setVirtualKeyDown(27, true) -- пїЅпїЅпїЅ
    wait(10)
    setVirtualKeyDown(27, false) -- пїЅпїЅпїЅ
    wait(500)
    sampSendChat("/invent")
    wait(1500)
    sampSendClickTextdraw(2071) -- textdraw пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
    end)
end
function _con()
    local huy = callFunction(0x53C500, 2, 2, true, true)
    local huy1 = callFunction(0x53C810, 1, 1, true)
    local huy2 = callFunction(0x40CF80, 0, 0)
    local huy3 = callFunction(0x4090A0, 0, 0)
    local huy4 = callFunction(0x5A18B0, 0, 0)
    local huy5 = callFunction(0x707770, 0, 0)
    local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
    requestCollision(pX, pY)
    loadScene(pX, pY, pZ)
    sampAddChatMessage(tag.."[Cleaner]  {d5dedd}Очистка буффера произошла успешно!", 0x01A0E9)
end
function isKeyCheckAvailable()
	if not isSampLoaded() then
		return true
	end
	if not isSampfuncsLoaded() then
		return not sampIsChatInputActive() and not sampIsDialogActive()
	end
	return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive()
end
function sampev.onServerMessage(color, text)   
    if active and text:match(tag..'Данный тип топлива не подходит для вашего транспорта.') --[[and color == -1347440641]] then 
        return false
    end
end
function sampev.onShowTextDraw(id, data)
    if active then
        local x, y = math.floor(data.position.x), math.floor(data.position.y)
        for k, v in pairs(tds) do
            if x == v.x and y == v.y then
                tds[k].id = id
            end
        end
        if x == tds['fuel_name'].x and y == tds['fuel_name'].y then
            if data.text == 'DIESEL' then
                sampAddChatMessage(tag..'[AutoGasFill]: {ffffff}начинаю заправку!', 0xFFff004d)
                lua_thread.create(function()
                    wait(150)
                    sampSendClickTextdraw(tds['max'].id)
                    wait(click_delay)
                    for i = 1, 4 do
                        sampSendClickTextdraw(tds['next'].id)
                        wait(click_delay)
                        sampSendClickTextdraw(tds['fill'].id)
                        wait(click_delay)
                    end
                end)
            end
        end

        if tds['fuel_name'].id ~= -1 then
            for k, v in ipairs(ALL_MENU_TDS) do
                if sampTextdrawIsExists(tds['fuel_name'].id) and v.x == x and v.y == y then 
                    data.position.y = 600
                    return {id, data}
                end
            end
        end
    end
end
function getCurrentServer(name)
	if name:find('Advance RolePlay') then return 1
	elseif name:find('Samp%-Rp') then return 2
	elseif name:find('SRP') then return 2
	elseif name:find('Pears Project') then return 3
	elseif name:find('Arizona Role Play') then return 4
	elseif name:find('Diamond Role Play') then return 5
	elseif name:find('Evolve%-Rp') then return 6 end
end

function naborspam()
    active = not active
    sampAddChatMessage(tag.."Флудер набора "..(active and "{32CD32}работает" or "{FF0000}остановлен"), -1)
    lua_thread.create(function() 
        while active do 
            
            sampSendChat('/vr '..u8:decode(nabortext1.v), -1)
            wait(1000)
            sampSendChat('/fam '..u8:decode(nabortext2.v), -1)
            wait(1000)
            sampSendChat('/ad '..u8:decode(nabortext3.v), -1)
            wait(60)
            sampSendDialogResponse(25473, 1, 0, -1)
            wait(60)
            sampSendDialogResponse(15346, 1, 0, -1)
            wait(60)
            sampSendDialogResponse(15347, 1, 0, -1)
            wait(60)
            setVirtualKeyDown(0x1B, true)
            wait(60)
            setVirtualKeyDown(0x1B, false)
            wait(60)
            wait(nabint.v*1000)
            
 
        end
    end)
end
function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end       
function autobankparol()
    active = not active
    sampAddChatMessage(tag.."Автоввод пароля в банке "..(active and "{32CD32}работает" or "{FF0000}остановлен"), -1)
    lua_thread.create(function() 
        while active do 
            wait(100)
            sampSendDialogResponse(991, 1, 0, parolbank.v)
        end
    end)   
end

function famchatflooder()
    active = not active
    sampAddChatMessage(tag.."Флудер семьи " ..(active and "{32CD32}работает" or "{FF0000}остановлен"), -1)
    lua_thread.create(function() 
        while active do 
            wait(100)
            sampSendChat('/fam '..u8:decode(famtext3.v), -1)  
            wait(famint.v*1000)
        end
    end)
end

function prospam()
    active = not active
    sampAddChatMessage(tag.."Флудер организации " ..(active and "{32CD32}работает" or "{FF0000}остановлен"), -1)
    lua_thread.create(function() 
        while active do 
            wait(100)
            sampSendChat('/fb '..u8:decode(prospamtext1.v), -1) 
            wait(orgint.v*1000)
            sampSendChat('/fb '..u8:decode(prospamtext2.v), -1)
            wait(orgint.v*1000)
            sampSendChat('/fb '..u8:decode(prospamtext3.v), -1)
            wait(orgint.v*1000)
            wait(orgint2.v*1000)
        end
    end)
end


function cmd_update(arg)
    sampShowDialog(1000, "Автообновление", "PrescottHelper идет обновление к новой версии", "Закрыть", "", 0)
end