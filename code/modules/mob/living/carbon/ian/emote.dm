/mob/living/carbon/ian/emote(act, m_type = SHOWMSG_AUDIO, message = null, auto)
	if(src.stat == DEAD && (act != "deathgasp"))
		return

	switch(act)
		if("me")
			if(silent)
				return
			if(client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='red'>Вы не можете отправлять IC-сообщения (muted).</span>")
					return
				if(client.handle_spam_prevention(message,MUTE_IC))
					return
			if(stat || !message)
				return
			return custom_emote(m_type, message)

		if ("blink")
			message = "<B>[src]</B> [pick("моргает", "быстро моргает")]."
			m_type = SHOWMSG_VISUAL
		if("custom")
			return custom_emote(m_type, message)
		if("scratch")
			if(!restrained())
				message = "<B>[src]</B> чешется."
				m_type = SHOWMSG_VISUAL
		if("whimper")
			message = "<B>[src]</B> скулит."
			m_type = SHOWMSG_AUDIO
		if("roar")
			message = "<B>[src]</B> рычит."
			m_type = SHOWMSG_AUDIO
		if("tail")
			message = "<B>[src]</B> машет хвостом."
			m_type = SHOWMSG_VISUAL
		if("gasp")
			message = "<B>[src]</B> тяжело дышит."
			m_type = SHOWMSG_AUDIO
		if("shiver")
			message = "<B>[src]</B> дрожит."
			m_type = SHOWMSG_AUDIO
		if("drool")
			message = "<B>[src]</B> пускает слюни."
			m_type = SHOWMSG_VISUAL
		if ("eyebrow")
			message = "<B>[src]</B> поднимает бровь."
			m_type = SHOWMSG_VISUAL
		if("paw")
			if(!restrained())
				message = "<B>[src]</B> машет лапой."
				m_type = SHOWMSG_VISUAL
		if("choke")
			message = "<B>[src]</B> задыхается."
			m_type = SHOWMSG_AUDIO
		if("moan")
			message = "<B>[src]</B> стонет!"
			m_type = SHOWMSG_AUDIO
		if("nod")
			message = "<B>[src]</B> кивает."
			m_type = SHOWMSG_VISUAL
		if("sit")
			message = "<B>[src]</B> садится."
			m_type = SHOWMSG_VISUAL
		if("sway")
			message = "<B>[src]</B> качается."
			m_type = SHOWMSG_VISUAL
		if("sulk")
			message = "<B>[src]</B> печально дуется."
			m_type = SHOWMSG_VISUAL
		if("twitch")
			message = "<B>[src]</B> [pick("сильно трясется", "дергается")]."
			m_type = SHOWMSG_VISUAL
		if ("faint")
			message = "<B>[src]</B> падает в обморок."
			if(IsSleeping())
				return
			SetSleeping(20 SECONDS)
			m_type = SHOWMSG_VISUAL
		if("dance")
			if(!restrained())
				message = "<B>[src]</B> [pick("пляшет", "гоняется за хвостом")]."
				m_type = SHOWMSG_VISUAL
		if("roll")
			if(!restrained())
				message = "<B>[src]</B> катается по полу."
				m_type = SHOWMSG_VISUAL
		if("shake")
			message = "<B>[src]</B> трясет головой."
			m_type = SHOWMSG_VISUAL
		if("gnarl")
			message = "<B>[src]</B> злится и оскаливает зубы."
			m_type = SHOWMSG_AUDIO
		if("jump")
			message = "<B>[src]</B> прыгает!"
			m_type = SHOWMSG_VISUAL
		if("collapse")
			Paralyse(2)
			message = "<B>[src]</B> в припадке!"
			m_type = SHOWMSG_AUDIO
		if("deathgasp")
			message = "<B>[src]</B> замерев, безвольно падает и умирает..."
			m_type = SHOWMSG_VISUAL
		if("cough")
			message = "<B>[src]</B> кашляет!"
			m_type = SHOWMSG_AUDIO
		if ("pray")
			m_type = SHOWMSG_VISUAL
			message = "<b>[src]</b> молится."
			INVOKE_ASYNC(src, /mob.proc/pray_animation)
		if("help")
			to_chat(src, "blink, blink_r, choke, collapse, cough, eyebrow, faint, dance, deathgasp, drool, gasp, shiver, gnarl, jump, point, paw, moan, nod,\nroar, roll, scratch, shake, sit, sulk, sway, tail, twitch, twitch_s, whimper")
		else
			to_chat(src, "Неправильная эмоция: [act]")

	if(message)
		if(client)
			log_emote("[key_name(src)] : [message]")

		for(var/mob/M in observer_list)
			if(!M.client)
				continue //skip leavers
			if((M.client.prefs.chat_ghostsight != CHAT_GHOSTSIGHT_NEARBYMOBS) && !(M in viewers(src, null)))
				to_chat(M, "[FOLLOW_LINK(M, src)] [message]") // ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here

		if (m_type & SHOWMSG_VISUAL)
			for (var/mob/O in get_mobs_in_view(world.view,src))
				O.show_message(message, m_type)
		else if (m_type & SHOWMSG_AUDIO)
			for (var/mob/O in (hearers(src.loc, null) | get_mobs_in_view(world.view,src)))
				O.show_message(message, m_type)
