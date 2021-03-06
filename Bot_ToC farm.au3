#cs
#################################
#                               #
#          Vaettir Bot          #
#                               #
#################################
Author: farmzor
Modified by; Greg76
#ce

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_type=a3x
#AutoIt3Wrapper_Outfile=..\Exe\Bot_ToC farm.a3x
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /tl
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <_Files.au3>

#Region declarations
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global $bag_slots[5] = [0, 20, 5, 10, 10]
Global $spawned = False
global  $ensuresafety = False  ; will zone  until it finds empty dis , and wont kneel if people in town
global const $warrsupply = 35121
global const $champion = 1947
Global Const $fow = 34
Global Const $grog = 30885
global const $chantry = 393
Global Const $embark = 857
global const $toa = 138
Global Const $shard = 945
Global Const $scroll = 22280
Global Const $scrollitem = GetItemByModelID($scroll)
Global Const $darkremains = 522
Global Const $ruby = 937
Global Const $saph = 938
Global Const $obbykey = 5971
Global Const $ITEM_ID_Snowman_Summoner = 6376
Global Const $ITEM_ID_Fruitcake = 21492
Global Const $ITEM_ID_Eggnog = 6375
Global Const $ITEM_ID_Mischievious_Tonic = 31020
Global Const $ITEM_ID_Frosty_Tonic = 30648
Global Const $RARITY_GOLD = 2624
Global Const $RARITY_PURPLE = 2626
Global Const $RARITY_BLUE = 2623
Global Const $RARITY_WHITE = 2621
global $town = $toa ;start town
global $shardcount = 0
Global $wins = 0
Global $fails = 0
Global $shardcount = 0
Global $RenderingEnabled = True
Global $BotRunning = False
Global $BotInitialized = False
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Global Const $skill_id_shroud = 1031
global const $skill_id_iau = 2356
global const $skill_id_wd =450
global const $skill_id_mb = 2417
Global Const $ds = 3
Global Const $sf = 2
Global Const $shroud = 1
Global Const $hos = 5
Global Const $wd = 4
Global Const $iau = 6
Global Const $de = 7
Global Const $mb = 8
; Store skills energy cost
Global $skillCost[9]
$skillCost[$ds] = 5
$skillCost[$sf] = 5
$skillCost[$shroud] = 10
$skillCost[$wd] = 4
$skillCost[$hos] = 5
$skillCost[$iau] = 5
$skillCost[$de] = 5
$skillCost[$mb] = 10
#EndRegion declarations
#Region ### START Koda GUI section ### Form=c:\users\dada\documents\fowbot.kxf
$Form1 = GUICreate("toc Morn Rebonk", 220, 375, 1031, 651)
;$Checkbox1 = GUICtrlCreateCheckbox("ensure safety", 8, 192, 97, 17)
;GUICtrlSetState(-1,$gui_checked)
;GUICtrlSetOnEvent(-1,"safety")
$Combo1 = GUICtrlCreateCombo("", 8, 8, 105, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, GetLoggedCharNames())
$Button1 = GUICtrlCreateButton("Initalize", 8, 32, 107, 17)
GUICtrlSetOnEvent(-1, "GuiButtonHandler")
$Group1 = GUICtrlCreateGroup("Runs", 16, 56, 105, 65, BitOR($GUI_SS_DEFAULT_GROUP, $BS_CENTER))
$Label1 = GUICtrlCreateLabel("wins :", 13, 67, 31, 17)
GUICtrlSetColor(-1, 0x008000)
$Label2 = GUICtrlCreateLabel("fails : ", 13, 89, 31, 17)
GUICtrlSetColor(-1, 0xFF0000)
$Label3 = GUICtrlCreateLabel("shards : ", 13, 111, 31, 17)
GUICtrlSetColor(-1, 0x008000)
$shardlabel = GUICtrlCreateLabel("0", 48, 111, 20, 17)
GUICtrlSetColor(-1, 0xFF0000)
$winlabel = GUICtrlCreateLabel("0", 48, 67, 20, 17)
GUICtrlSetColor(-1, 0x008000)
$faillabel = GUICtrlCreateLabel("0", 48, 89, 20, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("entrance method", 16, 128, 105, 57)
$kneelm = GUICtrlCreateRadio("Kneel", 16, 144, 113, 17)
   GUICtrlSetState(-1, $gui_checked)
$scrollm = GUICtrlCreateRadio("Scroll", 16, 160, 113, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("", 8, 232, 105, 35)
$slabel = GUICtrlCreateLabel("waiting on action     ", 54, 286, 131, 57)
GUICtrlSetFont(-1, 12, 400, 0, "MS Serif")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Checkbox2 = GUICtrlCreateCheckbox("disable rendering", 8, 216, 97, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "ToggleRendering")
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

#Region funcs
Func _Exit()
	Local $AgentName = MemoryRead($mCharname, 'wchar[30]')
	WinSetTitle($mGWWindowHandle, '', 'Guild Wars')
	WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Exit
EndFunc

Func GuiButtonHandler()
	If $BotRunning Then
		GUICtrlSetData($Button1, "Will pause after this run")
		GUICtrlSetState($Button1, $GUI_DISABLE)
		$BotRunning = False
	ElseIf $BotInitialized Then
		GUICtrlSetData($Button1, "Pause")
		$BotRunning = True
	Else
		Out("Initializing")
		Local $CharName = GUICtrlRead($Combo1)
		If $CharName == "" Then
			If Initialize(ProcessExists("gw.exe")) = False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf
		Else
			If Initialize($CharName) = False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharName & "'")
				Exit
			EndIf
		EndIf
		GUICtrlSetState($Checkbox2, $GUI_ENABLE)
		GUICtrlSetState($Combo1, $GUI_DISABLE)
		GUICtrlSetData($Button1, "Pause")
		$BotRunning = True
		$BotInitialized = True
		 setmaxmemory()
	  EndIf
EndFunc   ;==>GuiButtonHandler

;Func safety()
	;if GUICtrlRead($Checkbox1) = $gui_checked Then
	;   $ensuresafety = True
	  ; out("safe mode")
    ;Else
	  ; $ensuresafety = False
	  ; out("will ignore people")
   ; EndIf
;EndFunc

Func ToggleRendering()
	$RenderingEnabled = Not $RenderingEnabled
	If $RenderingEnabled Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
EndFunc   ;==>ToggleRendering

;~ Description: Print to console with timestamp
Func Out($TEXT)
	Local $TEXTLEN = StringLen($TEXT)
	Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($GLOGBOX)
	If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($GLOGBOX, StringRight(_GUICtrlEdit_GetText($GLOGBOX), 30000 - $TEXTLEN - 1000))
	_GUICtrlEdit_AppendText($GLOGBOX, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $TEXT)
	_GUICtrlEdit_Scroll($GLOGBOX, 1)
EndFunc   ;==>OUT

;Func UseSkillEx($lSkill, $lTgt = -2, $aTimeout = 3000)
	;$mSkillbar = GetSkillbar()
	;If GetIsDead(-2) Then Return
	;;If Not IsRecharged($lSkill) Then Return
	;If GetEnergy(-2) < $skillCost[$lSkill] Then Return
	;Local $Skill = GetSkillByID(DllStructGetData($mSkillbar, 'Id' & $lSkill))
	;If DllStructGetData($mSkillbar, 'AdrenalineA' & $lSkill) < DllStructGetData($lSkill, 'Adrenaline') Then Return False
	;Local $lDeadlock = TimerInit()
	;UseSkill($lSkill, $lTgt)
	;Do
	;	Sleep(50)
	;	If GetIsDead(-2) = 1 Then Return
	;Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)

	;If $lSkill > 1 Then RndSleep(350)
