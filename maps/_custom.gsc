#include maps\_utility;
#include common_scripts\utility; 
#include maps\_zombiemode_utility;

init()
{
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	self.initial_spawn = 1;
	for(;;)
	{
		self waittill("spawned_player");
		wait_network_frame();
		self give_perk_reward();
		if (self.initial_spawn == 1)
		{
			self.initial_spawn = 0;
			self thread watch_for_respawn();
			self.score = 25000;
		}
	}
}

give_perk_reward()
{
	flag_wait( "all_players_connected" ); 
	wait_network_frame();

	if(IsDefined(self._retain_perks))
	{
		return;
	}

	if(!IsDefined(level._sq_perk_array))
	{
		level._sq_perk_array = [];
		
		machines = GetEntArray( "zombie_vending", "targetname" );	
		
		for(i = 0; i < machines.size; i ++)
		{
			level._sq_perk_array[level._sq_perk_array.size] = machines[i].script_noteworthy;
		}
	}

	for(i = 0; i < level._sq_perk_array.size; i ++)
	{
		if(!self HasPerk(level._sq_perk_array[i]))
		{
			self playsound( "evt_sq_bag_gain_perks" );
			self maps\_zombiemode_perks::give_perk(level._sq_perk_array[i]);
			wait(0.25);
		}
	}
	self._retain_perks = true;
}

watch_for_respawn()
{
	self endon("disconnect");
	while(1)
	{
		self waittill_either( "spawned_player", "player_revived" ); 
		wait_network_frame();
		self maps\_zombiemode_perks::update_perk_hud();
		self SetMaxHealth( level.zombie_vars["zombie_perk_juggernaut_health"] );
	}
}