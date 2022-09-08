import "CoreLibs/timer"
import "CoreLibs/qrcode"
import "CoreLibs/graphics"

local TEXT_WIDTH = 288
local TEXT_HEIGHT = 16
local x = (400 - TEXT_WIDTH) / 2
local y = (240 - TEXT_HEIGHT) / 2
customFont = playdate.graphics.font.new("Fonts/ibm-vga-normal-9x16.pft")
playdate.graphics.setFont(customFont)
playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

local unlockKey = "This only works on real devices."
local instructionText = "Crank to reveal the unlock code!"
local labelText = "Crank to reveal the unlock code!"
local QRSprite = playdate.graphics.sprite.new()

local QRCallback = function (image, errorMessage)
	QRSprite:setImage(image)
	QRSprite:update()
	print("QR code ready")
end

local iterateChar = function (charToIterate, operation)
	local newChar = string.char(charToIterate:byte() + operation)
	if (operation < 0) then
		if (newChar == "*") then
			newChar = ")"
		elseif (newChar == "_") then
			newChar = "^"
		end
	elseif (operation > 0) then
		if (newChar == "*") then
			newChar = "+"
		elseif (newChar == "_") then
			newChar = "`"
		end
	end
	return newChar
end

unlockFile = playdate.file.open("unlockkey.txt")
unlockKey = unlockFile:readline()
print("Succesfully read an unlock code: " .. unlockKey)

playdate.graphics.generateQRCode(unlockKey, 200, QRCallback)

placeholderQR = playdate.graphics.image.new("QR_placeholder.png")
QRSprite:setImage(placeholderQR)
QRSprite:moveTo(100, 120)
QRSprite:setVisible(false)
QRSprite:add()


function playdate.gameWillPause()
	QRSprite:setVisible(true)
	QRSprite:update()
	playdate.display.flush()
	local img = playdate.graphics.getDisplayImage()
	playdate.setMenuImage(img)
end

function playdate.gameWillResume()
	QRSprite:setVisible(false)
	QRSprite:update()
	playdate.display.flush()
	playdate.graphics.clear()
end

function playdate.update()
	playdate.timer.updateTimers()
	playdate.graphics.sprite.update()
	
	local chng, accel = playdate.getCrankChange()
	if (chng > 0.0) then
		if (labelText ~= unlockKey) then
			for i = 1, #labelText do
				local charLabel = labelText:sub(i,i)
				local charOther = unlockKey:sub(i,i)
				local len = charLabel:byte() - charOther:byte()
				if (math.random(1, 3) == 1) then
					if (len > 0) then
						local newChar = iterateChar(charLabel, -1)
						labelText = labelText:sub(1, i - 1) .. newChar .. labelText:sub(i + 1)
					elseif (len < 0) then
						local newChar = iterateChar(charLabel, 1)
						labelText = labelText:sub(1, i - 1) .. newChar .. labelText:sub(i + 1)
					end
				end
			end
		end
	elseif (chng < 0.0) then
		if (labelText ~= instructionText) then
			for i = 1, #labelText do
				local charLabel = labelText:sub(i,i)
				local charOther = instructionText:sub(i,i)
				local len = charLabel:byte() - charOther:byte()
				if (math.random(1, 3) == 1) then
					if (len > 0) then
						local newChar = iterateChar(charLabel, -1)
						labelText = labelText:sub(1, i - 1) .. newChar .. labelText:sub(i + 1)
					elseif (len < 0) then
						local newChar = iterateChar(charLabel, 1)
						labelText = labelText:sub(1, i - 1) .. newChar .. labelText:sub(i + 1)
					end
				end
			end
		end
	end

	playdate.graphics.clear()
	playdate.graphics.drawText(labelText, x, y)
	
end