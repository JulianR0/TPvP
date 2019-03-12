/*
*   _______     _      _  __          __
*  | _____/    | |    | | \ \   __   / /
*  | |         | |    | |  | | /  \ | |
*  | |         | |____| |  | |/ __ \| |
*  | |   ___   | ______ |  |   /  \   |
*  | |  |_  |  | |    | |  |  /    \  |
*  | |    | |  | |    | |  | |      | |
*  | |____| |  | |    | |  | |      | |
*  |_______/   |_|    |_|  \_/      \_/
*
*/

#define VERSION	"1.4e-n"

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define MAX_NOMINATED	20
#define MAX_TRIES	50

new configfile[200]

new menu[2000]
new keys

new g_teamScore[2]

new bool:voting
new votes[10]
new maps[9][32]

new num_nominated = 0
new nominated[MAX_NOMINATED][32]
new bool:has_nominated[33]

new mp_winlimit
new mp_maxrounds
new mp_timelimit

new extended_pcvar
new extendtime_pcvar
new lastmap_pcvar
new lastmap_was_pcvar
new lastlastmap_pcvar
new lastlastmap_was_pcvar
new showvotes_pcvar
new rtv_percent_pcvar
new rtv_wait_pcvar
new delay_time_pcvar
new delay_tally_time_pcvar

new extended

new cur_nextmap[32]

new cstrike
new bool:rtv[33]
new rtvtotal

new Float:voterocked
new bool:voterocked2

new num

new say_commands[][32] =
{
	"rockthevote",
	"rock the vote",
	"rtv",
	"/rockthevote",
	"/rock the vote",
	"/rtv"
}

new lastmap[32]
new lastlastmap[32]
new currentmap[32]

public plugin_init()
{
	register_plugin("Custom NextMap Chooser",VERSION,"GHW_Chronic + Giegue")

	get_configsdir(configfile,199)
	format(configfile,199,"%s/custom_nextmaps.ini",configfile)

	register_cvar("map_enabled","1")

	if(file_exists(configfile) && get_cvar_num("map_enabled"))
	{
		register_concmd("amx_nextmap_vote","cmd_nextmap",ADMIN_MAP,"Starts a vote for nextmap [1=allow extend(Default) | 0=Don't allow extend] [1=Change Now(Default) | 0=Change at End")

		register_clcmd("say nextmap","saynextmap")
		register_clcmd("say_team nextmap","saynextmap")

		register_clcmd("say","say_hook")
		register_clcmd("say_team","say_hook")

		cstrike = cstrike_running()
		if(cstrike) register_event("TeamScore", "team_score", "a")

		register_menucmd(register_menuid("CustomNextMap"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9),"VoteCount")

		set_task(15.0,"Check_Endround",1337,"",0,"b")
		set_task(1.0,"SaveMap")
		
		if(cstrike)
		{
			mp_winlimit = get_cvar_pointer("mp_winlimit")
			mp_maxrounds = get_cvar_pointer("mp_maxrounds")
		}
		mp_timelimit = get_cvar_pointer("mp_timelimit")

		extended_pcvar = register_cvar("map_extend_max","3")
		extendtime_pcvar = register_cvar("map_extend_time","5")
		lastmap_pcvar = register_cvar("map_lastmap_show","1")
		lastlastmap_pcvar = register_cvar("map_lastlastmap_show","1")
		showvotes_pcvar = register_cvar("map_show_votes","1")
		rtv_percent_pcvar = register_cvar("map_rtv_percent","50")
		rtv_wait_pcvar = register_cvar("map_rtv_wait","180")
		lastmap_was_pcvar = register_cvar("qq_lastmap","")
		lastlastmap_was_pcvar = register_cvar("qq_lastlastmap","")
		delay_time_pcvar = register_cvar("map_delay_time","6")
		delay_tally_time_pcvar = register_cvar("map_tally_delay_time","15")

		if(is_plugin_loaded("Nextmap Chooser")!=-1) pause("acd","mapchooser.amxx")
		if(!cvar_exists("amx_nextmap")) register_cvar("amx_nextmap","")

		get_pcvar_string(lastmap_was_pcvar,lastmap,31)
		get_pcvar_string(lastlastmap_was_pcvar,lastlastmap,31)
		get_mapname(currentmap,31)
	}
}

