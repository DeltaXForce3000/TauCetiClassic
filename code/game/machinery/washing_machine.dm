/obj/machinery/washing_machine
	name = "Washing Machine"
	desc = "Washes your bloody clothes."
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	var/state = 1
	//1 = empty, open door
	//2 = empty, closed door
	//3 = full, open door
	//4 = full, closed door
	//5 = running
	//6 = blood, open door
	//7 = blood, closed door
	//8 = blood, running
	var/panel = 0
	//0 = closed
	//1 = open
	var/hacked = 1 //Bleh, screw hacking, let's have it hacked by default.
	//0 = not hacked
	//1 = hacked
	var/gibs_ready = 0
	var/obj/crayon

/obj/machinery/washing_machine/verb/start()
	set name = "Start Washing"
	set category = "Object"
	set src in oview(1)

	if(!istype(usr, /mob/living)) //ew ew ew usr, but it's the only way to check.
		return

	if( state != 4 )
		to_chat(usr, "The washing machine cannot run in this state.")
		return

	if( locate(/mob,contents) )
		state = 8
	else
		state = 5
	update_icon()
	playsound(src, 'sound/items/washingmachine.ogg', VOL_EFFECTS_MASTER)
	sleep(210)
	for(var/atom/A in contents)
		A.clean_blood()

	for(var/obj/item/I in contents)
		I.decontaminate()
		I.wet = 0

	//Tanning!
	for(var/obj/item/stack/sheet/hairlesshide/HH in contents)
		new/obj/item/stack/sheet/wetleather(src, HH.get_amount())
		qdel(HH)


	if(crayon)
		var/wash_color
		if(istype(crayon,/obj/item/toy/crayon))
			var/obj/item/toy/crayon/CR = crayon
			wash_color = CR.colourName
		else if(istype(crayon,/obj/item/weapon/stamp))
			var/obj/item/weapon/stamp/ST = crayon
			wash_color = ST.item_color

		if(wash_color)
			var/new_jumpsuit_icon_state = ""
			var/new_jumpsuit_item_state = ""
			var/new_jumpsuit_name = ""
			var/new_glove_fingerless_item_state = ""
			var/new_glove_fingerless_icon_state = ""
			var/new_glove_fingerless_name = ""
			var/new_glove_item_state = ""
			var/new_glove_icon_state = ""
			var/new_glove_name = ""
			var/new_shoe_icon_state = ""
			var/new_shoe_name = ""
			var/new_sheet_icon_state = ""
			var/new_sheet_name = ""
			var/new_softcap_icon_state = ""
			var/new_softcap_name = ""
			var/new_desc = "The colors are a bit dodgy."
			/*
				ADD /proc/machine_wash TO CLOTHING AND REMOVE THIS SPAGHETTI HELL WE HAVE BEEN DOOMED TO.
			*/
			for(var/T in typesof(/obj/item/clothing/under))
				var/obj/item/clothing/under/J = new T
				//world << "DEBUG: [color] == [J.color]"
				if(wash_color == J.item_color)
					new_jumpsuit_icon_state = J.icon_state
					new_jumpsuit_item_state = J.item_state
					new_jumpsuit_name = J.name
					qdel(J)
					//world << "DEBUG: YUP! [new_icon_state] and [new_item_state]"
					break
				qdel(J)
			for(var/T in typesof(/obj/item/clothing/gloves/fingerless))
				var/obj/item/clothing/gloves/fingerless/G = new T
				if(wash_color == G.item_color)
					new_glove_fingerless_icon_state = G.icon_state
					new_glove_fingerless_item_state = G.item_state
					new_glove_fingerless_name = G.name
					qdel(G)
					break
				qdel(G)
			for(var/T in typesof(/obj/item/clothing/gloves))
				var/obj/item/clothing/gloves/G = new T
				if(wash_color == G.item_color)
					new_glove_icon_state = G.icon_state
					new_glove_item_state = G.item_state
					new_glove_name = G.name
					qdel(G)
					break
				qdel(G)
			for(var/T in typesof(/obj/item/clothing/shoes))
				var/obj/item/clothing/shoes/S = new T
				//world << "DEBUG: [color] == [J.color]"
				if(wash_color == S.item_color)
					new_shoe_icon_state = S.icon_state
					new_shoe_name = S.name
					qdel(S)
					//world << "DEBUG: YUP! [new_icon_state] and [new_item_state]"
					break
				qdel(S)
			for(var/T in typesof(/obj/item/weapon/bedsheet))
				var/obj/item/weapon/bedsheet/B = new T
				//world << "DEBUG: [color] == [J.color]"
				if(wash_color == B.item_color)
					new_sheet_icon_state = B.icon_state
					new_sheet_name = B.name
					qdel(B)
					//world << "DEBUG: YUP! [new_icon_state] and [new_item_state]"
					break
				qdel(B)
			for(var/T in typesof(/obj/item/clothing/head/soft))
				var/obj/item/clothing/head/soft/H = new T
				//world << "DEBUG: [color] == [J.color]"
				if(wash_color == H.item_color)
					new_softcap_icon_state = H.icon_state
					new_softcap_name = H.name
					qdel(H)
					//world << "DEBUG: YUP! [new_icon_state] and [new_item_state]"
					break
				qdel(H)
			if(new_jumpsuit_icon_state && new_jumpsuit_item_state && new_jumpsuit_name)
				for(var/obj/item/clothing/under/J in contents)
					//world << "DEBUG: YUP! FOUND IT!"
					J.item_state = new_jumpsuit_item_state
					J.icon_state = new_jumpsuit_icon_state
					J.item_color = wash_color
					J.name = new_jumpsuit_name
					J.desc = new_desc
			if(new_glove_name && new_glove_item_state && new_glove_icon_state||new_glove_fingerless_name && new_glove_fingerless_item_state && new_glove_fingerless_icon_state)
				for(var/obj/item/clothing/gloves/G in contents)
					if(istype(G, /obj/item/clothing/gloves/fingerless))
						if(new_glove_fingerless_name && new_glove_fingerless_item_state && new_glove_fingerless_icon_state)
							G.item_state = new_glove_fingerless_item_state
							G.icon_state = new_glove_fingerless_icon_state
							G.item_color = wash_color
							G.name = new_glove_fingerless_name
							G.desc = new_desc
					else
						if (new_glove_name && new_glove_item_state && new_glove_icon_state)
							G.item_state = new_glove_item_state
							G.icon_state = new_glove_icon_state
							G.item_color = wash_color
							G.name = new_glove_name
							G.desc = new_desc
			if(new_shoe_icon_state && new_shoe_name)
				for(var/obj/item/clothing/shoes/S in contents)
					//world << "DEBUG: YUP! FOUND IT!"
					if (istype(S,/obj/item/clothing/shoes/orange))
						var/obj/item/clothing/shoes/orange/L = S
						if (L.chained)
							L.remove_cuffs()
					if(new_shoe_icon_state == "orange1")
						new_shoe_icon_state = "orange"
					if(new_shoe_name == "shackles")
						new_shoe_name = "orange shoes"
					if(S.item_state == "o_shoes1")
						S.item_state = "o_shoes"
					S.icon_state = new_shoe_icon_state
					S.item_color = wash_color
					S.name = new_shoe_name
					S.desc = new_desc
			if(new_sheet_icon_state && new_sheet_name)
				for(var/obj/item/weapon/bedsheet/B in contents)
					//world << "DEBUG: YUP! FOUND IT!"
					B.icon_state = new_sheet_icon_state
					B.item_color = wash_color
					B.name = new_sheet_name
					B.desc = new_desc
			if(new_softcap_icon_state && new_softcap_name)
				for(var/obj/item/clothing/head/soft/H in contents)
					//world << "DEBUG: YUP! FOUND IT!"
					H.icon_state = new_softcap_icon_state
					H.item_color = wash_color
					H.name = new_softcap_name
					H.desc = new_desc
		qdel(crayon)
		crayon = null

	for(var/obj/item/clothing/under/U in contents)
		U.fresh_laundered_until = world.time + 5 MINUTES

	if( locate(/mob,contents) )
		state = 7
		gibs_ready = 1
	else
		state = 4
	update_icon()

