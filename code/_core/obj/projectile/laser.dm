/obj/projectile/bullet/laser/
	name = "laser"
	id = "laser"
	icon = 'icons/obj/projectiles/laser.dmi'
	icon_state = "laser"

	impact_effect_turf = /obj/effect/temp/impact/bullet/laser

/obj/projectile/bullet/laser/update_icon()

	var/icon/I = new/icon(initial(icon),initial(icon_state))
	I.Blend(bullet_color,ICON_MULTIPLY)

	var/icon/I2 = new/icon(initial(icon),"core")
	I.Blend(I2,ICON_OVERLAY)

	icon = I

	return ..()

/* Real x-ray rifles would be exceptionally overpowered and super exploitable.
/obj/projectile/bullet/laser/penetrating
	name = "penetrating laser"
	id = "laser_penetrating"
	var/penetrations_current = 0
	var/penetrations_max = 5

	collision_flags = FLAG_COLLISION_NONE

/obj/projectile/bullet/laser/penetrating/on_hit(var/atom/hit_atom)

	if(hit_atom != target_atom && is_living(hit_atom))
		var/mob/living/L = hit_atom
		if(L.status & FLAG_STATUS_DEAD || L.status & FLAG_STATUS_STUN)
			return FALSE

	if(damage_type)
		var/damagetype/DT = all_damage_types[damage_type]

		if(!DT)
			return ..()

		var/list/params = list()
		params["icon-x"] = shoot_x
		params["icon-y"] = shoot_y

		var/atom/object_to_damage = hit_atom.get_object_to_damage(owner,hit_atom,params)
		var/can_attack = DT.can_attack(owner,hit_atom,weapon,object_to_damage)

		if(!can_attack)
			return FALSE

		if(hit_atom.perform_block(owner,weapon,object_to_damage,DT)) return TRUE
		if(hit_atom.perform_dodge(owner,weapon,object_to_damage,DT)) return FALSE
		if(DT.perform_miss(owner,weapon,object_to_damage)) return FALSE

		DT.do_damage(owner,hit_atom,weapon,object_to_damage)

	penetrations_current += 1

	if(penetrations_current > penetrations_max)
		all_projectiles -= src
		post_on_hit(hit_atom)
		qdel(src)
		return TRUE

	return FALSE
*/