math.randomseed(os.time())
local function getRandomZeroPos(grid)
	local n=#grid
	local m=#grid[1]
	local zeros={}
	for i=1,n do
		for j=1,m do
			if grid[i][j]==0 then
				table.insert(zeros,{i=i,j=j})
			end
		end
	end
	if #zeros>0 then
		local r=math.random(1,#zeros)
		return zeros[r].i,zeros[r].j;
	end
end
local function randomNum(grid)
	local i,j=getRandomZeroPos(grid)
	if i and j then
		local r=math.random()
		if r<0.9 then
			grid[i][j]=2
		else
			grid[i][j]=4
		end
	end
end
function initGrid(n,m)
	local grid={}
	for i=1,n do
		if not grid[i] then
			grid[i]={}
		end
		for j=1,n do
			grid[i][j]=0;
		end
	end
	randomNum(grid)
	randomNum(grid)
	return grid
end
--[[function copyGrid(grid)
	local tmpGrid={}
	local n=#grid
	local m=#grid[1]
	for i=1,n do
		if not tmpGrid[i] then
			tmpGrid[i]={}
		end
		for j=1,m do
			tmpGrid[i][j]=grid[i][j]
		end
	end
	
end]]--
function moveLeft(grid)
	local score=0
	local ismove=false
	local n=#grid
	local m=#grid[1]
	for i=1,n do
		local k=0
		for j=1,m do
			if grid[i][j]~=0 then
				k=k+1
				if k~=j then ismove=true end
				grid[i][k]=grid[i][j]
			end
		end
		for j=k+1,m do
			grid[i][j]=0
		end
		for j=1,k-1 do
			if grid[i][j]==grid[i][j+1] then
				grid[i][j]=grid[i][j]*2
				grid[i][j+1]=0
				score=score+grid[i][j]
			end
		end
		k=0
		for j=1,m do
			if grid[i][j]~=0 then
				k=k+1
				if k~=j then ismove=true end
				grid[i][k]=grid[i][j]
			end
		end
		for j=k+1,m do
			grid[i][j]=0
		end
	end
	return score,ismove
end
function moveRight(grid)
	local score=0
	local ismove=false
	local n=#grid
	local m=#grid[1]
	for i=1,n do 
		local k=m+1
		for j=m,1,-1 do 
			if grid[i][j]~=0 then
				k=k-1
				if k~=j then ismove=true end
				grid[i][k]=grid[i][j]
			end
		end
		for j=k-1,1,-1 do
			grid[i][j]=0
		end
		for j=m,k+1,-1 do
			if(grid[i][j]==grid[i][j-1]) then
				grid[i][j]=grid[i][j]*2
				grid[i][j-1]=0
				score=score+grid[i][j]
			end
		end
		k=m+1
		for j=m,1,-1 do 
			if grid[i][j]~=0 then
				k=k-1
				if k~=j then ismove=true end
				grid[i][k]=grid[i][j]
			end
		end
		for j=k-1,1,-1 do
			grid[i][j]=0
		end
	end
	return score,ismove
end
function moveDown(grid)
	local score=0
	local ismove=false
	local n=#grid
	local m=#grid[1]
	for j=1,m do
		local k=n+1
		for i=n,1,-1 do
			if grid[i][j]~=0 then
				k=k-1
				if k~=i then ismove=true end
				grid[k][j]=grid[i][j]
			end
		end
		for i=k-1,1,-1 do
			grid[i][j]=0
		end
		for i=n,k+1,-1 do 
			if(grid[i][j]==grid[i-1][j]) then
				grid[i][j]=grid[i][j]*2
				grid[i-1][j]=0
				score=score+grid[i][j]
			end
		end
		k=n+1
		for i=n,1,-1 do
			if grid[i][j]~=0 then
				k=k-1
				if k~=i then ismove=true end
				grid[k][j]=grid[i][j]
			end
		end
		for i=k-1,1,-1 do
			grid[i][j]=0
		end
	
	end
	return score,ismove
end

function moveUp(grid)
	local score=0
	local ismove=false
	local n=#grid
	local m=#grid[1]
	for j=1,m do
		local k=0
		for i=1,n do
			if grid[i][j]~=0 then
				k=k+1
				if k~=i then ismove=true end
				grid[k][j]=grid[i][j]
			end
		end
		for i=k+1,n do
			grid[i][j]=0
		end
		for i=1,k-1 do 
			if(grid[i][j]==grid[i+1][j]) then
				grid[i][j]=grid[i][j]*2
				grid[i+1][j]=0
				score=score+grid[i][j]
			end
		end
		k=0
		for i=1,n do
			if grid[i][j]~=0 then
				k=k+1
				if k~=i then ismove=true end
				grid[k][j]=grid[i][j]
			end
		end
		for i=k+1,n do
			grid[i][j]=0
		end
	end
	return score,ismove
end
function serialize(t)
    local mark={}
    local assign={}
    local function ser_table(tbl,parent)
        mark[tbl]=parent
        local tmp={}
        for k,v in pairs(tbl) do
            local key= type(k)=="number" and "["..k.."]" or k
            if type(v)=="table" then
                local dotkey= parent..(type(k)=="number" and key or "."..key)
                if mark[v] then
                    table.insert(assign,dotkey.."="..mark[v])
                else
                    table.insert(tmp, key.."="..ser_table(v,dotkey))
                end
            else
                table.insert(tmp, key.."="..v)
            end
        end
        return "{"..table.concat(tmp,",").."}"
    end
 
    return ser_table(t,"ret")..table.concat(assign," ")
end
function notMove(grid)
	local n=#grid
	local m=#grid[1]
	for i=1,n do
		for j=1,m do
			if grid[i][j]==0 then 
				return false
			end
			if (j<m and grid[i][j]==grid[i][j+1]) or (i<n and grid[i][j]==grid[i+1][j]) then
				return false
			end			
		end
	end
	return true
end
local ops={
	left=moveLeft,
	right=moveRight,
	up=moveUp,
	down=moveDown
}
function op(grid,way)
	--local beforeGrid=copyGrid(grid)
	local score,ismove=ops[way](grid)
	if  score ~=0 then 	ismove=true end
	if ismove==true then randomNum(grid) end
	return score,ismove
end