;EndFunc   ;==>UseSkillEx

Func UseSF()
	If IsRecharged($sf) Then
		UseSkillEx($sf)
	EndIf
	If isrecharged($shroud) and  GetEffectTimeRemaining($skill_id_iau) > 1 Then
		 useSkillEx($shroud)
	EndIf
    if GetEffectTimeRemaining($skill_id_shroud) < 10 then
	   useSkillEx($shroud)
    EndIf
EndFunc   ;==>UseSF

Func MoveRunning($lDestX, $lDestY)
	If GetIsDead(-2) Then Return False

	Local $lMe, $lTgt
	Local $lBlocked = 0
	Local $ChatStuckTimer = TimerInit()

	Move($lDestX, $lDestY)

	Do
		RndSleep(500)

		TargetNearestEnemy()
		$lMe = GetAgentByID(-2)
		$lTgt = GetAgentByID(-1)

		If GetIsDead($lMe) Then Return False
	    if $lblocked > 1 Then
		   If TimerDiff($ChatStuckTimer) > 3000 Then
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
			EndIf
		 EndIf
		UseSF()
		If $lBlocked = 5 Then
			UseSkillEx($hos,-1)
			Sleep(100)
			Move($lDestX, $lDestY)
			If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
				$lBlocked = 1
			Else
				$lBlocked = 0
			EndIf
		 EndIf
		 If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			Move($lDestX, $lDestY)
		EndIf

		If DllStructGetData($lMe, 'hp') < 0.2 Then
			UseSkillEx($hos)
		 EndIf
	    if gethascondition($lme) and  DllStructGetData($lMe, 'hp') < 0.4 Then
			UseSkillEx($hos)
		 EndIf
		 If GetDistance() > 1100 Then ;
			If TimerDiff($ChatStuckTimer) > 3000 Then ;
			   SendChat("stuck", "/")
			   $ChatStuckTimer = TimerInit()
			   RndSleep(GetPing())
			endIf
		 EndIf

	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < 250
	Return True
