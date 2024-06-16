ESX.RegisterServerCallback('mero_npcmechanic:pay', function(source, cb, option, index, vehicle)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerName = xPlayer.getName() -- Pobieranie imienia i nazwiska postaci
    local steamId = GetPlayerIdentifier(source, 0) -- Pobieranie SteamID (ID w grze)
    local logMessage = ''

    -- Debug prints
    print('Player:', playerName, 'SteamID:', steamId)

    if option == 'repair' then
        if xPlayer.getAccount('money').money >= Config.Repair.Price then
            xPlayer.removeAccountMoney('money', Config.Repair.Price)
            TriggerClientEvent('mero_npcmechanic:startRepair', -1, index, vehicle)
            cb(true)
            logMessage = string.format('[MECHANIC] Gracz %s (%s) zapłacił %s za naprawę pojazdu.', playerName, steamId, Config.Repair.Price)
            Wait(Config.Repair.Duration)
            TriggerClientEvent('mero_npcmechanic:end', -1, index)
        else
            cb(false)
            logMessage = string.format('[MECHANIC] Gracz %s (%s) nie mógł sobie pozwolić na naprawę pojazdu.', playerName, steamId)
        end
    else
        if xPlayer.getAccount('money').money >= Config.Clean.Price then
            xPlayer.removeAccountMoney('money', Config.Clean.Price)
            TriggerClientEvent('mero_npcmechanic:startClean', -1, index, vehicle)
            cb(true)
            logMessage = string.format('[MECHANIC] Gracz %s (%s) zapłacił %s za czyszczenie pojazdu.', playerName, steamId, Config.Clean.Price)
            Wait(Config.Clean.Duration)
            TriggerClientEvent('mero_npcmechanic:end', -1, index)
        else
            cb(false)
            logMessage = string.format('[MECHANIC] Gracz %s (%s) nie mógł sobie pozwolić na czyszczenie pojazdu.', playerName, steamId)
        end
    end

    -- Wysyłanie wiadomości logującej na webhook Discord
    if Config.EnableDiscordLogs then
        local webhookData = {
            content = logMessage,
            username = 'Mechanic Log'
        }
        PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers)
            if err ~= 200 then
                print('Błąd wysyłania logów Discord: ' .. err)
            else
                print('Log Discord wysłany pomyślnie.')
            end
        end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
    end
end)

Config.EnableDiscordLogs = true  -- Włączanie lub wyłączanie logów Discord
Config.DiscordWebhook = 'https://discord.com/api/webhooks/1251157171547144244/_S_KnXc13_CvaOzDRgE2ThSvrn4OwQdAv9aO381I9OHcaLsX5BVZjVrh7XUF6jTDsbnA'
