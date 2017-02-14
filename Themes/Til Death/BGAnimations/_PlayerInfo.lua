-- Old avatar actor frame.. renamed since much more will be placed here (hopefully?)
local t = Def.ActorFrame{
	Name="PlayerAvatar"
}

local profile
local profileName = "No Profile"
local playCount = 0
local playTime = 0
local noteCount = 0
local numfaves = 0
local skillsets = {
	Overall = 0,
	Speed 	= 0,
	Stam  	= 0,
	Jack  	= 0,
}
local AvatarX = 0
local AvatarY = SCREEN_HEIGHT-50
local profileXP = 0 --Used for exp/level and such.
--Tier System. -Misterkister
local tier_one = 0
local tier_two = 7
local tier_three = 13
local tier_four = 17
local tier_five = 21
local tier_six = 25
local tier_seven = 29
local tier_eight = 35
local tier_nine = 40

t[#t+1] = Def.Actor{
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self)
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			profile = GetPlayerOrMachineProfile(PLAYER_1)
			if profile ~= nil then
				if profile == PROFILEMAN:GetMachineProfile() then
					profileName = "Player 1"
				else
					profileName = profile:GetDisplayName()
				end
				playCount = profile:GetTotalNumSongsPlayed()
				playTime = profile:GetTotalSessionSeconds()
				noteCount = profile:GetTotalTapsAndHolds()
				--Since I'm awful at making level algorithms, I'm just going to use this algorithm straight coming from Prim's levels.lua.
				--Unfortunately, it's not a true exp formula, so rip. -Misterkister
				profileXP = math.floor(profile:GetTotalDancePoints()/10 + profile:GetTotalNumSongsPlayed()*50)
				
				-- oook i need to handle this differently
				skillsets.Overall = profile:GetPlayerRating()
				skillsets.Speed = profile:GetPlayerSkillsetRating(2)
				skillsets.Stam = profile:GetPlayerSkillsetRating(3)
				skillsets.Jack = profile:GetPlayerSkillsetRating(4)
			else 
				profileName = "No Profile"
				playCount = 0
				playTime = 0
				noteCount = 0
				profileXP = 0
			end; 
		else
			profileName = "No Profile"
			playCount = 0
			playTime = 0
			noteCount = 0
			profileXP = 0
		end;
	end;
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
	PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set");
}

local judgeX = SCREEN_CENTER_X
local judgeY = AvatarY+30

if IsNetSMOnline() == true then

judgeX = SCREEN_CENTER_X-125
judgeY = AvatarY+40

end