EndFunc   ;==>MoveRunning

Func WaitFor($lMs,$class = 1 ) ;class cause we dont want to hos @ rangers
	If GetIsDead(-2) Then Return
   $lMe = GetAgentByID(-2)
	Local $lTimer = TimerInit()
	if $class = 1 Then
	Do
	   if GetEffectTimeRemaining($skill_id_wd) < 1 then Return
		Sleep(100)
		If GetIsDead(-2) Then Return
		If IsRecharged($iau)  Then
			UseSkillEx($iau)
		 EndIf

		If DllStructGetData($lMe, 'hp') < 0.3 Then
			UseSkillEx($hos)
		 EndIf
		 if gethascondition($lme) and DllStructGetData($lMe, 'hp') < 0.4 Then
			UseSkillEx($hos)
		 EndIf
		UseSF()
		if isrecharged($mb) and geteffecttimeremaining($skill_id_mb) = 0 Then
		   useskillex($mb)
		 EndIf
	 Until TimerDiff($lTimer) > $lMs or GetIsDead(-2)
  Else
	 Do
		Sleep(100)
		If GetIsDead(-2) Then Return
		If IsRecharged($iau) Then
			UseSkillEx($iau)
		 EndIf
		UseSF()
	 Until TimerDiff($lTimer) > $lMs
  EndIf
EndFunc   ;==>WaitFor

Func useitembyslot($abag, $aslot)
	Local $item = getitembyslot($abag, $aslot)
	Return sendpacket(8, $HEADER_ITEM_USE, DllStructGetData($item, "ID"))
EndFunc   ;==>useitembyslot

While 1
	Sleep(50)
	clearmemory()
	While Not $BotRunning
		Sleep(100)
	WEnd
	enterfow()
	loop()
	If Not $BotRunning Then
		Out("Bot was paused")
		TravelGH()
		GUICtrlSetData($Button1, "Start")
		GUICtrlSetState($Button1, $GUI_ENABLE)
	EndIf
WEnd

