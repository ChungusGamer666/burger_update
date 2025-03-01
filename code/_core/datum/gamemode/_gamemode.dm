/gamemode/
	var/name = "Gamemode Name"
	var/desc = "Gamemode Description"

	var/list/objective/crew_active_objectives = list()
	var/list/objective/crew_completed_objectives = list()
	var/list/objective/crew_failed_objectives = list()

	var/list/objective/antagonist_active_objectives = list()
	var/list/objective/antagonist_completed_objectives = list()
	var/list/objective/antagonist_failed_objectives = list()

	var/allow_launch = FALSE

	var/state = GAMEMODE_PRELOAD

	var/objective_text = "No objectives listed."

	var/next_objective_update = 0

	var/round_time = 0 //In seconds.
	var/round_time_next = 120 //In seconds.

	var/hidden = FALSE //Set to true if this gamemode shouldn't show up in voting.

	var/points = 50
	//0 means failure.
	var/alert_level = CODE_GREEN

	var/initialized = FALSE
	var/generated = FALSE
	var/finalized = FALSE

	var/horde_data/gamemode_horde_data

	var/allow_continue = TRUE

/gamemode/proc/Initialize()
	if(initialized)
		CRASH("WARNING: [src.get_debug_name()] was initialized twice!")
		return TRUE
	return TRUE

/gamemode/proc/PostInitialize()
	return TRUE

/gamemode/proc/Generate() //Generate the atom, giving it stuff if needed.
	if(generated)
		CRASH("WARNING: [src.get_debug_name()] was generated twice!")
		return TRUE
	return TRUE

/gamemode/proc/Finalize() //We're good to go.
	if(finalized)
		CRASH("WARNING: [src.get_debug_name()] was finalized twice!")
		return TRUE
	return TRUE

/gamemode/PreDestroy()

	QDEL_CUT(crew_active_objectives)
	QDEL_CUT(crew_completed_objectives)
	QDEL_CUT(crew_failed_objectives)

	QDEL_CUT(antagonist_active_objectives)
	QDEL_CUT(antagonist_completed_objectives)
	QDEL_CUT(antagonist_failed_objectives)

	return ..()

/gamemode/New()
	state = GAMEMODE_WAITING
	if(SSevents) //Go through all the events and remove them if needed. I know this is shitcode and I need to combine SSgamemode with SSevent so events initialize after the gamemode is picked.
		for(var/k in SSevents.all_events)
			var/event/E = SSevents.all_events[k]
			if(E.gamemode_blacklist[src.type])
				SSevents.all_events -= E.type
				qdel(E)
	return TRUE

/gamemode/proc/handle_alert_level()
	var/desired_alert_level = CODE_GREEN //Failsafe.
	switch(points)
		if(-INFINITY to 15)
			desired_alert_level = CODE_RED
		if(15 to 25)
			desired_alert_level = CODE_AMBER
		if(25 to 50)
			desired_alert_level = CODE_BLUE
		if(50 to INFINITY)
			desired_alert_level = CODE_GREEN

	if(desired_alert_level > alert_level)
		alert_level = desired_alert_level
		switch(alert_level)
			if(CODE_BLUE)
				CALLBACK_GLOBAL(\
					"gamemode_announce_code",\
					SECONDS_TO_DECISECONDS(10),\
					.proc/announce,\
					"Station Alert System",\
					"Alert Level Increased",\
					"Attention. Condition Blue set throughout the station. Exercise Term: Fade Out.",\
					ANNOUNCEMENT_STATION,\
					'sound/voice/announcement/code_blue.ogg'\
				)
			if(CODE_AMBER)
				CALLBACK_GLOBAL(
					"gamemode_announce_code",\
					SECONDS_TO_DECISECONDS(10),\
					.proc/announce,\
					"Station Alert System",\
					"Alert Level Increased",\
					"Attention. Condition Amber set throughout the station. Exercise Term: Double Take. Additional Enemy Reinforcements detected in route to Area of Operations.",\
					ANNOUNCEMENT_STATION,\
					'sound/voice/announcement/code_amber.ogg'\
				)
			if(CODE_RED)
				CALLBACK_GLOBAL(\
					"gamemode_announce_code",\
					SECONDS_TO_DECISECONDS(10),\
					.proc/announce,\
					"Station Alert System",\
					"Alert Level Increased",\
					"Warning. Warning. Condition Red set throughout the station. Exercise Term: Fast Pace. All personnel to prepare for potential borders on station..",\
					ANNOUNCEMENT_STATION,\
					'sound/voice/announcement/code_red.ogg'\
				)
			if(CODE_DELTA)
				CALLBACK_GLOBAL(\
					"gamemode_announce_code",\
					SECONDS_TO_DECISECONDS(10),\
					.proc/announce,\
					"Station Alert System",\
					"Alert Level Increased",\
					"Warning. Warning. Condition Delta set throughout the station. Exercise Term: Cocked Pistol. Nuclear Strike is imminent. All personnel are ordered to evacuate the Area of Operations.",\
					ANNOUNCEMENT_STATION,\
					'sound/voice/announcement/code_delta.ogg'\
				)

/gamemode/proc/on_life()

	if(next_objective_update > 0 && next_objective_update <= world.time)
		update_objectives()

	round_time++

	return TRUE

/gamemode/proc/on_end()
	state = GAMEMODE_BREAK
	return TRUE

/gamemode/proc/on_continue() //What to do when this gamemode continues via a vote.
	state = GAMEMODE_FIGHTING
	return TRUE

/gamemode/proc/can_continue()
	//Can we even continue?
	return TRUE

/gamemode/proc/on_object_sold(var/atom/movable/M)

	for(var/k in crew_active_objectives)
		var/objective/O = k
		if(!O.track_cargo)
			continue
		O.on_object_sold(M)

	return TRUE




/gamemode/proc/add_objective(var/objective/O)
	O = new O

	if(O.completion_state == IMPOSSIBLE)
		qdel(O)

	if(!O || O.qdeleting)
		log_error("Could not add objective [O.type].")
		return FALSE
	next_objective_update = world.time + 10
	O.update()
	return TRUE

/gamemode/proc/update_objectives()

	objective_text = ""

	var/has_new = FALSE

	for(var/k in crew_active_objectives)
		var/objective/O = k
		objective_text += "[O.desc] (ACTIVE)[O.is_new ? div("good bold"," (NEW)") : ""]<br>"
		if(O.is_new) has_new = TRUE
		O.is_new = FALSE

	for(var/k in crew_completed_objectives)
		var/objective/O = k
		objective_text += "[O.desc] (COMPLETED)[O.is_new ? div("good bold"," (NEW)") : ""]<br>"
		if(O.is_new) has_new = TRUE
		O.is_new = FALSE

	for(var/k in crew_failed_objectives)
		var/objective/O = k
		objective_text += "[O.desc] (FAILED)[O.is_new ? div("good bold"," (NEW)") : ""]<br>"
		if(O.is_new) has_new = TRUE
		O.is_new = FALSE

	announce(
		"Central Command Mission Update",
		has_new ? "New Objectives Added" : "Objectives Updated",
		objective_text,
		sound_to_play = 'sound/alert/airplane.ogg')

	for(var/k in all_mobs_with_clients)
		var/mob/M = k
		M.client.update_statpanel = TRUE


	next_objective_update = -1

	return TRUE