t[#t+1] = Def.ActorFrame{
	Name="Avatar"..PLAYER_1,
	BeginCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		if profile == nil then
			self:visible(false)
		else
			self:visible(true)
		end
	end,
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
	PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),

	Def.Sprite {
		Name="Image",
		InitCommand=cmd(visible,true;halign,0;valign,0;xy,AvatarX,AvatarY),
		BeginCommand=cmd(queuecommand,"ModifyAvatar"),
		PlayerJoinedMessageCommand=cmd(queuecommand,"ModifyAvatar"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"ModifyAvatar"),
		ModifyAvatarCommand=function(self)
			self:finishtweening()
			self:Load(THEME:GetPathG("","../"..getAvatarPath(PLAYER_1)))
			self:zoomto(50,50)
		end,
	},
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarX+53,AvatarY+20;halign,0;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			self:settext(playCount.." Plays")
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
	},
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarX+53,AvatarY+30;halign,0;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			self:settext(noteCount.." Arrows Smashed")
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
	},
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarX+53,AvatarY+40;halign,0;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			local time = SecondsToHHMMSS(playTime)
			self:settextf(time.." PlayTime")
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
	},
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,judgeX,judgeY;halign,0.5;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			self:settext("Judge: "..GetTimingDifficulty())
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
	},
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,SCREEN_WIDTH-5,AvatarY+10;halign,1;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			self:settext(GAMESTATE:GetEtternaVersion())
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
	},
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,SCREEN_WIDTH-5,AvatarY+20;halign,1;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			self:settextf("Songs Loaded: %i", SONGMAN:GetNumSongs())
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
	},
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,SCREEN_WIDTH-5,AvatarY+30;halign,1;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
			self:settextf("Songs Favorited: %i",  profile:GetNumFaves())
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
		FavoritesUpdatedMessageCommand=cmd(queuecommand,"Set"),
	},
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,SCREEN_CENTER_X,AvatarY+25;halign,0.5;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
		--Setting a level up. Level cap at 40. -Misterkister
		if profileXP == 0 and IsNetSMOnline() == true then
			self:settext("Overall Level: 1".."\nEXP Earned: "..profileXP.."/"..(2^1))
		elseif profileXP > 0 and profileXP < 2^1 and IsNetSMOnline() == true then
			self:settext("Overall Level: 1".."\nEXP Earned: "..profileXP.."/"..(2^1) )
		elseif profileXP == 2^1 and IsNetSMOnline() == true then
			self:settext("Overall Level: 2".."\nEXP Earned: "..profileXP.."/"..(2^2))
		elseif profileXP > 2^1 and profileXP < 2^2 and IsNetSMOnline() == true then
			self:settext("Overall Level: 2".."\nEXP Earned: "..profileXP.."/"..(2^2))
		elseif profileXP == 2^2 and IsNetSMOnline() == true then
			self:settext("Overall Level: 3".."\nEXP Earned: "..profileXP.."/"..(2^3))
		elseif profileXP > 2^2 and profileXP < 2^3 and IsNetSMOnline() == true then
			self:settext("Overall Level: 3".."\nEXP Earned: "..profileXP.."/"..(2^3))
		elseif profileXP == 2^3 and IsNetSMOnline() == true then
			self:settext("Overall Level: 4".."\nEXP Earned: "..profileXP.."/"..(2^4))
		elseif profileXP > 2^3 and profileXP < 2^4 and IsNetSMOnline() == true then
			self:settext("Overall Level: 4".."\nEXP Earned: "..profileXP.."/"..(2^4))
		elseif profileXP == 2^4 and IsNetSMOnline() == true then
			self:settext("Overall Level: 5".."\nEXP Earned: "..profileXP.."/"..(2^5))
		elseif profileXP > 2^4 and profileXP < 2^5 and IsNetSMOnline() == true then
			self:settext("Overall Level: 5".."\nEXP Earned: "..profileXP.."/"..(2^5))
		elseif profileXP == 2^5 and IsNetSMOnline() == true then
			self:settext("Overall Level: 6".."\nEXP Earned: "..profileXP.."/"..(2^6))
		elseif profileXP > 2^5 and profileXP < 2^6 and IsNetSMOnline() == true then
			self:settext("Overall Level: 6".."\nEXP Earned: "..profileXP.."/"..(2^6))
		elseif profileXP == 2^6 and IsNetSMOnline() == true then
			self:settext("Overall Level: 7".."\nEXP Earned: "..profileXP.."/"..(2^7))
		elseif profileXP > 2^6 and profileXP < 2^7 and IsNetSMOnline() == true then
			self:settext("Overall Level: 7".."\nEXP Earned: "..profileXP.."/"..(2^7))
		elseif profileXP == 2^7 and IsNetSMOnline() == true then
			self:settext("Overall Level: 8".."\nEXP Earned: "..profileXP.."/"..(2^8))
		elseif profileXP > 2^7 and profileXP < 2^8 and IsNetSMOnline() == true then
			self:settext("Overall Level: 8".."\nEXP Earned: "..profileXP.."/"..(2^8))
		elseif profileXP == 2^8 and IsNetSMOnline() == true then
			self:settext("Overall Level: 9".."\nEXP Earned: "..profileXP.."/"..(2^9))
		elseif profileXP > 2^8 and profileXP < 2^9 and IsNetSMOnline() == true then
			self:settext("Overall Level: 9".."\nEXP Earned: "..profileXP.."/"..(2^9))
		elseif profileXP == 2^9 and IsNetSMOnline() == true then
			self:settext("Overall Level: 10".."\nEXP Earned: "..profileXP.."/"..(2^10))
		elseif profileXP > 2^9 and profileXP < 2^10 and IsNetSMOnline() == true then
			self:settext("Overall Level: 10".."\nEXP Earned: "..profileXP.."/"..(2^10))
		elseif profileXP == 2^10 and IsNetSMOnline() == true then
			self:settext("Overall Level: 11".."\nEXP Earned: "..profileXP.."/"..(2^11))
		elseif profileXP > 2^10 and profileXP < 2^11 and IsNetSMOnline() == true then
			self:settext("Overall Level: 11".."\nEXP Earned: "..profileXP.."/"..(2^11))
		elseif profileXP == 2^11 and IsNetSMOnline() == true then
			self:settext("Overall Level: 12".."\nEXP Earned: "..profileXP.."/"..(2^12))
		elseif profileXP > 2^11 and profileXP < 2^12 and IsNetSMOnline() == true then
			self:settext("Overall Level: 12".."\nEXP Earned: "..profileXP.."/"..(2^12))
		elseif profileXP == 2^12 and IsNetSMOnline() == true then
			self:settext("Overall Level: 13".."\nEXP Earned: "..profileXP.."/"..(2^13))
		elseif profileXP > 2^12 and profileXP < 2^13 and IsNetSMOnline() == true then
			self:settext("Overall Level: 13".."\nEXP Earned: "..profileXP.."/"..(2^13))
		elseif profileXP == 2^13 and IsNetSMOnline() == true then
			self:settext("Overall Level: 14".."\nEXP Earned: "..profileXP.."/"..(2^14))
		elseif profileXP > 2^13 and profileXP < 2^14 and IsNetSMOnline() == true then
			self:settext("Overall Level: 14".."\nEXP Earned: "..profileXP.."/"..(2^14))
		elseif profileXP == 2^14 and IsNetSMOnline() == true then
			self:settext("Overall Level: 15".."\nEXP Earned: "..profileXP.."/"..(2^15))
		elseif profileXP > 2^14 and profileXP < 2^15 and IsNetSMOnline() == true then
			self:settext("Overall Level: 15".."\nEXP Earned: "..profileXP.."/"..(2^15))
		elseif profileXP == 2^15 and IsNetSMOnline() == true then
			self:settext("Overall Level: 16".."\nEXP Earned: "..profileXP.."/"..(2^16))
		elseif profileXP > 2^15 and profileXP < 2^16 and IsNetSMOnline() == true then
			self:settext("Overall Level: 16".."\nEXP Earned: "..profileXP.."/"..(2^16))
		elseif profileXP == 2^16 and IsNetSMOnline() == true then
			self:settext("Overall Level: 17".."\nEXP Earned: "..profileXP.."/"..(2^17))
		elseif profileXP > 2^16 and profileXP < 2^17 and IsNetSMOnline() == true then
			self:settext("Overall Level: 17".."\nEXP Earned: "..profileXP.."/"..(2^17))
		elseif profileXP == 2^17 and IsNetSMOnline() == true then
			self:settext("Overall Level: 18".."\nEXP Earned: "..profileXP.."/"..(2^18))
		elseif profileXP > 2^17 and profileXP < 2^18 and IsNetSMOnline() == true then
			self:settext("Overall Level: 18".."\nEXP Earned: "..profileXP.."/"..(2^18))
		elseif profileXP == 2^18 and IsNetSMOnline() == true then
			self:settext("Overall Level: 19".."\nEXP Earned: "..profileXP.."/"..(2^19))
		elseif profileXP > 2^18 and profileXP < 2^19 and IsNetSMOnline() == true then
			self:settext("Overall Level: 19".."\nEXP Earned: "..profileXP.."/"..(2^19))
		elseif profileXP == 2^19 and IsNetSMOnline() == true then
			self:settext("Overall Level: 20".."\nEXP Earned: "..profileXP.."/"..(2^20))
		elseif profileXP > 2^19 and profileXP < 2^20 and IsNetSMOnline() == true then
			self:settext("Overall Level: 20".."\nEXP Earned: "..profileXP.."/"..(2^20))
		elseif profileXP == 2^20 and IsNetSMOnline() == true then
			self:settext("Overall Level: 21".."\nEXP Earned: "..profileXP.."/"..(2^21))
		elseif profileXP > 2^20 and profileXP < 2^21 and IsNetSMOnline() == true then
			self:settext("Overall Level: 21".."\nEXP Earned: "..profileXP.."/"..(2^21))
		elseif profileXP == 2^21 and IsNetSMOnline() == true then
			self:settext("Overall Level: 22".."\nEXP Earned: "..profileXP.."/"..(2^22))
		elseif profileXP > 2^21 and profileXP < 2^22 and IsNetSMOnline() == true then
			self:settext("Overall Level: 22".."\nEXP Earned: "..profileXP.."/"..(2^22))
		elseif profileXP == 2^22 and IsNetSMOnline() == true then
			self:settext("Overall Level: 23".."\nEXP Earned: "..profileXP.."/"..(2^23))
		elseif profileXP > 2^22 and profileXP < 2^23 and IsNetSMOnline() == true then
			self:settext("Overall Level: 23".."\nEXP Earned: "..profileXP.."/"..(2^23))
		elseif profileXP == 2^23 and IsNetSMOnline() == true then
			self:settext("Overall Level: 24".."\nEXP Earned: "..profileXP.."/"..(2^24))
		elseif profileXP > 2^23 and profileXP < 2^24 and IsNetSMOnline() == true then
			self:settext("Overall Level: 24".."\nEXP Earned: "..profileXP.."/"..(2^24))
		elseif profileXP == 2^24 and IsNetSMOnline() == true then
			self:settext("Overall Level: 25".."\nEXP Earned: "..profileXP.."/"..(2^25))
		elseif profileXP > 2^24 and profileXP < 2^25 and IsNetSMOnline() == true then
			self:settext("Overall Level: 25".."\nEXP Earned: "..profileXP.."/"..(2^25))
		elseif profileXP == 2^25 and IsNetSMOnline() == true then
			self:settext("Overall Level: 26".."\nEXP Earned: "..profileXP.."/"..(2^26))
		elseif profileXP > 2^25 and profileXP < 2^26 and IsNetSMOnline() == true then
			self:settext("Overall Level: 26".."\nEXP Earned: "..profileXP.."/"..(2^26))
		elseif profileXP == 2^26 and IsNetSMOnline() == true then
			self:settext("Overall Level: 27".."\nEXP Earned: "..profileXP.."/"..(2^27))
		elseif profileXP > 2^26 and profileXP < 2^27 and IsNetSMOnline() == true then
			self:settext("Overall Level: 27".."\nEXP Earned: "..profileXP.."/"..(2^27))
		elseif profileXP == 2^27 and IsNetSMOnline() == true then
			self:settext("Overall Level: 28".."\nEXP Earned: "..profileXP.."/"..(2^28))
		elseif profileXP > 2^27 and profileXP < 2^28 and IsNetSMOnline() == true then
			self:settext("Overall Level: 28".."\nEXP Earned: "..profileXP.."/"..(2^28))
		elseif profileXP == 2^28 and IsNetSMOnline() == true then
			self:settext("Overall Level: 29".."\nEXP Earned: "..profileXP.."/"..(2^29))
		elseif profileXP > 2^28 and profileXP < 2^29 and IsNetSMOnline() == true then
			self:settext("Overall Level: 29".."\nEXP Earned: "..profileXP.."/"..(2^29))
		elseif profileXP == 2^29 and IsNetSMOnline() == true then
			self:settext("Overall Level: 30".."\nEXP Earned: "..profileXP.."/"..(2^30))
		elseif profileXP > 2^29 and profileXP < 2^30 and IsNetSMOnline() == true then
			self:settext("Overall Level: 30".."\nEXP Earned: "..profileXP.."/"..(2^30))
		elseif profileXP == 2^30 and IsNetSMOnline() == true then
			self:settext("Overall Level: 31".."\nEXP Earned: "..profileXP.."/"..(2^31))
		elseif profileXP > 2^30 and profileXP < 2^31 and IsNetSMOnline() == true then
			self:settext("Overall Level: 31".."\nEXP Earned: "..profileXP.."/"..(2^31))
		elseif profileXP == 2^31 and IsNetSMOnline() == true then
			self:settext("Overall Level: 32".."\nEXP Earned: "..profileXP.."/"..(2^32))
		elseif profileXP > 2^31 and profileXP < 2^32 and IsNetSMOnline() == true then
			self:settext("Overall Level: 32".."\nEXP Earned: "..profileXP.."/"..(2^32))
		elseif profileXP == 2^32 and IsNetSMOnline() == true then
			self:settext("Overall Level: 33".."\nEXP Earned: "..profileXP.."/"..(2^33))
		elseif profileXP > 2^32 and profileXP < 2^33 and IsNetSMOnline() == true then
			self:settext("Overall Level: 33".."\nEXP Earned: "..profileXP.."/"..(2^33))
		elseif profileXP == 2^33 and IsNetSMOnline() == true then
			self:settext("Overall Level: 34".."\nEXP Earned: "..profileXP.."/"..(2^34))
		elseif profileXP > 2^33 and profileXP < 2^34 and IsNetSMOnline() == true then
			self:settext("Overall Level: 34".."\nEXP Earned: "..profileXP.."/"..(2^34))
		elseif profileXP == 2^34 and IsNetSMOnline() == true then
			self:settext("Overall Level: 35".."\nEXP Earned: "..profileXP.."/"..(2^35))
		elseif profileXP > 2^34 and profileXP < 2^35 and IsNetSMOnline() == true then
			self:settext("Overall Level: 35".."\nEXP Earned: "..profileXP.."/"..(2^35))
		elseif profileXP == 2^35 and IsNetSMOnline() == true then
			self:settext("Overall Level: 36".."\nEXP Earned: "..profileXP.."/"..(2^36))
		elseif profileXP > 2^35 and profileXP < 2^36 and IsNetSMOnline() == true then
			self:settext("Overall Level: 36".."\nEXP Earned: "..profileXP.."/"..(2^36))
		elseif profileXP == 2^36 and IsNetSMOnline() == true then
			self:settext("Overall Level: 37".."\nEXP Earned: "..profileXP.."/"..(2^37))
		elseif profileXP > 2^36 and profileXP < 2^37 and IsNetSMOnline() == true then
			self:settext("Overall Level: 37".."\nEXP Earned: "..profileXP.."/"..(2^37))
		elseif profileXP == 2^37 and IsNetSMOnline() == true then
			self:settext("Overall Level: 38".."\nEXP Earned: "..profileXP.."/"..(2^38))
		elseif profileXP > 2^37 and profileXP < 2^38 and IsNetSMOnline() == true then
			self:settext("Overall Level: 38".."\nEXP Earned: "..profileXP.."/"..(2^38))
		elseif profileXP == 2^38 and IsNetSMOnline() == true then
			self:settext("Overall Level: 39".."\nEXP Earned: "..profileXP.."/"..(2^39))
		elseif profileXP > 2^38 and profileXP < 2^39 and IsNetSMOnline() == true then
			self:settext("Overall Level: 39".."\nEXP Earned: "..profileXP.."/"..(2^39))
		elseif profileXP == 2^39 and IsNetSMOnline() == true then
			self:settext("Overall Level: 40".."\nEXP Earned: "..profileXP.."/999999999999")
		elseif profileXP > 2^39 and profileXP < 2^40 and IsNetSMOnline() == true then
			self:settext("Overall Level: 40".."\nEXP Earned: "..profileXP.."/999999999999")
		--Level cap. -Misterkister
		elseif profileXP == 2^40 and IsNetSMOnline() == true then
			self:settext("Overall Level: MAX".."\nEXP Earned: 999999999999/999999999999")
		elseif profileXP > 2^40 and IsNetSMOnline() == true then
			self:settext("Overall Level: MAX".."\nEXP Earned: 999999999999/999999999999")
		else
			self:settext("")
			end
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
	},
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,AvatarX+53,AvatarY+7;halign,0;zoom,0.6;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
		--Online only. Take it with a grain of salt of where you're at. -Misterkister
		if skillsets.Overall < tier_two and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 1: Novice)",profileName,skillsets.Overall)
		elseif skillsets.Overall == tier_two and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 2: Basic)",profileName,skillsets.Overall)
		elseif skillsets.Overall > tier_two and skillsets.Overall < tier_three and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 2: Basic)",profileName,skillsets.Overall)
		elseif skillsets.Overall == tier_three and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 3: Intermediate)",profileName,skillsets.Overall)
		elseif skillsets.Overall > tier_three and skillsets.Overall < tier_four and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 3: Intermediate)",profileName,skillsets.Overall)
		elseif skillsets.Overall == tier_four and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 4: Advanced)",profileName,skillsets.Overall)
		elseif skillsets.Overall > tier_four and skillsets.Overall < tier_five and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 4: Advanced)",profileName,skillsets.Overall)
		elseif skillsets.Overall == tier_five and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 5: Expert)",profileName,skillsets.Overall)
		elseif skillsets.Overall > tier_five and skillsets.Overall < tier_six and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 5: Expert)",profileName,skillsets.Overall)
		elseif skillsets.Overall == tier_six and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 6: Master)",profileName,skillsets.Overall)
		elseif skillsets.Overall > tier_six and skillsets.Overall < tier_seven and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 6: Master)",profileName,skillsets.Overall)
		elseif skillsets.Overall == tier_seven and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 7: Veteran)",profileName,skillsets.Overall)
		elseif skillsets.Overall > tier_seven and skillsets.Overall < tier_eight and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 7: Veteran)",profileName,skillsets.Overall)
		elseif skillsets.Overall == tier_eight and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 8: Legendary)",profileName,skillsets.Overall)
		elseif skillsets.Overall > tier_eight and skillsets.Overall < tier_nine and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 8: Legendary)",profileName,skillsets.Overall)
		elseif skillsets.Overall == tier_nine and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 9: Vibro Legend)",profileName,skillsets.Overall)
		elseif skillsets.Overall > tier_nine and IsNetSMOnline() == true then
			self:settextf("%s: %5.2f (Tier 9: Vibro Legend)",profileName,skillsets.Overall)
		else
			self:settextf("%s: %5.2f",profileName,skillsets.Overall)
			end
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
	},
}

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	if getAvatarUpdateStatus(PLAYER_1) then
    	self:GetChild("Avatar"..PLAYER_1):GetChild("Image"):queuecommand("ModifyAvatar")
    	setAvatarUpdateStatus(PLAYER_1,false)
    end;
end
t.InitCommand=cmd(SetUpdateFunction,Update)

local function littlebits(i)
	local t = Def.ActorFrame{
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,AvatarX+200,AvatarY+10*i;halign,0;zoom,0.35;diffuse,getMainColor('positive')),
			BeginCommand=cmd(queuecommand,"Set"),
			SetCommand=function(self)
				self:settext(ms.SkillSets[i]..":")
			end,
			PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
			PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
		},
		LoadFont("Common Normal") .. {
			InitCommand=cmd(xy,AvatarX+300,AvatarY+10*i;halign,1;zoom,0.35),
			BeginCommand=cmd(queuecommand,"Set"),
			SetCommand=function(self)
				self:settextf("%5.2f",skillsets[ms.SkillSets[i]])
				self:diffuse(ByMSD(skillsets[ms.SkillSets[i]]))
			end,
			PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
			PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
		}
	}
	return t
end

for i=2,#ms.SkillSets do 
	--t[#t+1] = littlebits(i)
end

return t
