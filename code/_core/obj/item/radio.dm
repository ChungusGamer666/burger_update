/obj/item/radio
	name = "radio"
	desc = "It's a radio"
	icon = 'icons/obj/item/radio.dmi'
	icon_state = "inventory"

	var/obj/item/device/radio/stored_radio = /obj/item/device/radio/headset/nanotrasen

	value = 20

	weight = 1

/obj/item/radio/PreDestroy()
	QDEL_NULL(stored_radio)
	. = ..()

/obj/item/radio/Generate()
	stored_radio = new stored_radio(src)
	INITIALIZE(stored_radio)
	GENERATE(stored_radio)
	FINALIZE(stored_radio)
	return ..()

/obj/item/radio/click_self(var/mob/caller,location,control,params)
	return stored_radio.click_self(caller,location,control,params)

/obj/item/radio/clicked_on_by_object(var/mob/caller as mob,var/atom/object,location,control,params)
	return stored_radio.clicked_on_by_object(caller,object,location,control,params)

/obj/item/radio/mouse_wheel_on_object(var/mob/caller,delta_x,delta_y,location,control,params)
	return stored_radio.mouse_wheel_on_object(caller,delta_x,delta_y,location,control,params)

/obj/item/radio/trigger(var/mob/caller,var/atom/source,var/signal_freq,var/signal_code)
	return stored_radio.trigger(caller,source,signal_freq,signal_code)

/obj/item/radio/save_item_data(var/mob/living/advanced/player/P,var/save_inventory = TRUE,var/died=FALSE,var/loadout=FALSE)
	RUN_PARENT_SAFE
	SAVEATOM("stored_radio")

/obj/item/radio/load_item_data_pre(var/mob/living/advanced/player/P,var/list/object_data,var/loadout=FALSE)
	RUN_PARENT_SAFE
	LOADATOM("stored_radio")
