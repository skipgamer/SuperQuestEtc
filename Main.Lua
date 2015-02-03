io.stdout:setvbuf("no")
debug = true

screenWidth = 0
screenHeight = 0

PLAY = "play"
BUILD = "build"
programState = PLAY

terrain = {}
hill = {}
hills = {}

deltaT = 0
fps = 0
timer = 0
frames = 0
gameTimer = 0

constMoveSpeed = 100
constSprintMultiplier = 2.3
constSprintEnergyDrain = 25
constAttackCost = 10
constBaseEnergy = 100
constBaseEnergyRegen = 15
constGridWidth = 100

maxEnergy = 100
currentEnergy = 100

moveUp = false
moveDown = false
moveLeft = false
moveRight = false	
isSprinting = false

isAttacking = false
startAttack = false
attackProjectiles = {}
cooldownTimer = 0
cooldownTime = .75

enemies = {}
friendlies = {}

player = {}
player.x = 0
player.y = 0
player.facing = {}
player.facing.x = 0
player.facing.y = 0

xPos = 0
yPos = 0

cameraX = -400
cameraY = -300

mouseX = 0
mouseY = 0
mouseDistance = 0

function love.load() --called when love framework is loaded
	love.graphics.setBackgroundColor(10,10,10)
	xPos = love.graphics.getWidth()/2
	yPos = love.graphics.getHeight()/2
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()

	--"generate" world "features"
	local forestNo = 1
	for i = 1, forestNo do
		local forestWidth = 100
		local forestHeight = 100
		local forestRadius = 100
		local forestPoly = {}
		local pointNo = 10
		--loop method
		for i = 1, pointNo do
			
		end

		-- box method, not happy
		--topright
		table.insert(forestPoly, forestWidth + forestWidth/2 - love.math.random(forestWidth/2))
		table.insert(forestPoly, forestHeight + forestHeight/2 - love.math.random(forestHeight/2))
		--top
		table.insert(forestPoly, love.math.random(forestWidth/2))
		table.insert(forestPoly, forestHeight + forestHeight/2 - love.math.random(forestHeight/2))
		--topleft
		table.insert(forestPoly, -forestWidth + forestWidth/2 - love.math.random(forestWidth/2))
		table.insert(forestPoly, forestHeight + forestHeight/2 - love.math.random(forestHeight/2))
		--left
		table.insert(forestPoly, -forestWidth + forestWidth/2 - love.math.random(forestWidth/2))
		table.insert(forestPoly, love.math.random(forestHeight/2))
		--botleft
		table.insert(forestPoly, -forestWidth + forestWidth/2 - love.math.random(forestWidth/2))
		table.insert(forestPoly, -forestHeight + forestHeight/2 - love.math.random(forestHeight/2))
		--bot
		table.insert(forestPoly, love.math.random(forestHeight/2))
		table.insert(forestPoly, -forestHeight + forestHeight/2 - love.math.random(forestHeight/2))
		--botright
		table.insert(forestPoly, forestWidth + forestWidth/2 - love.math.random(forestWidth/2))
		table.insert(forestPoly, -forestHeight + forestHeight/2 - love.math.random(forestHeight/2))
		--right
		table.insert(forestPoly, forestWidth + forestWidth/2 - love.math.random(forestWidth/2))
		table.insert(forestPoly, love.math.random(forestHeight/2))

		table.insert(terrain, forestPoly)
	end
	--circle method
	--
	for i = 1, 10 do
		hill.x = love.math.random(screenWidth)
		hill.y = love.math.random(screenHeight)
		hill.radius = love.math.random(200) + 50
		hill.segments = love.math.random(9)
		table.insert(hills, hill)
		hills[i] = hill
	end

	testImage = love.graphics.newImage("images/floor.png")
	
end