Func loop()
	If Not $RenderingEnabled Then ClearMemory()
	If getmapid() <> $fow Then Return
	out("moving to first spot")
	UseSkillEx($sf)
	UseSkillEx($ds)
	UseSkillEx($de)
	moveto(-21131, -2390)
	MoveRunning(-16494, -3113)
	out("starting to ball abbys")
	Sleep(1000)
	UseSkillEx($iau)
	If IsRecharged($ds) Then
		UseSkillEx($ds)
	EndIf
	If IsRecharged($ds) Then
		UseSkillEx($ds)
	EndIf
	useskillex($mb)
	MoveRunning(-14453, -3536)
	UseSkillEx($ds)
	UseSkillEx($wd)
	$whirletimer = TimerInit()
	MoveRunning(-13684, -2077)
	MoveRunning(-14113, -418) ; Put something after here for HoS use to tighten the ball a tad
	out("whirling abbys")
	waitfor(38000 - TimerDiff($whirletimer))
	out("abbys dead") ; Changed by me
	;PickUpLoot() ; Added by me
	Sleep(500)
	;PickUpItems(-1)
	MoveRunning(-13684, -2077)
	out("balling rangers")
	MoveRunning(-15826, -3046)
	rndsleep(1500)
	moveto(-16002, -3031)
	out("checking skills")
	Do
		If getisdead(-2) Then Return
		WaitFor(1500)
	Until IsRecharged($mb) And isrecharged($wd)
	moveto(-16004, -3202)
	MoveRunning(-15272, -3004)
	UseSkillEx($iau)
	UseSkillEx($ds)
	UseSkillEx($mb)
	If IsRecharged($wd) Then
		UseSkillEx($wd)
	EndIf
	If IsRecharged($mb) Then
		UseSkillEx($mb)
	EndIf
	out("killing rangers")
	MoveRunning(-14453, -3536)
	moverunning(-14209, -2935)
	moverunning(-14535, -2615)
	waitfor(27000, 2)
	moveto(-14506, -2633)
	out("looting")
	PickUpLoot()
	Sleep(500)
	TravelTo($toa)
	;PickUpItems(-1)
	If Not getisdead(-2) Then
		$wins = $wins + 1
		GUICtrlSetData($winlabel, $wins)
	EndIf
	If GetIsDead(-2) Then
		$fails = $fails + 1
		GUICtrlSetData($faillabel, $fails)

	EndIf

	$spawned = False
	RndTravel($town)
	WaitMapLoading($town)
EndFunc   ;==>loop

Func enterfow()
	;LoadSkillTemplate("OgcTc5+8Z6ASn5uU4ABimsBKuEA")
	;If GUICtrlRead($scrollm) = $gui_checked Then
		;If getmapid() <> $embark Then
			;travelto($embark)
		;EndIf
		;enterscroll()
	; Else
		CheckGold()
		enterkneel()
		WaitMapLoading($fow)

EndFunc   ;==>enterfow

Func enterscroll()
	Out("using scroll")
	useitembymodelid($scroll)
	WaitMapLoading($fow)
EndFunc   ;==>enterscroll

 func enterkneel()
   if $ensuresafety  Then
	  do
		 rndtravel($town)
		 rndsleep(200)
	  until isdisempty()
	else
	  rndtravel($town)
   EndIf

   if getmapid() = $toa Then
	  out("zoning to toa")
	  rndsleep(200)
	  kneel(-2522,18731)

   EndIf
 EndFunc

 func moveandcheckdis($ax,$ay,$arandom = 65) ; for noids , replace this with moveto() in kneel,will change dis as soon as it detect s1
   	Local $lBlocked = 0
	Local $lMe
	Local $lMapLoading = GetMapLoading(), $lMapLoadingOld
	Local $lDestX = $aX + Random(-$aRandom, $aRandom)
	Local $lDestY = $aY + Random(-$aRandom, $aRandom)
    $notalone  = False
	Move($lDestX, $lDestY, 0)

	Do
		Sleep(100)
		$lMe = GetAgentByID(-2)

		If DllStructGetData($lMe, 'HP') <= 0 Then ExitLoop

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetMapLoading()
		If $lMapLoading <> $lMapLoadingOld Then ExitLoop

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			$lDestX = $aX + Random(-$aRandom, $aRandom)
			$lDestY = $aY + Random(-$aRandom, $aRandom)
			Move($lDestX, $lDestY, 0)
		 EndIf
	    if not isdisempty() Then
		   enterfow()
		 EndIf
	  Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < 100 Or $lBlocked > 14