public SaveMap()
{
	new mapname[32], vaultkey[48], vaultdata[64], timestamp_now
	get_mapname(mapname,31)
	timestamp_now = get_systime()
	format(vaultkey, charsmax(vaultkey), "rtv-%s", mapname)
	format(vaultdata, charsmax(vaultdata), "%i", timestamp_now)
	set_vaultdata(vaultkey, vaultdata);
}

public client_disconnect(id)
{
	if(rtv[id])
	{
		rtv[id]=false
		has_nominated[id]=false
		rtvtotal--
	}
}

public cmd_nextmap(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}

	if(!voting)
	{
		num = get_pcvar_num(delay_time_pcvar)
		if(num<1) num=1

		new arg1[8] = "1"
		new arg2[8] = "1"
		if(read_argc()>=2)
		{
			read_argv(1,arg1,7)
			if(read_argc()>=3)
			{
				read_argv(2,arg2,7)
			}
		}

		client_print(0,print_chat,"[AMXX] An admin has started a nextmap vote! Vote starting in %d seconds.",num)

		if(str_to_num(arg2)) voterocked2=true
		else voterocked2=false
		make_menu(str_to_num(arg1))

	}
	else
	{
		client_print(id,print_chat,"[AMXX] There is already a nextmap vote in progress.")
	}
	return PLUGIN_HANDLED
}

public make_menu(add_extend)
{
	num = get_pcvar_num(delay_time_pcvar)
	if(num<1) num=1

	for(new i=0;i<10;i++) votes[i]=0
	for(new i=0;i<9;i++) format(maps[i],31,"")

	format(menu,1999,"^n")

	new Fsize = file_size(configfile,1)
	new read[32], trash, string[8]
	new numbers[17]

	for(new i=1;i<9;i++)
	{
		numbers[i]=0
		numbers[17-i]=0
		for(new i2=0;i2<Fsize;i2++)
		{
			read_file(configfile,i2,read,31,trash)
			format(string,7,"[%d]",i)
			if(equali(read,string)) numbers[i]=i2+1
				
			format(string,7,"[/%d]",i)
			if(equali(read,string)) numbers[17-i]=i2-1
		}
	}

	new tries
	keys = (1<<9)
	new j
	for(new i=1;i<9;i++)
	{
		format(maps[i],31,"")
		if(numbers[i] && numbers[17-i] && numbers[17-i]-numbers[i]>=0)
		{
			tries=0
			while(tries<MAX_TRIES)
			{
				read_file(configfile,random_num(numbers[i],numbers[17-i]),read,31,trash)
				if(containi(read,"%nominated%")==0 && num_nominated>0) format(read,31,"%s",nominated[random_num(0,num_nominated - 1)])
				if(is_map_valid(read) && !equali(read,currentmap) && (get_pcvar_num(lastmap_pcvar) || !equali(read,lastmap)) && (get_pcvar_num(lastlastmap_pcvar) || !equali(read,lastlastmap)))
				{
					for(j=1;j<i;j++)
					{
						if(equali(read,maps[j]))
						{
							j = 0
							break;
						}
					}
					if(!j) break;
					format(maps[i],31,"%s",read)
					format(menu,1999,"%s^n%d. %s",menu,i,read)
					switch(i)
					{
						case 1: keys |= (1<<0)
						case 2: keys |= (1<<1)
						case 3: keys |= (1<<2)
						case 4: keys |= (1<<3)
						case 5: keys |= (1<<4)
						case 6: keys |= (1<<5)
						case 7: keys |= (1<<6)
						case 8: keys |= (1<<7)
					}
					break;
				}
				tries++
			}
		}
	}

	if(add_extend)
	{
		new mapname[32]
		get_mapname(mapname,31)
		if(extended<get_pcvar_num(extended_pcvar))
		{
			format(menu,1999,"%s^n^n9. Extend %s",menu,mapname)
			keys |= (1<<8)
		}
	}
	format(menu,1999,"%s^n0. I don't care",menu)

	set_hudmessage(255,0,0,0.03,0.40,0,6.0,1.0,0.0,0.0,3)
	show_hudmessage(0,"Vote for Next Map in %d seconds:",num)

	set_hudmessage(255,255,255,0.03,0.40,0,6.0,1.0,0.0,0.0,4)
	show_hudmessage(0,menu)

	set_task(1.0,"Send_Menu",0,"",0,"a",num)
	set_task(get_pcvar_float(delay_tally_time_pcvar) + float(num),"VoteTally",0)

	voting=true
	voterocked=-1.0
}

