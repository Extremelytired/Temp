print("<<KAKONTROL>>")
print("BREEDER EDITION")
print("--------------------------------")
print("INITIALIZING COMPONENTS")
component = require("component")
os.sleep(0.07)

print("INITIALIZING TERM")
term = require("term")
os.sleep(0.07)

print("INITIALIZING EVENT")
event = require("event")
os.sleep(0.07)

print("INITIALIZING GRAPHICS")
gpu = component.gpu
width, height = gpu.getResolution()
os.sleep(0.07)

print("INITIALIZING REACTOR")
for address, name in component.list() do
  if name == "research_reactor" then
    reactor = component.proxy(address)
  end
end
os.sleep(0.07)

print("INITIALIZING FUNCTIONS")
function setDefault() 
  fluxThresholdLow = 150
  tempThresholdCrit = 650
  tempThresholdHigh = 500
  tempThresholdScram = 800
  rodThresholdScram = 999
  increment = 5
  refreshRate = 1
  rodLevel = 0
  autoScramEnabled = false
end
function alert(level, message)
  alertType = {"ⓘ", "⚠", "💀"}
  alertOutput = alertType[level] .. " | " .. message
  return alertOutput
end
function updateInfo()
  gpu.set(2, 3, "REACTOR INFO")
  gpu.set(3, 4, "TEMPERATURE: " .. math.floor(temperature))
  gpu.set(3, 5, "CURRENT LEVEL: " .. reactor.getLevel())
  gpu.set(3, 6, "TARGET LEVEL: " .. rodLevel)
  gpu.set(3, 7, "FLUX: " .. reactor.getFlux())
  gpu.set(3, 8, "ROD INCREMENT: " .. increment)
end
function updateAlert()
  gpu.set(29, 3, "REACTOR ALERTS")
  if reactor.getFlux() <= fluxThresholdLow then
    alertOutput = alert(1, "LOW REACTOR FLUX")
    gpu.set(30, 4, alertOutput)
    if reactor.getFlux() == 0 then
      alertOutput = alert(2, "FUEL DEPLETED")
      gpu.set(30, 5, alertOutput)
    end
  end
  if temperature >= tempThresholdHigh then
    alertOutput = alert(2, "HIGH REACTOR TEMPERATURE")
    gpu.set(30, 6, alertOutput)
    if temperature >= tempThresholdCrit then
      alertOutput = alert(3, "CRITICAL REACTOR TEMPERATURE")
      gpu.set(30, 7, alertOutput)
    end
  end
  if reactor.getLevel() == 0 then
    alertOutput = alert(1, "REACTOR OFFLINE")
    gpu.set(30, 8, alertOutput)
  end
  if autoScramEnabled == false then
    alertOutput = alert(2, "AUTO SCRAM DISABLED")
    gpu.set(30, 9, alertOutput)
  end
end
function updateButtons()
  for _, b in pairs(buttonsList) do
    drawButton(b, b.colorUp)
  end
    gpu.set(3, 17, "ROD UP")
  gpu.set(3, 21, "ROD DOWN")
  gpu.set(15, 17, "INCREMENT")
  gpu.setForeground(0xFF0000)
  gpu.set(27, 17, "SCRAM")
  gpu.setForeground(0xFFFFFF)
  gpu.set(43, 17, "AUTO-SCRAM")
end
function updateAuto()
  if autoScramEnabled == true then
    if temperature >= tempThresholdScram or rodLevel >= rodThresholdScram then
    scram()
    end
  end
end
function update()
  term.clear()
  gpu.set(1, 1, "KAKONTROL | BREEDER EDITION")
  temperature = reactor.getTemp() * 0.0196 + 20
  reactor.setLevel(rodLevel)
  updateAlert()
  updateInfo()
  updateButtons()
  updateAuto()
end
os.sleep(0.07)


print("INITIALIZING BUTTONS") -- ty nootles so much for BUUTTTTOOOOOOOONS
function newButton(x, y, width, height, colorUp, colorDown, func)
  local button = {xpos = x, ypos = y, width = width, height = height, colorUp = colorUp, colorDown = colorDown, func = func}
  return button
end
function drawButton(button, color)
  gpu.setBackground(color)
  gpu.fill(button.xpos, button.ypos, button.width, button.height, " ")
  gpu.setBackground(0x000000)
end
function buttonPress(_, _, x, y, _, _)
  for _, b in pairs(buttonsList) do
    if (x >= b.xpos and x < b.xpos + b.width and y >= b.ypos and y < b.ypos + b.height) then
      drawButton(b, b.colorDown)
      pressedButton = b
      pressedButton.func()
      return
    end
  end
end
function buttonRelease(_, _, x, y, _, _)
  if pressedButton and (x >= pressedButton.xpos and x < pressedButton.xpos + pressedButton.width and y >= pressedButton.ypos and y < pressedButton.ypos + pressedButton.height) then
    drawButton(pressedButton, pressedButton.colorUp)
    pressedButton.func()
    pressedButton = nil
  end
end
function rodUp()
  rodLevel = rodLevel + increment
end
function rodDown()
  rodLevel = rodLevel - increment
end
function changeIncrement()
  if increment == 1 then
    increment = 5
  elseif increment == 5 then
    increment = 10
  elseif increment == 10 then
    increment = 1
  end
end
function scram()
  reactor.setLevel(0)
  rodLevel = 0
end
function autoScramToggle()
  if autoScramEnabled == false then
    autoScramEnabled = true
  else
    autoScramEnabled = false
  end
end
buttonsList = {
  newButton(3, 18, 10, 3, 0xFFFFFF, 0xCCCCCC, rodUp),
  newButton(3, 22, 10, 3, 0xFFFFFF, 0xCCCCCC, rodDown),
  newButton(15, 18, 10, 7, 0xFFFFFF, 0xCCCCCC, changeIncrement),
  newButton(27, 18, 14, 7, 0xFF0000, 0xCC0000, scram),
  newButton(43, 18, 10, 7, 0xFFFFFF, 0xCCCCCC, autoScramToggle),
}
os.sleep(0.07)

event.listen("touch", buttonPress)
event.listen("touch_up", buttonRelease)

print("LOADING COMPLETE")
print("--------------------------------")
os.sleep(0.07)

print("BOOTING")
setDefault() -- quick fix, def wont cause problems later
os.sleep(0.2)
while true do
  update()
  os.sleep(refreshRate)
end