/obj/machinery/washing_machine/verb/climb_out()
	set name = "Climb out"
	set category = "Object"
	set src in usr.loc

	sleep(20)
	if(state in list(1,3,6) )
		usr.loc = src.loc


/obj/machinery/washing_machine/update_icon()
	icon_state = "wm_[state][panel]"

/obj/machinery/washing_machine/attackby(obj/item/weapon/W, mob/user)
	/*if(isscrewdriver(W))
		panel = !panel
		to_chat(user, "<span class='notice'>you [panel ? </span>"open" : "close"] the [src]'s maintenance panel")*/
	if(istype(W,/obj/item/toy/crayon) ||istype(W,/obj/item/weapon/stamp))
		if( state in list(	1, 3, 6 ) )
			if(!crayon)
				user.drop_from_inventory(W, src)
				crayon = W
			else
				..()
		else
			..()
	else if(istype(W,/obj/item/weapon/grab))
		if( (state == 1) && hacked)
			var/obj/item/weapon/grab/G = W
			if(ishuman(G.assailant) && (iscorgi(G.affecting) || isIAN(G.affecting)))
				G.affecting.loc = src
				qdel(G)
				state = 3
		else
			..()
	else if(istype(W,/obj/item/stack/sheet/hairlesshide) || \
		istype(W,/obj/item/clothing/under) || \
		istype(W,/obj/item/clothing/mask) || \
		istype(W,/obj/item/clothing/head) || \
		istype(W,/obj/item/clothing/gloves) || \
		istype(W,/obj/item/clothing/shoes) || \
		istype(W,/obj/item/clothing/suit) || \
		istype(W,/obj/item/weapon/bedsheet))

		//YES, it's hardcoded... saves a var/can_be_washed for every single clothing item.
		if ( istype(W,/obj/item/clothing/suit/space ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/syndicatefake ) )
			to_chat(user, "This item does not fit.")
			return
