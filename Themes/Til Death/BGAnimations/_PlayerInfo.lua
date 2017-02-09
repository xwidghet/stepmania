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
local profileXP = 0
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
	--Along with the level system, this need to be simplified.
	--Gonna bring this feature when you play SMO only. Even though there's already a level system in SMO, this is a more in-game level system instead (as SMO only show the level system when you check your profile on the website.)
	--Definitely redundant, but people won't care about the level system anyway. -Misterkister
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,SCREEN_CENTER_X,AvatarY+30;halign,0.5;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
		if profileXP < 4 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/4")
		elseif profileXP == 4 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/8")
		elseif profileXP > 4 and profileXP < 8 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/8")
		elseif profileXP == 8 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/16")
		elseif profileXP > 8 and profileXP < 16 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/16")
		elseif profileXP == 16 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/32")
		elseif profileXP > 16 and profileXP < 32 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/32")
		elseif profileXP == 32 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/64")
		elseif profileXP > 32 and profileXP < 64 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/64")
		elseif profileXP == 64 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/128")
		elseif profileXP > 64 and profileXP < 128 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/128")
		elseif profileXP == 128 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/256")
		elseif profileXP > 128 and profileXP < 256 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/256")
		elseif profileXP == 256 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/512")
		elseif profileXP > 256 and profileXP < 512 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/512")
		elseif profileXP == 512 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/1024")
		elseif profileXP > 512 and profileXP < 1024 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/1024")
		elseif profileXP == 1024 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/2048")
		elseif profileXP > 1024 and profileXP < 2048 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/2048")
		elseif profileXP == 2048 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/4096")
		elseif profileXP > 2048 and profileXP < 4096 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/4096")
		elseif profileXP == 4096 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/8192")
		elseif profileXP > 4096 and profileXP < 8192 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/8192")
		elseif profileXP == 8192 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/16384")
		elseif profileXP > 8192 and profileXP < 16384 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/16384")
		elseif profileXP == 16384 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/32768")
		elseif profileXP > 16384 and profileXP < 32768 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/32768")
		elseif profileXP == 32768 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/65536")
		elseif profileXP > 32768 and profileXP < 65536 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/65536")
		elseif profileXP == 65536  and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/131072")
		elseif profileXP > 65536 and profileXP < 131072  and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/131072")
		elseif profileXP == 131072  and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/262144")
		elseif profileXP > 131072 and profileXP < 262144  and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/262144")
		elseif profileXP == 262144 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/524288")
		elseif profileXP > 262144 and profileXP < 524288 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/524288")
		elseif profileXP == 524288 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/1048576")
		elseif profileXP > 524288 and profileXP < 1048576 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/1048576")
		elseif profileXP == 1048576 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/2097152")
		elseif profileXP > 1048576 and profileXP < 2097152 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/2097152")
		elseif profileXP == 2097152 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/4194304")
		elseif profileXP > 2097152 and profileXP < 4194304 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/4194304")
		elseif profileXP == 4194304 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/8388608")
		elseif profileXP > 4194304 and profileXP < 8388608 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/8388608")
		elseif profileXP == 8388608 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/16777216")
		elseif profileXP > 8388608 and profileXP < 16777216 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/16777216")
		elseif profileXP == 16777216 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/33554432")
		elseif profileXP > 16777216 and profileXP < 33554432 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/33554432")
		elseif profileXP == 33554432 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/67108864")
		elseif profileXP > 33554432 and profileXP < 67108864 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/67108864")
		elseif profileXP == 67108864 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/134217728")
		elseif profileXP > 67108864 and profileXP < 134217728 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/134217728")
		elseif profileXP == 134217728 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/268435456")
		elseif profileXP > 134217728 and profileXP < 268435456 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/268435456")
		elseif profileXP == 268435456 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/536870912")
		elseif profileXP > 268435456 and profileXP < 536870912 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/536870912")
		elseif profileXP == 536870912 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/1073741824")
		elseif profileXP > 536870912 and profileXP < 1073741824 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/1073741824")
		elseif profileXP == 1073741824 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/2147483648")
		elseif profileXP > 1073741824 and profileXP < 2147483648 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/2147483648")
		elseif profileXP == 2147483648 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/4294967296")
		elseif profileXP > 2147483648 and profileXP < 4294967296 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/4294967296")
		elseif profileXP == 4294967296 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/8589934592")
		elseif profileXP > 4294967296 and profileXP < 8589934592 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/8589934592")
		elseif profileXP == 8589934592 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/17179869184")
		elseif profileXP > 8589934592 and profileXP < 17179869184 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/17179869184")
		elseif profileXP == 17179869184 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/34359738368")
		elseif profileXP > 17179869184 and profileXP < 34359738368 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/34359738368")
		elseif profileXP == 34359738368 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/68719476736")
		elseif profileXP > 34359738368 and profileXP < 68719476736 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/68719476736")
		elseif profileXP == 68719476736 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/137438953472")
		elseif profileXP > 68719476736 and profileXP < 137438953472 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/137438953472")
		elseif profileXP == 137438953472 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/274877906944")
		elseif profileXP > 137438953472 and profileXP < 274877906944 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/274877906944")
		elseif profileXP == 274877906944 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/549755813888")
		elseif profileXP > 274877906944 and profileXP < 549755813888 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/549755813888")
		elseif profileXP == 549755813888 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/999999999999")
		--Maxed out exp. -Misterkister
		elseif profileXP > 549755813888 and profileXP < 999999999999 and IsNetSMOnline() == true then
			self:settext("EXP Earned: "..profileXP.."/999999999999")
		elseif profileXP == 999999999999 and IsNetSMOnline() == true then
			self:settext("EXP Earned: 999999999999/999999999999")
		elseif profileXP > 999999999999 and IsNetSMOnline() == true then
			self:settext("EXP Earned: 999999999999/999999999999")
		else
			self:settext("")
			end
		end,
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set"),
		PlayerUnjoinedMessageCommand=cmd(queuecommand,"Set"),
	},
	--This is BY FAR the stupidest way to set the levels, but I'm going to put this here until someone find a proper efficient way to fix this.
	--Levels are up to 40. Formula for the level is 2^x.
	--Moving this to online. -Misterkister
	LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,SCREEN_CENTER_X,AvatarY+20;halign,0.5;zoom,0.35;diffuse,getMainColor('positive')),
		BeginCommand=cmd(queuecommand,"Set"),
		SetCommand=function(self)
		if profileXP < 4 and IsNetSMOnline() == true then
			self:settext("Overall Level: 1")
		elseif profileXP == 4 and IsNetSMOnline() == true then
			self:settext("Overall Level: 2")
		elseif profileXP > 4 and profileXP < 8 and IsNetSMOnline() == true then
			self:settext("Overall Level: 2")
		elseif profileXP == 8 and IsNetSMOnline() == true then
			self:settext("Overall Level: 3")
		elseif profileXP > 8 and profileXP < 16 and IsNetSMOnline() == true then
			self:settext("Overall Level: 3")
		elseif profileXP == 16 and IsNetSMOnline() == true then
			self:settext("Overall Level: 4")
		elseif profileXP > 16 and profileXP < 32 and IsNetSMOnline() == true then
			self:settext("Overall Level: 4")
		elseif profileXP == 32 and IsNetSMOnline() == true then
			self:settext("Overall Level: 5")
		elseif profileXP > 32 and profileXP < 64 and IsNetSMOnline() == true then
			self:settext("Overall Level: 5")
		elseif profileXP == 64 and IsNetSMOnline() == true then
			self:settext("Overall Level: 6")
		elseif profileXP > 64 and profileXP < 128 and IsNetSMOnline() == true then
			self:settext("Overall Level: 6")
		elseif profileXP == 128 and IsNetSMOnline() == true then
			self:settext("Overall Level: 7")
		elseif profileXP > 128 and profileXP < 256 and IsNetSMOnline() == true then
			self:settext("Overall Level: 7")
		elseif profileXP == 256 and IsNetSMOnline() == true then
			self:settext("Overall Level: 8")
		elseif profileXP > 256 and profileXP < 512 and IsNetSMOnline() == true then
			self:settext("Overall Level: 8")
		elseif profileXP == 512 and IsNetSMOnline() == true then
			self:settext("Overall Level: 9")
		elseif profileXP > 512 and profileXP < 1024 and IsNetSMOnline() == true then
			self:settext("Overall Level: 9")
		elseif profileXP == 1024 and IsNetSMOnline() == true then
			self:settext("Overall Level: 10")
		elseif profileXP > 1024 and profileXP < 2048 and IsNetSMOnline() == true then
			self:settext("Overall Level: 10")
		elseif profileXP == 2048 and IsNetSMOnline() == true then
			self:settext("Overall Level: 11")
		elseif profileXP > 2048 and profileXP < 4096 and IsNetSMOnline() == true then
			self:settext("Overall Level: 11")
		elseif profileXP == 4096 and IsNetSMOnline() == true then
			self:settext("Overall Level: 12")
		elseif profileXP > 4096 and profileXP < 8192 and IsNetSMOnline() == true then
			self:settext("Overall Level: 12")
		elseif profileXP == 8192 and IsNetSMOnline() == true then
			self:settext("Overall Level: 13")
		elseif profileXP > 8192 and profileXP < 16384 and IsNetSMOnline() == true then
			self:settext("Overall Level: 13")
		elseif profileXP == 16384 and IsNetSMOnline() == true then
			self:settext("Overall Level: 14")
		elseif profileXP > 16384 and profileXP < 32768 and IsNetSMOnline() == true then
			self:settext("Overall Level: 14")
		elseif profileXP == 32768 and IsNetSMOnline() == true then
			self:settext("Overall Level: 15")
		elseif profileXP > 32768 and profileXP < 65536 and IsNetSMOnline() == true then
			self:settext("Overall Level: 15")
		elseif profileXP == 65536 and IsNetSMOnline() == true then
			self:settext("Overall Level: 16")
		elseif profileXP > 65536 and profileXP < 131072 and IsNetSMOnline() == true then
			self:settext("Overall Level: 16")
		elseif profileXP == 131072 and IsNetSMOnline() == true then
			self:settext("Overall Level: 17")
		elseif profileXP > 131072 and profileXP < 262144 and IsNetSMOnline() == true then
			self:settext("Overall Level: 17")
		elseif profileXP == 262144 and IsNetSMOnline() == true then
			self:settext("Overall Level: 18")
		elseif profileXP > 262144 and profileXP < 524288 and IsNetSMOnline() == true then
			self:settext("Overall Level: 18")
		elseif profileXP == 524288 and IsNetSMOnline() == true then
			self:settext("Overall Level: 19")
		elseif profileXP > 524288 and profileXP < 1048576 and IsNetSMOnline() == true then
			self:settext("Overall Level: 19")
		elseif profileXP == 1048576 and IsNetSMOnline() == true then
			self:settext("Overall Level: 20")
		elseif profileXP > 1048576 and profileXP < 2097152 and IsNetSMOnline() == true then
			self:settext("Overall Level: 20")
		elseif profileXP == 2097152 and IsNetSMOnline() == true then
			self:settext("Overall Level: 21")
		elseif profileXP > 2097152 and profileXP < 4194304 and IsNetSMOnline() == true then
			self:settext("Overall Level: 21")
		elseif profileXP == 4194304 and IsNetSMOnline() == true then
			self:settext("Overall Level: 22")
		elseif profileXP > 4194304 and profileXP < 8388608 and IsNetSMOnline() == true then
			self:settext("Overall Level: 22")
		elseif profileXP == 8388608 and IsNetSMOnline() == true then
			self:settext("Overall Level: 23")
		elseif profileXP > 8388608 and profileXP < 16777216 and IsNetSMOnline() == true then
			self:settext("Overall Level: 23")
		elseif profileXP == 16777216 and IsNetSMOnline() == true then
			self:settext("Overall Level: 24")
		elseif profileXP > 16777216 and profileXP < 33554432 and IsNetSMOnline() == true then
			self:settext("Overall Level: 24")
		elseif profileXP == 33554432 and IsNetSMOnline() == true then
			self:settext("Overall Level: 25")
		elseif profileXP > 33554432 and profileXP < 67108864 and IsNetSMOnline() == true then
			self:settext("Overall Level: 25")
		elseif profileXP == 67108864 and IsNetSMOnline() == true then
			self:settext("Overall Level: 26")
		elseif profileXP > 67108864 and profileXP < 134217728 and IsNetSMOnline() == true then
			self:settext("Overall Level: 26")
		elseif profileXP == 134217728 and IsNetSMOnline() == true then
			self:settext("Overall Level: 27")
		elseif profileXP > 134217728 and profileXP < 268435456 and IsNetSMOnline() == true then
			self:settext("Overall Level: 27")
		elseif profileXP == 268435456 and IsNetSMOnline() == true then
			self:settext("Overall Level: 28")
		elseif profileXP > 268435456 and profileXP < 536870912 and IsNetSMOnline() == true then
			self:settext("Overall Level: 28")
		elseif profileXP == 536870912 and IsNetSMOnline() == true then
			self:settext("Overall Level: 29")
		elseif profileXP > 536870912 and profileXP < 1073741824 and IsNetSMOnline() == true then
			self:settext("Overall Level: 29")
		elseif profileXP == 1073741824 and IsNetSMOnline() == true then
			self:settext("Overall Level: 30")
		elseif profileXP > 1073741824 and profileXP < 2147483648 and IsNetSMOnline() == true then
			self:settext("Overall Level: 30")
		elseif profileXP == 2147483648 and IsNetSMOnline() == true then
			self:settext("Overall Level: 31")
		elseif profileXP > 2147483648 and profileXP < 4294967296 and IsNetSMOnline() == true then
			self:settext("Overall Level: 31")
		elseif profileXP == 4294967296 and IsNetSMOnline() == true then
			self:settext("Overall Level: 32")
		elseif profileXP > 4294967296 and profileXP < 8589934592 and IsNetSMOnline() == true then
			self:settext("Overall Level: 32")
		elseif profileXP == 8589934592 and IsNetSMOnline() == true then
			self:settext("Overall Level: 33")
		elseif profileXP > 8589934592 and profileXP < 17179869184 and IsNetSMOnline() == true then
			self:settext("Overall Level: 33")
		elseif profileXP == 17179869184 and IsNetSMOnline() == true then
			self:settext("Overall Level: 34")
		elseif profileXP > 17179869184 and profileXP < 34359738368 and IsNetSMOnline() == true then
			self:settext("Overall Level: 34")
		elseif profileXP == 34359738368 and IsNetSMOnline() == true then
			self:settext("Overall Level: 35")
		elseif profileXP > 34359738368 and profileXP < 68719476736 and IsNetSMOnline() == true then
			self:settext("Overall Level: 35")
		elseif profileXP == 68719476736 and IsNetSMOnline() == true then
			self:settext("Overall Level: 36")
		elseif profileXP > 68719476736 and profileXP < 137438953472 and IsNetSMOnline() == true then
			self:settext("Overall Level: 36")
		elseif profileXP == 137438953472 and IsNetSMOnline() == true then
			self:settext("Overall Level: 37")
		elseif profileXP > 137438953472 and profileXP < 274877906944 and IsNetSMOnline() == true then
			self:settext("Overall Level: 37")
		elseif profileXP == 274877906944 and IsNetSMOnline() == true then
			self:settext("Overall Level: 38")
		elseif profileXP > 274877906944 and profileXP < 549755813888 and IsNetSMOnline() == true then
			self:settext("Overall Level: 38")
		elseif profileXP == 549755813888 and IsNetSMOnline() == true then
			self:settext("Overall Level: 39")
		elseif profileXP > 549755813888 and profileXP < 999999999999 and IsNetSMOnline() == true then
			self:settext("Overall Level: 39")
		--Level has been maxed out. -Misterkister
		elseif profileXP == 999999999999 and IsNetSMOnline() == true then
			self:settext("Overall Level: 40")
		elseif profileXP > 999999999999 and IsNetSMOnline() == true then
			self:settext("Overall Level: 40")
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