public Send_Menu()
{
	if(num!=1)
	{
		set_hudmessage(255,0,0,0.03,0.40,0,6.0,1.0,0.0,0.0,3)
		show_hudmessage(0,"Vote for Next Map in %d seconds:",num-1)

		set_hudmessage(255,255,255,0.03,0.40,0,6.0,1.0,0.0,0.0,4)
		show_hudmessage(0,menu)
		num--
	}
	else
	{
		client_cmd(0,"spk Gman/Gman_Choose2")
		format(menu,1999,"Vote for Next Map:%s",menu)
		show_menu(0,keys,menu,get_pcvar_num(delay_tally_time_pcvar),"CustomNextMap")
	}
}

public saynextmap(id)
{
	if(strlen(cur_nextmap)) client_print(0,print_chat,"[AMXX] --Nextmap: %s",cur_nextmap)
	else client_print(0,print_chat,"[AMXX] --Nextmap not chosen yet.")
}

public say_hook(id)
{
	new text[64]
	read_args(text,63)
	remove_quotes(text)

	new string[32]
	for(new i=0;i<sizeof(say_commands);i++)
	{
		format(string,31,"%s",say_commands[i])
		if(containi(text,string)==0) return sayrockthevote(id);
	}
	
	if( is_map_valid2(text) && can_nominate_map(text) ) return saynominate(id,text);
	
	return PLUGIN_CONTINUE
}

public can_nominate_map( check[] )
{
	new inifile[256]
	get_configsdir(inifile,255)
	format(inifile,255,"%s/custom_nextmaps.ini",inifile)
	
	new pointer
	pointer = fopen(inifile,"r")
	if (pointer)
	{
		new data[128],map[32]
		
		while(fgets(pointer,data,127))
		{
			replace(data, charsmax(data), "^n", "")
			
			if (!data[0] || data[0] == '[') continue;
			
			parse(data,map,31)
			
			// Nomination check is at follows:
			// -
			// 1. Map must be valid (duh)
			// 2. Map must be on the votemap file
			// 3. There should be at least 1 hour of difference since the map was last played
			if (equal(check, map))
			{
				new vaultkey[48]
				format(vaultkey, charsmax(vaultkey), "rtv-%s", map)
				if (vaultdata_exists(vaultkey))
				{
					new timestamp_save[64], timestamp_old, timestamp_new, timestamp_diff
					get_vaultdata(vaultkey, timestamp_save, charsmax(timestamp_save))
					timestamp_old = str_to_num(timestamp_save)
					timestamp_new = get_systime()
					timestamp_diff = timestamp_new - timestamp_old
					if ( timestamp_diff > 4500 )
						return 1;
					else
					{
						client_print(0,print_chat,"[AMXX] That map has been recently played and cannot be nominated.")
						return 0;
					}
				}
				return 1;
			}
		}
		fclose(pointer)
	}
	
	return 0;
}

