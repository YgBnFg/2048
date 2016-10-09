local touchStart={0,0}
local totalScore=0
local bestScore=0
local isOver=false
local savePath=device.writablePath.."savefile.save"
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local colors = {
    [-1]   = cc.c4b(0xee, 0xe4, 0xda, 100),
    [0]    = cc.c3b(0xee, 0xe4, 0xda),
    [2]    = cc.c3b(0xee, 0xe4, 0xda),
    [4]    = cc.c3b(0xed, 0xe0, 0xc8),
    [8]    = cc.c3b(0xf2, 0xb1, 0x79),
    [16]   = cc.c3b(0xf5, 0x95, 0x63),
    [32]   = cc.c3b(0xf6, 0x7c, 0x5f),
    [64]   = cc.c3b(0xf6, 0x5e, 0x3b),
    [128]  = cc.c3b(0xed, 0xcf, 0x72),
    [256]  = cc.c3b(0xed, 0xcc, 0x61),
    [512]  = cc.c3b(0xed, 0xc8, 0x50),
    [1024] = cc.c3b(0xed, 0xc5, 0x3f),
    [2048] = cc.c3b(0xed, 0xc2, 0x2e),
    [4096] = cc.c3b(0x3c, 0x3a, 0x32),
}
local numcolors =cc.c3b(0x77,0x6e,0x65)
function MainScene:saveStatus()
	local gridstr=serialize(grid)
	local s=string.format("local bestScore,totalScore,grid=\
		%d,%d,%s \n return bestScore,totalScore,grid",bestScore,totalScore,gridstr)
	io.writefile(savePath,s)
end
function MainScene:loadStatus()
	if io.exists(savePath) then
		local s=io.readfile(savePath)
		if s then
			local f=loadstring(s)
			local _bestScore,_totalScore,_grid=f()
			if _bestScore and _totalScore and _grid then
				bestScore,totalScore,grid=_bestScore,_totalScore,_grid
				self.scoreLabel:setString(string.format("best:%d\nscore:%d\n",bestScore,totalScore))
			end
		end
	end
end

function MainScene:createLabel( title ) 
	cc.ui.UILabel.new({text=title,size=20,color=display.COLOR_BLACK})
		:align(display.CENTER,display.cx-15,display.top-20)
		:addTo(self)
	self.scoreLabel=cc.ui.UILabel.new({
		text="score:0",
		size=30,
		color=display.COLOR_BLUE,
	})
	self.scoreLabel:align(display.CENTER,display.cx,display.top-100):addTo(self)
end
function MainScene:createButton() 
	local images={
		normal="s.png",
		pressed="press.png",
		disabled="s.png",
	}
	cc.ui.UIPushButton.new(images,{scale9=true})
		:setButtonSize(200,50)
		:setButtonLabel("normal",cc.ui.UILabel.new({
			UILabelType=2;
			text="New Game",
			size=32
		}))
		:onButtonClicked(function(event)
			self:restartGame()
		end)
		:align(display.CENTER_TOP,display.left+display.width/2,display.top-170)
		:addTo(self)
end
function getPosFormIdx(mx,my)
    local cellsize=150
    local cdis = 2*cellsize-cellsize/2
    local origin = {x=display.cx-cdis,y=display.cy+cdis}
    local x = (my-1)*cellsize+origin.x
    local y = -(mx-1)*cellsize+origin.y-100
    return x,y
end

function MainScene:show(cell,mx,my)
    local x,y = getPosFormIdx(mx,my)
    local bsz = cell.backgroundsize/2
    cell.background:setPosition(cc.p(x-bsz,y-bsz))
    self:addChild(cell.background)
    cell.num:align(display.CENTER,x,y):addTo(self)
end
function MainScene:creatGridShow() 
	gridShow={}
	for tmp=0,15 do
		local i,j=math.floor(tmp/4)+1,math.floor(tmp%4)+1
		local num=grid[i][j]
		local s=tostring(num)
		if s=='0' then
			s=''
		end
		if not gridShow[i] then
			gridShow[i]={}
		end
		local cell ={
			backgroundsize=140,
			background=cc.LayerColor:create(colors[-1],140,140),
			num=cc.ui.UILabel.new({
				text=s,
				size=40,
				color=numcolors,
			}),
		}
		if s==''then
			cell.background:setOpacity(100)
		else 
			cell.background:setOpacity(255)
		end
		cell.background:setColor(colors[num])
		cell.num:setColor(numcolors)
		gridShow[i][j]=cell
		self:show(gridShow[i][j],i,j)
	end
end
function setNum(self,num,i,j)
	local s=tostring(num)
	if s=='0'then
		s=''
		self.background:setOpacity(100)
	else 
		self.background:setOpacity(255)
	end
	local c=colors[num]
	if not c then
		c=colors[4096]
	end
	self.num:setString(s)
	self.background:setColor(c)
	self.num:setColor(numcolors)
end
function MainScene:reLoadGame()
	local n=#grid
	local m=#grid[1]
	for i=1,n do
		for j=1,m do
			setNum(gridShow[i][j],grid[i][j],i,j)
		end
	end
	if totalScore>bestScore then 
		bestScore=totalScore
	end
	self.scoreLabel:setString(string.format("best:%d\nscore:%d\n",bestScore,totalScore))	
	isOver=notMove(grid)
	self:saveStatus()
end 
function MainScene:restartGame()
	grid=initGrid(4,4)
	totalScore=0
	isOver=false
	self:reLoadGame()
	WINSTR=""
	
end
function MainScene:onTouch(event)
	local name=event.name 
	local x=event.x
	local y=event.y
	local score=0
	local isMove=false;
	if name=='began' then
		touchStart={x,y}
	elseif name=='ended' then
		local tx,ty=x-touchStart[1],y-touchStart[2]
		if tx*tx+ty*ty<10 then 
			return true 
		end
		local k=ty/tx
		if k>1 or k<-1 then
			if ty>0 then
				score,isMove=op(grid,"up")
			else
				score,isMove=op(grid,"down")
			end
		else 
			if tx>0 then
				score,isMove=op(grid,"right")
			else 
				score,isMove=op(grid,"left")
			end
		end
		totalScore=totalScore+score
		--if isMove then
			self:reLoadGame()
			if isOver==true then
				device.showAlert("Confirm Exit", "菜鸡?", {"YES"}, function (event) 
				if event.buttonIndex == 1 then 
					self:restartGame()   
				end
			end)
			end
		--end
	end
	return true
end
function MainScene:ctor()
  display.newColorLayer(cc.c4b(0xfa,0xf8,0xef, 255)):addTo(self)
    self:createLabel("2048")
	grid = initGrid(4,4)
	self:loadStatus()
	self:creatGridShow()
	self:createButton()
	
end

function MainScene:onEnter()
	local layer=display.newNode()
	layer:setContentSize(display.width,display.height)
	layer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
		return self:onTouch(event)
	end)
	layer:addNodeEventListener(cc.KEYPAD_EVENT, function (check) 
		print("pushhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
		if check.key=="back" then
			device.showAlert("Confirm Exit","是否退出？",{"YES","NO"},function(event)
				if event.buttonIndex==1 then 
					--cc.Driector:getInstence():endToLua()
					os.exit()
				end
			end)
		end
	end)
	layer:setKeypadEnabled(true)
	layer:setTouchEnabled(true)
	layer:setTouchSwallowEnabled(false)
	self:addChild(layer)
end

function MainScene:onExit()
end
 
return MainScene
