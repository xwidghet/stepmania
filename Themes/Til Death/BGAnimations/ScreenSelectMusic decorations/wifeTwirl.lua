local profile = PROFILEMAN:GetProfile(PLAYER_1)
local frameX = 10
local frameY = 250+capWideScale(get43size(120),90)
local frameWidth = capWideScale(get43size(455),455)
local scoreType = themeConfig:get_data().global.DefaultScoreType
local score
local song
local steps
local alreadybroadcasted

local update = false
local t = Def.ActorFrame{
    -- i really need to animate some elements separately
	BeginCommand=cmd(queuecommand,"Set";xy,0,-500),
	OffCommand=cmd(bouncy,0.32;xy,-100,0;diffusealpha,0),
	OnCommand=cmd(bouncy,0.32;xy,0,0;diffusealpha,1),
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 0 then
			self:queuecommand("On")
			update = true
		else 
			self:queuecommand("Off")
			update = false
		end
	end,
	TabChangedMessageCommand=cmd(queuecommand,"Set"),
}

-- Music Rate Display
t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,18,SCREEN_BOTTOM-225;visible,true;halign,0;zoom,0.4;maxwidth,capWideScale(get43size(360),360)/capWideScale(get43size(0.45),0.45)),
	BeginCommand=function(self)
		self:settext(getCurRateDisplayString())
	end,
	CodeMessageCommand=function(self,params)
		local rate = getCurRateValue()
		ChangeMusicRate(rate,params)
		self:settext(getCurRateDisplayString())
	end,
}

-- Temporary update control tower; it would be nice if the basic song/step change commands were thorough and explicit and non-redundant
t[#t+1] = Def.Actor{
	SetCommand=function(self)
		if song and not alreadybroadcasted then 		-- if this is true it means we've just exited a pack's songlist into the packlist
			song = GAMESTATE:GetCurrentSong()			-- also apprently true if we're tabbing around within a songlist and then stop...
			MESSAGEMAN:Broadcast("UpdateChart")			-- ms.ok(whee:GetSelectedSection( )) -- use this later to detect pack changes
			MESSAGEMAN:Broadcast("RefreshChartInfo")
		else
			alreadybroadcasted = false
		end
	end,
	CurrentStepsP1ChangedMessageCommand=function(self)	
		song = GAMESTATE:GetCurrentSong()			
		MESSAGEMAN:Broadcast("UpdateChart")
		alreadybroadcasted = true
	end,
	CurrentSongChangedMessageCommand=function(self)
		if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).OneShotMirror then	-- This will disable mirror when switching songs if OneShotMirror is enabled
			local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"
			local playeroptions = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions(modslevel)
			playeroptions:Mirror( false )
		end
		self:queuecommand("Set")
	end,
}

local function GetBestScoreByFilter(perc,CurRate)
	local rtTable = getRateTable(PROFILEMAN:GetProfile(PLAYER_1):GetHighScoresByKey(getCurKey()))
	local rates = tableKeys(rtTable)
	local scores, score
	
	if CurRate then
		local tmp = getCurRateString()
		if tmp == "1x" then tmp = "1.0x" end
		rates = {tmp}
		if not rtTable[rates[1]] then return nil end
	end
	
	table.sort(rates)
	for i=#rates,1,-1 do
		scores = rtTable[rates[i]]
		local bestscore = 0
		local index
		
		for ii=1,#scores do
			score = scores[ii]
			if score:ConvertDpToWife() > bestscore and getClearTypeFromScore(PLAYER_1,score,0) ~= "Invalid" then
				index = ii
				bestscore = score:ConvertDpToWife()
			end
		end
		
		if index and scores[index]:GetWifeScore() == 0 and GetPercentDP(scores[index]) > perc * 100 then
			return scores[index]
		end
		
		if bestscore > perc then
			return scores[index]
		end
	end		
end

local function GetDisplayScore()
	local score
	score = GetBestScoreByFilter(0, true)
	
	if not score then score = GetBestScoreByFilter(0.9, false) end
	if not score then score = GetBestScoreByFilter(0.5, false) end
	if not score then score = GetBestScoreByFilter(0, false) end
	return score
end

t[#t+1] = Def.Actor{
	SetCommand=function(self)		
		if song then 
			steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
			score = GetDisplayScore()
			MESSAGEMAN:Broadcast("RefreshChartInfo")
		end
	end,
	UpdateChartMessageCommand=cmd(queuecommand,"Set"),
	CurrentRateChangedMessageCommand=function()
		score = GetDisplayScore()
	end,
}