public sayrockthevote(id)
{
	if(voterocked==-1.0)
	{
		client_print(id,print_chat,"[AMXX] Voting Currently in Process.")
	}
	else if((!voterocked && get_gametime()>get_pcvar_num(rtv_wait_pcvar)) || (get_gametime() - voterocked) > get_pcvar_num(rtv_wait_pcvar))
	{
		if(get_pcvar_num(rtv_percent_pcvar)>0 && get_pcvar_num(rtv_percent_pcvar)<=100)
		{
			if(rtv[id])
			{
				client_print(id,print_chat,"[AMXX] You have already voted to Rock the Vote.")
			}
			else
			{
				rtv[id]=true
				rtvtotal++

				new num2, players[32]
				get_players(players,num2,"ch")

				new name[32]
				get_user_name(id,name,31)

				new num3 = floatround((num2 * get_pcvar_float(rtv_percent_pcvar) / 100.0) - rtvtotal,floatround_ceil)

				if(num3<=0)
				{
					client_print(0,print_chat,"[AMXX] %s has voted to Rock the Vote.",name)
					client_print(0,print_chat,"[AMXX] The Vote has been Rocked!")

					make_menu(1)

					voterocked2=true
				}
				else
				{
					if(num3!=1) client_print(0,print_chat,"[AMXX] %s has voted to Rock the Vote. Need %d more players.",name,num3)
					else client_print(0,print_chat,"[AMXX] %s has voted to Rock the Vote. Need 1 more player.",name)
				}
			}
		}
		else
		{
			client_print(id,print_chat,"[AMXX] Rock the Vote is disabled.")
		}
	}
	else if(voterocked>0.0)
	{
		client_print(id,print_chat,"[AMXX] Cannot Rock the Vote again for another %d seconds.",get_pcvar_num(rtv_wait_pcvar) - (floatround(get_gametime()) - floatround(voterocked)))
	}
	else
	{
		client_print(id,print_chat,"[AMXX] Cannot Rock the Vote till %d seconds after map start. (%d more seconds)",get_pcvar_num(rtv_wait_pcvar),get_pcvar_num(rtv_wait_pcvar) - floatround(get_gametime()))
	}

	return PLUGIN_CONTINUE
}

public saynominate(id,nom_map[64])
{
	if(has_nominated[id])
	{
		client_print(id,print_chat,"[AMXX] You have already nominated a map.")
	}
	else if(is_map_valid2(nom_map))
	{
		if(equali(nom_map,currentmap))
		{
			client_print(0,print_chat,"[AMXX] Cannot nominated the current map.")
			return PLUGIN_CONTINUE
		}
		else if(!get_pcvar_num(lastmap_pcvar) && equali(nom_map,lastmap))
		{
			client_print(0,print_chat,"[AMXX] Cannot nominated the previous map.")
			return PLUGIN_CONTINUE
		}
		else if(!get_pcvar_num(lastlastmap_pcvar) && equali(nom_map,lastlastmap))
		{
			client_print(0,print_chat,"[AMXX] Cannot nominated the previous to previous map.")
			return PLUGIN_CONTINUE
		}

		for(new i=0;i<num_nominated;i++)
		{
			if(equali(nominated[i],nom_map))
			{
				client_print(0,print_chat,"[AMXX] That map has already been nominated.")
				return PLUGIN_CONTINUE
			}
		}

		format(nominated[num_nominated],31,"%s",nom_map)
		num_nominated++

		new name[32]
		get_user_name(id,name,31)
		client_print(0,print_chat,"[AMXX] %s nominated %s.",name,nom_map)
		has_nominated[id] = true
	}
	else
	{
		client_print(0,print_chat,"[AMXX] That map does not exist on this server.")
	}

	return PLUGIN_CONTINUE
}