//		if ( istype(W,/obj/item/clothing/suit/powered ) )
//			user << "This item does not fit."
//			return
		if ( istype(W,/obj/item/clothing/suit/cyborg_suit ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/bomb_suit ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/armor ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/armor ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/mask/gas ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/mask/cigarette ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/head/syndicatefake ) )
			to_chat(user, "This item does not fit.")
			return
//		if ( istype(W,/obj/item/clothing/head/powered ) )
//			user << "This item does not fit."
//			return
		if ( istype(W,/obj/item/clothing/head/helmet ) )
			to_chat(user, "This item does not fit.")
			return
		if (istype(W, /obj/item/clothing/gloves/pipboy))
			to_chat(user, "This item does not fit.")
			return
		if(!W.canremove) //if "can't drop" item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in the washing machine!</span>")
			return

		if(contents.len < 5)
			if ( state in list(1, 3) )
				user.drop_from_inventory(W, src)
				state = 3
			else
				to_chat(user, "<span class='notice'>You can't put the item in right now.</span>")
		else
			to_chat(user, "<span class='notice'>The washing machine is full.</span>")
	else
		..()
	update_icon()

/obj/machinery/washing_machine/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()

/obj/machinery/washing_machine/attack_hand(mob/user)
	if(..())
		return 1
	user.SetNextMove(CLICK_CD_RAPID)
	switch(state)
		if(1)
			state = 2
		if(2)
			state = 1
			for(var/atom/movable/O in contents)
				O.loc = src.loc
		if(3)
			state = 4
		if(4)
			state = 3
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1
		if(5)
			to_chat(user, "<span class='warning'>The [src] is busy.</span>")
		if(6)
			state = 7
		if(7)
			if(gibs_ready)
				gibs_ready = 0
				if(locate(/mob,contents))
					var/mob/M = locate(/mob,contents)
					M.gib()
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1

	update_icon()
