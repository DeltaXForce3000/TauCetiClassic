/obj/item/weapon/gun/projectile/revolver/rocketlauncher
	name = "Goliath missile launcher"
	desc = "The Goliath is a single-shot shoulder-fired multipurpose missile launcher."
	icon_state = "rocket"
	item_state = "rocket"
	w_class = SIZE_NORMAL
	force = 5
	flags =  CONDUCT
	origin_tech = "combat=8;materials=5"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rocket
	wielded = FALSE
	can_be_holstered = FALSE
	istwohanded = TRUE
	fire_sound = 'sound/effects/bang.ogg'

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/atom_init()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	AddComponent(/datum/component/twohanded)

/// triggered on wield of two handed item
/obj/item/weapon/gun/projectile/revolver/rocketlauncher/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/weapon/gun/projectile/revolver/rocketlauncher/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = FALSE

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/MouseDrop(obj/over_object)
	. = ..()
	if (ishuman(usr) || ismonkey(usr))
		var/mob/M = usr
		//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
		if (loc != usr)
			return
		if (!over_object)
			return

		if (!usr.incapacitated())
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
			add_fingerprint(usr)

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/process_chamber()
	return ..(1, 1)

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/attack_hand(mob/user)
	if(loc != user)
		..()
		return	//let them pick it up
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class = 'notice'>You unload [num_unloaded] missile\s from [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/afterattack(atom/target, mob/user, proximity, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(!wielded)
		to_chat(user, "<span class='notice'>You need wield [src] in both hands before firing!</span>")
		return
	else
		..()
		magazine.get_round(FALSE)

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/anti_singulo
	name = "XASL Mk.2 singularity buster"
	desc = "Experimental Anti-Singularity Launcher. In case of extreme emergency you should point it at super-massive blackhole expanding towards you."
	icon_state = "anti-singulo"
	item_state = "anti-singulo"
	slot_flags = SLOT_FLAGS_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rocket/anti_singulo
	fire_sound = 'sound/weapons/guns/gunpulse_emitter2.ogg'
	origin_tech = "combat=3;bluespace=6"