t[#t+1] = Def.ActorFrame{
	-- **frames/bars**
	Def.Quad{InitCommand=cmd(xy,frameX,frameY-76;zoomto,110,94;halign,0;valign,0;diffuse,color("#333333CC");diffusealpha,0.66)},			--Upper Bar
	Def.Quad{InitCommand=cmd(xy,frameX,frameY+18;zoomto,frameWidth+4,50;halign,0;valign,0;diffuse,color("#333333CC");diffusealpha,0.66)},	--Lower Bar
	Def.Quad{InitCommand=cmd(xy,frameX,frameY-76;zoomto,8,144;halign,0;valign,0;diffuse,getMainColor('highlight');diffusealpha,0.5)},		--Side Bar (purple streak on the left)
	
	-- **score related stuff** These need to be updated with rate changed commands
	-- Primary percent score
	LoadFont("Common Large")..{
		InitCommand=cmd(xy,frameX+55,frameY+50;zoom,0.6;halign,0.5;maxwidth,125;valign,1),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			if song and score then
				if score:GetWifeScore() == 0 then 
					self:settextf("%05.2f%%", score:GetPercentDP()*100)
					self:diffuse(getGradeColor(score:GetGrade()))
				else
					self:settextf("%05.2f%%", notShit.floor(score:GetWifeScore()*10000)/100)
					self:diffuse(getGradeColor(score:GetWifeGrade()))
				end
			else
				self:settext("")
			end
		end,
		RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
		CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
	},
	
	-- Primary ScoreType
	LoadFont("Common Large")..{
		InitCommand=cmd(xy,frameX+125,frameY+40;zoom,0.3;halign,1;valign,1),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			if song and score then
				if score:GetWifeScore() == 0 then 
					self:settext("DP*")
				else
					self:settext(scoringToText(scoreType))
				end
			else
				self:settext("")
			end
		end,
		CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
		RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
	},
	
	-- Secondary percent score
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+130,frameY+63;zoom,0.6;halign,0.5;maxwidth,125;valign,1),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			if song and score then
				if score:GetWifeScore() == 0 then 
					self:settextf("NA")
					self:diffuse(getGradeColor("Grade_Failed"))
				else
					self:settextf("%05.2f%%", score:GetPercentDP()*100)
					self:diffuse(getGradeColor(score:GetGrade()))
				end
			else
				self:settext("")
			end
		end,
		RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
		CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
	},
	
	-- Secondary ScoreType
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+173,frameY+63;zoom,0.4;halign,1;valign,1),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			if song and score then
				if score:GetWifeScore() == 0 then 
					self:settext("Wife")
				else
					self:settext("DP")
				end
			else
				self:settext("")
			end
		end,
		CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
		RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
	},
	
	-- Rate for the displayed score
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+55,frameY+58;zoom,0.5;halign,0.5),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			if song and score then 
				local rate = getRate(score)
			
				-- need to standardize how this shit is handled (1x vs 1.0x)
				if rate == "1.0x" then
					rate = "1x"
				elseif rate == "2.0x" then
					rate = "2x"
				end
				
				local notCurRate = getCurRateString() ~= rate
				
				-- cause this is getting stupid - mina
				if rate == "1x" then
					rate = "1.0x"
				elseif rate == "2x" then
					rate = "2.0x"
				end
					
				if notCurRate then
					self:settext("("..rate..")")
				else
					self:settext(rate)
				end
			else
				self:settext("")
			end
		end,
		CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
		RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
	},
	
	-- Date score achieved on
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+185,frameY+59;zoom,0.4;halign,0),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			if song and score then
					self:settext(score:GetDate())
				else
					self:settext("")
				end
		end,
		CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
		RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
	},

	-- MaxCombo
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+185,frameY+49;zoom,0.4;halign,0),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			if song and score then
				self:settextf("Max Combo: %d", score:GetMaxCombo())
			else
				self:settext("")
			end
		end,
		CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
		RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
	},
	-- **End score related stuff**
}

-- "Radar values" aka basic chart information
local function radarPairs(i)
	local o = Def.ActorFrame{
		LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameX+13,frameY-52+13*i;zoom,0.5;halign,0;maxwidth,120),
			SetCommand=function(self)
				if song then
					self:settext(ms.RelevantRadarsShort[i])
				else
					self:settext("")
				end
			end,
			RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
		},
		LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameX+105,frameY+-52+13*i;zoom,0.5;halign,1;maxwidth,60),
			SetCommand=function(self)
				if song then		
					self:settext(steps:GetRelevantRadars(PLAYER_1)[i])
				else
					self:settext("")
				end
			end,
			RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
		},
	}
	return o
end

-- Create the radar values
for i=1,5 do
	t[#t+1] = radarPairs(i)
end

-- Difficulty value ("meter"), need to change this later
t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,frameX+58,frameY-62;halign,0.5;zoom,0.6;maxwidth,110/0.6),
	BeginCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		if song then
			local meter = steps:GetMSD(getCurRateValue(), 1)
			self:settextf("%05.2f",meter)
			self:diffuse(ByMSD(meter))
		else
			self:settext("")
		end
	end,
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
	CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
}

-- Song duration
t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,(capWideScale(get43size(384),384))+62,SCREEN_BOTTOM-85;visible,true;halign,1;zoom,capWideScale(get43size(0.6),0.6);maxwidth,capWideScale(get43size(360),360)/capWideScale(get43size(0.45),0.45)),
	BeginCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		if song then
			local playabletime = GetPlayableTime()
			self:settext(SecondsToMMSS(playabletime))
			self:diffuse(ByMusicLength(playabletime))
		else
			self:settext("")
		end
	end,
	CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
}