function love.draw() --called by main loop every frame (used to display graphics, not process game logic)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(testImage, png)
	--love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3, etc)
	--draw world
	love.graphics.setColor(15,40,15,255)
	--terrain poly method, not happy
	for feature = 1, table.maxn(terrain) do
		terrainFeature = terrain[feature]
		terrainOffset = {}
		for j = 1, table.maxn(terrainFeature)/2 do
			terrainOffset[j*2-1] = terrainFeature[j*2-1] - cameraX
			terrainOffset[j*2] = terrainFeature[j*2] - cameraY
		end
		love.graphics.polygon("fill", terrainOffset)
	end

	for i = 1, table.maxn(hills) do
		eachHill = (hills[i])
		love.graphics.setColor(100,100,100,100)
		love.graphics.circle("fill", eachHill.x, eachHill.y, eachHill.radius, eachHill.segments)
	end

	--fps calc
	timer = timer + deltaT
	frames = frames + 1
	if timer >= 1 then
		fps = frames
		frames = 0
		timer = 0
	end

	--grid lines
	love.graphics.setColor(20,75,20, 255)
	for yLines = -100, 100 do
		love.graphics.line(constGridWidth*yLines - cameraX, 0, constGridWidth*yLines - cameraX, screenHeight)
	end
	for xLines = -100, 100 do
		love.graphics.line(0, constGridWidth*xLines - cameraY, screenWidth, constGridWidth*xLines - cameraY)
	end

	--player
	love.graphics.setColor(50, 50, 50, 255)
	love.graphics.circle("fill", xPos, yPos, 10, 20) --background
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.arc( "fill", xPos, yPos, 10, -math.pi/2, cooldownTimer*math.pi*2*1.25-math.pi/2) --cooldown
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.circle("line", xPos, yPos, 10, 20) --outline
	love.graphics.line(xPos, yPos, xPos + player.facing.x * 10, yPos + player.facing.y * 10) --facing direction

	--attacks
	love.graphics.setColor(255, 255, 255, 255)
	for i = 1, table.maxn(attackProjectiles) do
		local attack = attackProjectiles[i]
		love.graphics.circle("fill", attack.x - cameraX, attack.y - cameraY, 3, 8)
	end

	--enemies
	for i = 1, table.maxn(enemies) do
		local enemy = enemies[i]
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.circle("fill", enemy.x -cameraX, enemy.y - cameraY, 10, 20) --background
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.circle("line", enemy.x -cameraX, enemy.y - cameraY, 10, 20) --outline
	end

	--friendlies
	for i = 1, table.maxn(friendlies) do
		local friendly = friendlies[i]
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.circle("fill", friendly.x -cameraX, friendly.y - cameraY, 10, 20) --background
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.circle("line", friendly.x -cameraX, friendly.y - cameraY, 10, 20) --outline
	end

	-------------UI------------------------------------------------------------------

	--energy bar
	love.graphics.setColor(100, 100, 100, 40)
	love.graphics.rectangle("fill", screenWidth/2 - 100, screenHeight - 100, 200, 20)
	love.graphics.setColor(200, 200, 200, 80)
	love.graphics.rectangle("fill", screenWidth/2 - 100, screenHeight - 100, 200 * (currentEnergy/100), 20)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(math.floor(currentEnergy), screenWidth/2 + 105, screenHeight - 97)

	if debug == true then
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.print("fps: "..fps, 0, 0)
		love.graphics.print("screen X, Y: "..math.floor(xPos)..", "..math.floor(yPos), 0, 15)
		love.graphics.print("world X, Y: "..math.floor(player.x)..", "..math.floor(player.y), 0, 30)
		love.graphics.print("camera X, Y: "..math.floor(cameraX)..", "..math.floor(cameraY), 0, 45)
		love.graphics.print("mouse X, Y: "..mouseX..", "..mouseY, 0, 60)
		love.graphics.print("mouse distance: "..math.floor(mouseDistance), 0, 75)
		love.graphics.print("game timer: "..math.floor(gameTimer), 0, 90)
		love.graphics.print("cooldown timer: "..cooldownTimer/cooldownTime, 0, 105)
		love.graphics.print(programState, 0, 120)
	end
end

function love.mousepressed(x, y, button)
	if button == "l" then isAttacking = true end
	if button == "r" then DisplayMenu() end
end

function love.mousereleased(x, y, button)
	if button == "l" then isAttacking = false end
end

function love.keypressed(key)
	--print (key.." pressed")
	if programState == PLAY then --play controls
		if key == "up" or key == "w" then moveUp = true
		elseif key == "down" or key == "s" then moveDown = true
		elseif key == "left" or key == "a" then moveLeft = true
		elseif key == "right" or key == "d" then moveRight = true
		elseif key == "lshift" or key == "rshift" then isSprinting = true
		end
	else --build controls
		if key == "b" then SwitchProgramState()
		elseif debug == true and key == "," then SpawnEnemy()
		elseif debug == true and key == "." then SpawnFriendly()
		else
		end
	end
end

function love.keyreleased(key)
	--print (key.." released")
	if key == "up" or key == "w" then moveUp = false
	elseif key == "down" or key == "s" then moveDown = false
	elseif key == "left" or key == "a" then moveLeft = false
	elseif key == "right" or key == "d" then moveRight = false
	elseif key == "lshift" or key == "rshift" then isSprinting = false
	elseif key == "escape" then love.event.quit()
	else
	end
end

