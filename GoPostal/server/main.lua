ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 									LIVRAISONS	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
RegisterServerEvent('gopostal_job:pay') -- Pay player at the end of delivery
AddEventHandler('gopostal_job:pay', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.addMoney(tonumber(amount))
end)

RegisterServerEvent('gopostal_job:end') -- Pay player at the end of delivery
AddEventHandler('gopostal_job:end', function(letter, package)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	local gainL = Config.PricePerLetter * letter 
	local gainC = Config.PricePerPackage * package 
	local gainT = gainL + gainC

	if letter > 0 then
		xPlayer.removeInventoryItem('letter', letter)
	end
	if package > 0 then
		xPlayer.removeInventoryItem('package', package)
	end

	xPlayer.addMoney(tonumber(gainT))

	TriggerClientEvent('esx:showAdvancedNotification', _source, 'GoPostal', '', _U('gain', tonumber(gainT)), 'CHAR_BRYONY', 1)

end)

ESX.RegisterServerCallback('gopostal_job:haveItem', function(source, cb, letter, package) -- Check if player have item
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local ccount = xPlayer.getInventoryItem('package').count
	local lcount = xPlayer.getInventoryItem('letter').count

	if lcount >= letter and ccount >= package then
		cb(true)
	else
		cb(false)
		if lcount < letter then
			TriggerClientEvent('esx:showNotification', _source, _U('not_enought_letter', letter - lcount))
		end
		if ccount < package then
			TriggerClientEvent('esx:showNotification', _source, _U('not_enought_package', package - ccount))
		end
	end
end) 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 									Distribution	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
RegisterServerEvent('gopostal_job:Item')
AddEventHandler('gopostal_job:Item', function(itemName, amount, label, type)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	if amount < 0 then
		print('gopostal_job: ' .. xPlayer.identifier .. ' attempted to exploit the distribution!')
		return
	end
	if type == 'pick' then
		if sourceItem.weight ~= -1 and (sourceItem.count + amount) > sourceItem.weight then
			TriggerClientEvent('esx:showNotification', _source, _U('player_cannot_hold'))
		else
			xPlayer.addInventoryItem(itemName, amount)
			TriggerClientEvent('esx:showNotification', _source, _U('take', amount, label))
		end
	elseif type == 'deposit' then

		if sourceItem.count >= amount then
			xPlayer.removeInventoryItem(itemName, amount)
			TriggerClientEvent('esx:showNotification', _source, _U('remove', amount, label))
		else
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough'))
		end
	end
end)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 									Caution	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

RegisterServerEvent('gopostal_job:caution')
AddEventHandler('gopostal_job:caution', function(cautionType, cautionAmount)
	local xPlayer = ESX.GetPlayerFromId(source)

	if cautionType == "take" then
		
		xPlayer.removeAccountMoney('bank', cautionAmount)
		TriggerClientEvent('esx:showNotification', source, _U('bank_deposit_taken', ESX.Math.GroupDigits(cautionAmount)))
		
	elseif cautionType == "give_back" then

		if cautionAmount > 1 then
			print(('gopostal_job: %s is using cheat engine!'):format(xPlayer.identifier))
			return
		end

		local caution = Config.Caution
		local toGive = ESX.Math.Round(caution * cautionAmount)

		xPlayer.addAccountMoney('bank', toGive)
		TriggerClientEvent('esx:showNotification', source, _U('bank_deposit_returned', ESX.Math.GroupDigits(toGive)))
	end
end)