public is_map_valid2(map[])
{
	if(is_map_valid(map) &&
	containi(map,"<")==-1 &&
	containi(map,"\")==-1 &&
	containi(map,"/")==-1 &&
	containi(map,">")==-1 &&
	containi(map,"?")==-1 &&
	containi(map,"|")==-1 &&
	containi(map,"*")==-1 &&
	containi(map,":")==-1 &&
	containi(map,"^"")==-1
	)
		return 1;

	return 0;
}

public Check_Endround()
{
	if(voterocked==-1.0)
		return ;

	new bool:continuea=false

	if(cstrike)
	{
		new winlimit = get_pcvar_num(mp_winlimit)
		if(winlimit)
		{
			new c = winlimit - 2
			if(!((c> g_teamScore[0]) && (c>g_teamScore[1]) ))
			{
				continuea=true
			}
		}

		new maxrounds = get_pcvar_num(mp_maxrounds)
	
		if(maxrounds)
		{
			if(!((maxrounds - 2) > (g_teamScore[0] + g_teamScore[1])))
			{
				continuea=true
			}
		}
	}

	new timeleft = get_timeleft()
	if(!(timeleft < 1 || timeleft > 129))
	{
		continuea=true
	}

	if(!continuea)
		return ;

	remove_task(1337)

	make_menu(1)

	return ;
}

public VoteCount(id,key)
{
	if(voting)
	{
		new name[32]
		get_user_name(id,name,31)
		if(key==8)
		{
			if(get_pcvar_num(showvotes_pcvar)) client_print(0,print_chat,"[AMXX] %s voted for map extension.",name)
			votes[9]++
		}
		else if(key==9)
		{
			if(get_pcvar_num(showvotes_pcvar)) client_print(0,print_chat,"[AMXX] %s didn't vote.",name)
		}
		else if(strlen(maps[key+1]))
		{
			if(get_pcvar_num(showvotes_pcvar)) client_print(0,print_chat,"[AMXX] %s voted for %s.",name,maps[key+1])
			votes[key+1]++
		}
		else
		{
			show_menu(id,keys,menu,-1,"CustomNextMap")
		}
	}
	return PLUGIN_HANDLED
}

public VoteTally(num)
{
	voting=false
	new winner[2]
	for(new i=1;i<10;i++)
	{
		if(votes[i]>winner[1])
		{
			winner[0]=i
			winner[1]=votes[i]
		}
		votes[i]=0
	}
	if(!winner[1])
	{
		if(!voterocked2)
		{
			/*
			new mapname[32]
			get_cvar_string("qq_lastmap",mapname,31)
			set_cvar_string("qq_lastlastmap",mapname)
			get_mapname(mapname,31)
			set_cvar_string("qq_lastmap",mapname)
			*/
			winner[0] = random_num( 1, 5 );
			set_cvar_string("amx_nextmap",maps[winner[0]])
			client_print(0,print_chat,"[AMXX] No one voted. Random Map coming.")
			
			set_task(1.0,"override_change_level",winner[0],"",0,"d")
		}
		else
		{
			client_print(0,print_chat,"[AMXX] No one voted.")
			voterocked=get_gametime()
		}
	}
	else if(winner[0]==9)
	{
		if(!voterocked2)
		{
			client_print(0,print_chat,"[AMXX] Map extending won. Extending map for %d minutes.",get_pcvar_num(extendtime_pcvar))
			set_pcvar_float(mp_timelimit,get_pcvar_float(mp_timelimit) + get_pcvar_num(extendtime_pcvar))
			set_task(15.0,"Check_Endround",1337,"",0,"b")
			extended++
		}
		else
		{
			client_print(0,print_chat,"[AMXX] Map extending won. No new map.")
		}
		voterocked=get_gametime()
	}
	else
	{
		new mapname[32]
		get_cvar_string("qq_lastmap",mapname,31)
		set_cvar_string("qq_lastlastmap",mapname)
		get_mapname(mapname,31)
		set_cvar_string("qq_lastmap",mapname)
		client_print(0,print_chat,"[AMXX] Voting Over. Nextmap will be %s!",maps[winner[0]])
		if(!voterocked2)
		{
			set_cvar_string("amx_nextmap",maps[winner[0]])
			set_task(1.0,"override_change_level",winner[0],"",0,"d")
		}
		else
		{
			set_task(5.0,"change_level",winner[0])
		}
		format(cur_nextmap,31,"%s",maps[winner[0]])
	}
	for(new i=0;i<=32;i++) rtv[i]=false

	voterocked2=false
}

public change_level(map)
{
	server_cmd("amx_map %s",maps[map])
}

public override_change_level( map )
{
	server_cmd("mp_nextmap %s",maps[map])
	server_cmd("mp_timelimit 0")
	
	set_task( 1.0, "as_endgame" )
}

public as_endgame()
{
	new ent = engfunc(EngFunc_FindEntityByString, -1, "targetname", "sys_game")
	fm_set_kvd( ent, "$i_end", "1" );
}

//From the AMXX nextmap base file
public team_score()
{
	new team[2]
	read_data(1,team,1)
	g_teamScore[(team[0]=='C') ? 0 : 1] = read_data(2)
}

stock fm_set_kvd(entity, const key[], const value[], const classname[] = "") {
	if (classname[0])
		set_kvd(0, KV_ClassName, classname);
	else {
		new class[32];
		pev(entity, pev_classname, class, sizeof class - 1);
		set_kvd(0, KV_ClassName, class);
	}

	set_kvd(0, KV_KeyName, key);
	set_kvd(0, KV_Value, value);
	set_kvd(0, KV_fHandled, 0);

	return dllfunc(DLLFunc_KeyValue, entity, 0);
}