EndFunc

 func kneel($one,$two)
   $Avatar = GetNearestNPCToCoords($one,$two)	;
   local $FailPops = 0
   $spawned = False
  if not $spawned Then
	   MoveRandom()
	   ;moveto($one,$two)
  If DllStructGetData($Avatar, "PlayerNumber") <> $champion Then
    if $ensuresafety Then
	 if not isdisempty() Then
		  enterfow()
	   EndIf
	  EndIf
	   if getmapid() <> $town then Return
		Out("kneeling")
		;SendChat("kneel", "/")
		Local $lDeadlock = TimerInit()
		Do
		   if getmapid() <> $town then Return
			Sleep(1500)	; .
			$Avatar = GetNearestNPCToCoords($one,$two)

			If TimerDiff($lDeadlock) > 5000 Then
				moveto($one,$two)
				SendChat("kneel", "/")
				$lDeadlock = TimerInit()
				$FailPops += 1
			 EndIf
		 Until DllStructGetData($Avatar, "PlayerNumber") == $champion  or $FailPops = 2;
	 EndIf

	  if $FailPops > 2 Then
		 	$spawned = False
		 if $town = $toa Then
			$town = $toa
		 else
			$town = $toa
		 EndIf
			enterfow()
		 Else
			$spawned = True
		 endif
       EndIf
  if getmapid() <> $town then Return
    if  $spawned  then
	  Out("entering fow")
	  Sleep(2500)
	  GoNearestNPCToCoords(-2429.00,18753.00)
	  Sleep(500)
	  Dialog(0x85)
	  Sleep(400)
	  DIALOG(0x86)
	  Sleep(100)
   endIf
 EndFunc

func isdisempty()
   local  $peoplecount = -1
   $lAgentArray = GetAgentArray()
   For $i = 1 To $lAgentArray[0]
	  $aAgent = $lAgentArray[$i]
	  if isagenthuman($aagent) Then
		$peoplecount += 1
	  EndIf
   Next
   if $peoplecount > 0 Then

	  if $town = $chantry then
		 out("dis not empty, going toa")
	     $town = $toa
	  Else
		 out("dis not empty, going  chaantry")
		 $town = $chantry
	  EndIf
   	   Return False
	Else
	   out("dis empty")
	  return True
   EndIf

EndFunc

func isagenthuman($aagent)
    if DllStructGetData($aagent,'Allegiance') <> 1 then Return
	$thename = GetPlayerName($aAgent)
	if $thename = "" then Return
    Return True
EndFunc

 Func RndTravel($aMapID)
   	Local $UseDistricts = 11 ; 7=eu-only, 8=eu+int, 11=all(excluding America)
	; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, us-en, int, asia-ko, asia-ch, asia-ja
	Local $Region[11] = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
	Local $Language[11] = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]
	Local $Random = Random(0, $UseDistricts - 1, 1)
	MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
	waitmaploading($amapid)
EndFunc   ;==>RndTravel
Func useitembymodelid($amodelid)
	Local $lItem
	For $lbag = 1 To 4
		For $lslot = 1 To $bag_slots[$lbag]
			$lItem = getitembyslot($lbag, $lslot)
			If DllStructGetData($lItem, "ModelID") == $amodelid Then Return sendpacket(8, $HEADER_ITEM_USE, DllStructGetData($lItem, "ID"))
		Next
	Next
	Return False
EndFunc   ;==>useitembymodelid
#EndRegion funcs
While Not $BotRunning
	Sleep(100)
WEnd

;While 1
	;Sleep(50)
	;clearmemory()
	;enterfow()
	;loop()
;WEnd

Func IsRecharged($lSkill)
	Return GetSkillbarSkillRecharge($lSkill) == 0
EndFunc   ;==>IsRecharged

While Not $BotRunning
	Sleep(100)
WEnd