function love.update(dt) --called by main loop every frame

	if programState == PLAY then

		gameTimer = gameTimer + dt
		deltaT = dt

		--attacks
		if isAttacking == true then
			if startAttack == false then
				startAttack = true -- first frame of mouseDown
				--print ("attack start")
				DoAttack()
			end
		else
			if startAttack == true then
				startAttack = false
				--print ("attack end")
			end
		end
		for i = 1, table.maxn(attackProjectiles) do
			local attack = attackProjectiles[i]
			if attack ~= null then
				attack.timeElapsed = attack.timeElapsed + dt
				attack.x = attack.x + attack.directionX * (deltaT * 300)
				attack.y = attack.y + attack.directionY * (deltaT * 300)
				if attack.timeElapsed >= 1 then
					table.remove(attackProjectiles, i)
				end
			end
		end

		--[[move enemies
		for i = 1, table.maxn(enemies) do
			local enemy = enemies[i]
			local playerDistance = math.sqrt((player.x-enemy.x) * (player.x-enemy.x) + (player.y-enemy.y) * (player.y-enemy.y))
			enemy.facingX = (enemy.x - player.x) / playerDistance
			enemy.facingY = (enemy.y - player.y) / playerDistance
			enemy.x = enemy.x - enemy.facingX * deltaT * 100
			enemy.y = enemy.y - enemy.facingY * deltaT * 100
		end--]]

		--cooldown
		if startAttack == true or cooldownTimer > 0 then
			cooldownTimer = cooldownTimer + dt
		end
		if cooldownTimer >= cooldownTime then
			cooldownTimer = 0
			if isAttacking == true then attack = DoAttack() end
		end

		PlayerMovement()
	else
	    --do
	end
end

function SwitchProgramState()
	if programState == PLAY then programState = BUILD
	else programState = PLAY
	end
end

function DoAttack()
	if currentEnergy >= constAttackCost then --do attack
		if cooldownTimer == 0 then
			local attack = {}
			attack.x = player.x
			attack.y = player.y
			attack.directionX = player.facing.x
			attack.directionY = player.facing.y
			attack.timeElapsed = 0
			table.insert (attackProjectiles, attack)
			print(table.maxn(attackProjectiles))
			currentEnergy = currentEnergy - constAttackCost
			cooldownTimer = 0
		end
	end
end

function SpawnEnemy()
	local enemy = {}
	enemy.x = mouseX + cameraX
	enemy.y = mouseY + cameraY
	table.insert (enemies, enemy)
end

function SpawnFriendly()
	local friendly = {}
	friendly.x = mouseX + cameraX
	friendly.y = mouseY + cameraY
	table.insert (friendlies, friendly)
end

function PlayerMovement()

	--facing direction
	mouseX, mouseY = love.mouse.getPosition()
	mouseDistance = math.sqrt((xPos-mouseX) * (xPos-mouseX) + (yPos-mouseY) * (yPos-mouseY))
	player.facing.x = (mouseX - xPos) / mouseDistance
	player.facing.y = (mouseY - yPos) / mouseDistance

	--sprinting
	moveSpeed = constMoveSpeed
	if currentEnergy < 1 then isSprinting = false end
	if isSprinting == true then
		if currentEnergy > 0 then
			currentEnergy = currentEnergy - deltaT * constSprintEnergyDrain
			moveSpeed = moveSpeed * constSprintMultiplier
		end
	else
		if currentEnergy < 100 then
			currentEnergy = currentEnergy + deltaT * constBaseEnergyRegen
		else
		    currentEnergy = 100
		end
	end

	--standard movement
	diagonalMovement = moveSpeed * .7 * deltaT
	standardMovement = moveSpeed * deltaT
	if moveUp == true then
		if moveLeft == true or moveRight == true then
			if yPos > 200 then yPos = yPos - diagonalMovement
			else
				cameraY = cameraY - diagonalMovement
			end
			player.y = player.y - diagonalMovement
		else
			if yPos > 200 then yPos = yPos - standardMovement 
			else
				cameraY = cameraY - standardMovement
			end
			player.y = player.y - standardMovement
		end
	end
	if moveDown == true then 
		if moveLeft == true or moveRight == true then
			if yPos < 400 then yPos = yPos + diagonalMovement 
			else
				cameraY = cameraY + diagonalMovement
			end
			player.y = player.y + diagonalMovement
		else
			if yPos < 400 then yPos = yPos + standardMovement 
			else
				cameraY = cameraY + standardMovement
			end
			player.y = player.y + standardMovement
		end
	end
	if moveLeft == true then 
		if moveUp == true or moveDown == true then
			if xPos > 200 then xPos = xPos - diagonalMovement 
			else
				cameraX = cameraX - diagonalMovement
			end
			player.x = player.x - diagonalMovement
		else
		    if xPos > 200 then xPos = xPos - standardMovement 
			else
				cameraX = cameraX - standardMovement
			end
			player.x = player.x - standardMovement
		end
	end
	if moveRight == true then 
		if moveUp == true or moveDown == true then
			if xPos < 600 then xPos = xPos + diagonalMovement 
			else
				cameraX = cameraX + diagonalMovement
			end
			player.x = player.x + diagonalMovement
		else
		    if xPos < 600 then xPos = xPos + standardMovement 
			else
				cameraX = cameraX + standardMovement
			end
			player.x = player.x + standardMovement
		end
	end

	--UI--

	function DisplayMenu()

	end
end