-- BPM display/label not sure why this was never with the chart info in the first place
t[#t+1] = Def.BPMDisplay {
	File=THEME:GetPathF("BPMDisplay", "bpm"),
	Name="BPMDisplay",
	InitCommand=cmd(xy,capWideScale(get43size(384),384)+62,SCREEN_BOTTOM-100;halign,1;zoom,0.50),
	SetCommand=function(self)
		if song then 
			self:visible(1)
			self:SetFromSong(song)
		else
			self:visible(0)
		end
	end,
	CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
}

t[#t+1] = LoadFont("Common Normal") .. {
	SetCommand = function(self)
		if song then
			self:settext("BPM")
		else
			self:settext("")
		end
	end,
	InitCommand=cmd(xy,capWideScale(get43size(384),384)+41,SCREEN_BOTTOM-100;halign,1;zoom,0.50),
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
}

-- CDtitle, need to figure out a better place for this later. -mina
--Gonna move the cdtitle right next to selected song similar to ultralight. -Misterkister
t[#t+1] = Def.Sprite {
	InitCommand=cmd(xy,capWideScale(get43size(344),364)+50,capWideScale(get43size(345),255);halign,0.5;valign,1),
	SetCommand=function(self)
		self:finishtweening()
		if GAMESTATE:GetCurrentSong() then
			local song = GAMESTATE:GetCurrentSong()	
			if song then
				if song:HasCDTitle() then
					self:visible(true)
					self:Load(song:GetCDTitlePath())
				else
					self:visible(false)
				end
			else
				self:visible(false)
			end
			local height = self:GetHeight()
			local width = self:GetWidth()
			
			if height >= 60 and width >= 75 then
				if height*(75/60) >= width then
				self:zoom(60/height)
				else
				self:zoom(75/width)
				end
			elseif height >= 60 then
				self:zoom(60/height)
			elseif width >= 75 then
				self:zoom(75/width)
			else
				self:zoom(1)
			end
		else
		self:visible(false)
		end
	end,
	BeginCommand=cmd(queuecommand,"Set"),
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
}

t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,frameX,frameY-120;halign,0;zoom,0.4),
	BeginCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		if steps:GetTimingData():HasWarps() then
			self:settext("NegBpms!")
		else
			self:settext("")
		end
	end,
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set"),
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
}

-- t[#t+1] = LoadFont("Common Large") .. {
	-- InitCommand=cmd(xy,(capWideScale(get43size(384),384))+68,SCREEN_BOTTOM-135;halign,1;zoom,0.4,maxwidth,125),
	-- BeginCommand=cmd(queuecommand,"Set"),
	-- SetCommand=function(self)
		-- if song then
			-- self:settext(song:GetOrTryAtLeastToGetSimfileAuthor())
		-- else
			-- self:settext("")
		-- end
	-- end,
	-- CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set"),
	-- RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
-- }

-- active filters display
-- t[#t+1] = Def.Quad{InitCommand=cmd(xy,16,capWideScale(SCREEN_TOP+172,SCREEN_TOP+194);zoomto,SCREEN_WIDTH*1.35*0.4 + 8,24;halign,0;valign,0.5;diffuse,color("#000000");diffusealpha,0),
	-- EndingSearchMessageCommand=function(self)
		-- self:diffusealpha(1)
	-- end
-- }
-- t[#t+1] = LoadFont("Common Large") .. {
	-- InitCommand=cmd(xy,20,capWideScale(SCREEN_TOP+170,SCREEN_TOP+194);halign,0;zoom,0.4;settext,"Active Filters: "..GetPersistentSearch();maxwidth,SCREEN_WIDTH*1.35),
	-- EndingSearchMessageCommand=function(self, msg)
		-- self:settext("Active Filters: "..msg.ActiveFilter)
	-- end
-- }


t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,frameX+120,frameY-60;halign,0;zoom,0.4,maxwidth,125),
	BeginCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		if song then
			self:settext(steps:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 1))
		else
			self:settext("")
		end
	end,
	CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
}

t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,frameX+120,frameY-30;halign,0;zoom,0.4,maxwidth,125),
	BeginCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		if song then
			self:settext(steps:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 2))
		else
			self:settext("")
		end
	end,
	CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
}

t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,frameX+120,frameY;halign,0;zoom,0.4,maxwidth,125),
	BeginCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		if song then
			self:settext(steps:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 3))
		else
			self:settext("")
		end
	end,
	CurrentRateChangedMessageCommand=cmd(queuecommand,"Set"),
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
}


--test actor
t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=cmd(xy,frameX,frameY-120;halign,0;zoom,0.4,maxwidth,125),
	BeginCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		self:settext("")
	end,
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set"),
	RefreshChartInfoMessageCommand=cmd(queuecommand,"Set"),
}


return t