Func GoNearestNPCToCoords($x, $y)
	Do
		RndSleep(250)
		$guy = GetNearestNPCToCoords($x, $y)
	Until DllStructGetData($guy, 'Id') <> 0
	ChangeTarget($guy)
	RndSleep(250)
	Move(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'))
	GoNPC($guy)
	RndSleep(250)
	Do
		RndSleep(750)
		Move(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'))
		GoNPC($guy)
		RndSleep(250)
		$Me = GetAgentByID(-2)
	Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
	RndSleep(1000)
EndFunc

Func CheckGold()

	Out("Checking if you have 1000 Gold")
	If GetGoldCharacter() < 1000 And GetGoldStorage() > 1000 Then
		Out("Grabbing Gold")
		RndSleep(250)
		WithdrawGold(1000)
		RndSleep(250)
	 EndIf
  EndFunc

Func MoveRandom()
   Out("Random Movement")
   Switch (Random(1, 20, 1))    ;<<<<<<<<<<<<<<<<<<<<<<<< NOTICE:  MAKE SURE TO CHANGE THIS TO THE NUMBER OF RANDOM PATHS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
   Case 1
	     Out("Random Move-1")
		 MoveTo(-3921, 17481, 100)
	  Case 2
		 Out("Random Move-2")
		 MoveTo(-3872, 17407, 100)
	  Case 3
		 Out("Random Move-3")
		 MoveTo(-4030, 17267, 100)
	  Case 4
		 Out("Random Move-4")
		 MoveTo(-4318, 17257, 100)
	  Case 5
		 Out("Random Move-5")
		 MoveTo(-4517, 17140, 100)
		 MoveTo(-3298, 17703, 100)
	  Case 6
		 Out("Random Move-6")
		 MoveTo(-3604, 17680, 100)
	  Case 7
		 Out("Random Move-7")
		 MoveTo(-3110, 17908, 100)
	  Case 8
		 Out("Random Move-8")
		 MoveTo(-3041, 18051, 100)
	  Case 9
		 Out("Random Move-9")
		 MoveTo(-2958, 18041, 100)
	  Case 10
	     Out("Random Move-10")
		 MoveTo(-3349, 17643, 100)
	  Case 11
	     Out("Random Move-11")
		 MoveTo(-4217, 16914, 100)
	  Case 12
		 Out("Random Move-12")
		 MoveTo(-4210, 17072, 100)
		 MoveTo(-3729, 17264, 100)
	  Case 13
	     Out("Random Move-13")
		 MoveTo(-4776, 17714, 100)
		 MoveTo(-2989, 18115, 100)
	  Case 14
	     Out("Random Move-14")
		 MoveTo(-4207, 17233, 100)
		 Sleep(GetPing()+250)
		 MoveTo(-3316, 17795, 100)
	  Case 15
	     Out("Random Move-15")
		 MoveTo(-5347, 18281, 100)
		 Sleep(GetPing()+350)
		 MoveTo(-4764, 18646, 100)
		 Sleep(GetPing()+350)
		 MoveTo(-3655, 17592, 100)
		 MoveTo(-3050, 17958, 100)
	  Case 16
	     Out("Random Move-16")
		 MoveTo(-3724, 17171, 100)
		 Sleep(GetPing()+350)
	  Case 17
	     Out("Random Move-17")
		 MoveTo(-5063, 19388, 100)
		 Sleep(GetPing()+5550)
		 MoveTo(-3902, 17738, 100)
		 Sleep(GetPing()+350)
		 MoveTo(-3757, 17694, 100)
		 MoveTo(-3614, 17697, 100)
		 MoveTo(-3614, 17697, 100)
		 MoveTo(-3400, 17779, 100)
	  Case 18
	     Out("Random Move-18")
		 MoveTo(-4667, 17195, 100)
		 MoveTo(-4667, 17195, 100)
		 MoveTo(-3935, 17277, 100)
	  Case 19
	     Out("Random Move-19")
		 MoveTo(-4110, 17172, 100)
		 ReverseDirection()
		 Sleep(GetPing()+1550)
		 ReverseDirection()
		 Sleep(GetPing()+1550)
		 MoveTo(-3471, 17634, 100)
	  Case 20
	     Out("Random Move-20")
		 MoveTo(-4601, 17762, 100)
		 Sleep(GetPing()+1550)
		 ReverseDirection()
		 Sleep(GetPing+1550)
		 ReverseDirection()
		 MoveTo(-4196, 17809, 100)
		 MoveTo(-3476, 17772, 100)
	EndSwitch
EndFunc   ;Move to 1 of 20 random spots
