#pragma once
/*
-----------------------------------------------------------------------------
 Class: AnnouncerManager

 Desc: Manages which graphics and sounds are chosed to load.  Every time 
	a sound or graphic is loaded, it gets the path from the AnnouncerManager.

 Copyright (c) 2001-2002 by the person(s) listed below.  All rights reserved.
	Chris Danford
-----------------------------------------------------------------------------
*/

#include "RageUtil.h"


enum AnnouncerElement { 
	ANNOUNCER_CAUTION,
	ANNOUNCER_GAMEPLAY_100_COMBO,
	ANNOUNCER_GAMEPLAY_1000_COMBO,
	ANNOUNCER_GAMEPLAY_200_COMBO,
	ANNOUNCER_GAMEPLAY_300_COMBO,
	ANNOUNCER_GAMEPLAY_400_COMBO,
	ANNOUNCER_GAMEPLAY_500_COMBO,
	ANNOUNCER_GAMEPLAY_600_COMBO,
	ANNOUNCER_GAMEPLAY_700_COMBO,
	ANNOUNCER_GAMEPLAY_800_COMBO,
	ANNOUNCER_GAMEPLAY_900_COMBO,
	ANNOUNCER_GAMEPLAY_CLEARED,
	ANNOUNCER_GAMEPLAY_COMBO_STOPPED,
	ANNOUNCER_GAMEPLAY_COMMENT_DANGER,
	ANNOUNCER_GAMEPLAY_COMMENT_GOOD,
	ANNOUNCER_GAMEPLAY_COMMENT_HOT,
	ANNOUNCER_GAMEPLAY_FAILED,
	ANNOUNCER_GAMEPLAY_HERE_WE_GO_EXTRA,
	ANNOUNCER_GAMEPLAY_HERE_WE_GO_FINAL,
	ANNOUNCER_GAMEPLAY_HERE_WE_GO_NORMAL,
	ANNOUNCER_GAMEPLAY_READY,
	ANNOUNCER_EVALUATION_FINAL_A,
	ANNOUNCER_EVALUATION_FINAL_AA,
	ANNOUNCER_EVALUATION_FINAL_AAA,
	ANNOUNCER_EVALUATION_FINAL_B,
	ANNOUNCER_EVALUATION_FINAL_C,
	ANNOUNCER_EVALUATION_FINAL_D,
	ANNOUNCER_GAME_OVER,
	ANNOUNCER_MUSIC_SCROLL,
	ANNOUNCER_EVALUATION_A,
	ANNOUNCER_EVALUATION_AA,
	ANNOUNCER_EVALUATION_AAA,
	ANNOUNCER_EVALUATION_B,
	ANNOUNCER_EVALUATION_C,
	ANNOUNCER_EVALUATION_D,
	ANNOUNCER_SELECT_COURSE_INTRO,
	ANNOUNCER_SELECT_DIFFICULTY_COMMENT_EASY,
	ANNOUNCER_SELECT_DIFFICULTY_COMMENT_HARD,
	ANNOUNCER_SELECT_DIFFICULTY_COMMENT_MEDIUM,
	ANNOUNCER_SELECT_DIFFICULTY_COMMENT_ONI,
	ANNOUNCER_SELECT_DIFFICULTY_CHALLENGE,
	ANNOUNCER_SELECT_DIFFICULTY_INTRO,
	ANNOUNCER_SELECT_GROUP_COMMENT_ALL_MUSIC,
	ANNOUNCER_SELECT_GROUP_COMMENT_GENERAL,
	ANNOUNCER_SELECT_GROUP_INTRO,
	ANNOUNCER_SELECT_MUSIC_COMMENT_GENERAL,
	ANNOUNCER_SELECT_MUSIC_COMMENT_HARD,
	ANNOUNCER_SELECT_MUSIC_COMMENT_NEW,
	ANNOUNCER_SELECT_MUSIC_INTRO,
	ANNOUNCER_SELECT_STYLE_COMMENT_COUPLE,
	ANNOUNCER_SELECT_STYLE_COMMENT_DOUBLE,
	ANNOUNCER_SELECT_STYLE_COMMENT_SINGLE,
	ANNOUNCER_SELECT_STYLE_COMMENT_SOLO,
	ANNOUNCER_SELECT_STYLE_COMMENT_VERSUS,
	ANNOUNCER_SELECT_STYLE_INTRO,
	ANNOUNCER_STAGE_1,
	ANNOUNCER_STAGE_2,
	ANNOUNCER_STAGE_3,
	ANNOUNCER_STAGE_4,
	ANNOUNCER_STAGE_5,
	ANNOUNCER_STAGE_EXTRA,
	ANNOUNCER_STAGE_FINAL,
	ANNOUNCER_TITLE_MENU_ATTRACT,
	ANNOUNCER_TITLE_MENU_GAME_NAME,

	NUM_ANNOUNCER_ELEMENTS	// leave this at the end
};


class AnnouncerManager
{
public:
	AnnouncerManager();

	void GetAnnouncerNames( CStringArray& AddTo );
	CString GetCurrentAnnouncerName() { return m_sCurAnnouncerName; }
	void SwitchAnnouncer( CString sAnnouncerName );		// return false if Announcer doesn't exist
	void AssertAnnouncerIsComplete( CString sAnnouncerName );		// return false if Announcer doesn't exist
	CString GetPathTo( AnnouncerElement ae );
	CString GetPathTo( AnnouncerElement ae, CString sAnnouncerName );

protected:
	CString GetAnnouncerDirFromName( CString sAnnouncerName );
	CString GetElementDir( AnnouncerElement te );

	CString m_sCurAnnouncerName;
};



extern AnnouncerManager*	ANNOUNCER;	// global and accessable from anywhere in our program
