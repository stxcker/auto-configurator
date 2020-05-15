local multipoint = ui.reference( "Rage", "Aimbot", "Multi-point" )
local pointscale = ui.reference( "Rage", "Aimbot", "Multi-point scale" )
local dynamic = ui.reference( "Rage", "Aimbot", "Dynamic multi-point" )
local prefer = ui.reference( "Rage", "Aimbot", "Prefer safe point" )
local limbsafepoint = ui.reference( "Rage", "Aimbot", "Force safe point on limbs" )
local autofire = ui.reference( "Rage", "Aimbot", "Automatic fire" )
local autowall = ui.reference( "Rage", "Aimbot", "Automatic penetration" )
local silentaim = ui.reference( "Rage", "Aimbot", "Silent aim" )
local hitchance = ui.reference( "Rage", "Aimbot", "Minimum hit chance" )
local damage = ui.reference( "Rage", "Aimbot", "Minimum damage" )
local hitboxes = ui.reference( "Rage", "Aimbot", "Target hitbox" )
local norecoil = ui.reference( "Rage", "Other", "Remove recoil" )
local resolver = ui.reference( "Rage", "Other", "Anti-aim correction" )
local preferbaim = ui.reference( "Rage", "Other", "Prefer body aim" )
local disablers = ui.reference( "Rage", "Other", "Prefer body aim disablers" )

local fakelag = ui.reference( "AA", "Fake lag", "Enabled" )

local infiniteduck = ui.reference( "Misc", "Movement", "Infinite duck" )
local easystrafe = ui.reference( "Misc", "Movement", "Easy strafe" )
local bunnyhop = ui.reference( "Misc", "Movement", "Bunny hop" )
local autostrafe = ui.reference( "Misc", "Movement", "Air strafe" )
local direction = ui.reference( "Misc", "Movement", "Air strafe direction" )

local limb_miss_percentage = 0
local body_miss_percentage = 0
local onshot_miss_percentage = 0

local total_hitgroup_shots = { 0 }
local total_hitgroup_misses = { 0 }

local latest_onshot = 0
local onshot_shots = 0
local onshot_misses = 0

local last_aimbot_fire_time = 0
local last_aimbot_target = 0
local fire_fight_initiated = false
local target_choke_log = { 0 }
local average_target_fakelag = 0

local old_simulation_time = { }

local hitgroup_names = { "generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
client.set_event_callback( "aim_fire", function( event_data )
	local group = hitgroup_names[ event_data.hitgroup + 1 ] or "?"
	for k in pairs( hitgroup_names ) do
		local key = hitgroup_names[ k + 1 ] or "?"
		if total_hitgroup_shots[ key ] == nil then
			total_hitgroup_shots[ key ] = 0
		end
	end
	total_hitgroup_shots[ group ] = total_hitgroup_shots[ group ] + 1
	
	if group == "head" then
		if event_data.high_priority then
			onshot_shots = onshot_shots + 1
			latest_onshot = event_data.id
		end
	end
	
	last_aimbot_target = event_data.target
	last_aimbot_fire_time = globals.curtime( )
end )

client.set_event_callback( "player_hurt", function( event_data )
	local hurt = client.userid_to_entindex( event_data.userid )
	local attacker = client.userid_to_entindex( event_data.attacker )
	local hurt_weapon = entity.get_player_weapon( hurt )
	local attacker_weapon = entity.get_player_weapon( attacker )
	if hurt_weapon and attacker_weapon then
		local hurt_weapon_idx = entity.get_prop(weapon_ent, "m_iItemDefinitionIndex")
		local attacker_weapon_idx = entity.get_prop(weapon_ent, "m_iItemDefinitionIndex")
		if hurt_weapon_idx and attacker_weapon_idx then
			if hurt == entity.get_local_player( ) and attacker == last_aimbot_target and hurt_weapon_idx == attacker_weapon_idx then
				fire_fight_initiated = true
			end
		end
	end
end )

client.set_event_callback( "setup_command", function( cmd )
	if fire_fight_initiated and globals.curtime( ) - last_aimbot_fire_time > 5 then
		fire_fight_initiated = false
	end
end )

client.set_event_callback( "aim_miss", function( event_data )
	-- Spread miss handler
	if event_data.reason == "spread" then
		if ui.get( hitchance ) < 84 then
			ui.set( hitchance, ui.get( hitchance ) + 2 )
		else
			ui.set( hitchance, ui.get( hitchance ) + 2 )
			if ui.get( pointscale ) > 25 then
				ui.set( pointscale, ui.get( pointscale ) - 2 )
			end
		end
	end
	
	-- Resolver miss handler
	local group = hitgroup_names[ event_data.hitgroup + 1 ] or '?'
	for k in pairs( hitgroup_names ) do
		local key = hitgroup_names[ k + 1 ] or "?"
		if total_hitgroup_misses[ key ] == nil then
			total_hitgroup_misses[ key ] = 0
		end
	end
	if event_data.reason == "?" then
		client.log( group )
		total_hitgroup_misses[ group ] = total_hitgroup_misses[ group ] + 1
		if group == "left arm" or group == "right arm" or group == "left leg" or group == "right leg" then
			limb_miss_percentage = ( total_hitgroup_misses[ "left arm" ] + total_hitgroup_misses[ "right arm" ] + total_hitgroup_misses[ "left leg" ] + total_hitgroup_misses[ "right leg" ] ) / ( total_hitgroup_shots[ "left arm" ] + total_hitgroup_shots[ "right arm" ] + total_hitgroup_shots[ "left leg" ] + total_hitgroup_shots[ "right leg" ] )
			limb_miss_percentage = limb_miss_percentage * 100
			client.log( limb_miss_percentage.."%" )
			if ( total_hitgroup_shots[ "left arm" ] + total_hitgroup_shots[ "right arm" ] + total_hitgroup_shots[ "left leg" ] + total_hitgroup_shots[ "right leg" ] ) > 10 and limb_miss_percentage >= 66.66 then
				ui.set( limbsafepoint, true )
			end
		elseif group == "chest" or group == "stomach" then
			body_miss_percentage = ( total_hitgroup_misses[ 'chest' ] + total_hitgroup_misses[ "stomach" ] ) / ( total_hitgroup_shots[ 'chest' ] + total_hitgroup_shots[ "stomach" ] )
			body_miss_percentage = body_miss_percentage * 100
			if ( total_hitgroup_shots[ "chest" ] + total_hitgroup_shots[ "stomach" ] ) > 10 and body_miss_percentage >= 66.66 then
				ui.set( prefer, true )
			end
		elseif group == "head" then
			-- On-shot miss handler
			if event_data.id == latest_onshot then
				onshot_misses = onshot_misses + 1
				onshot_miss_percentage = onshot_misses / onshot_shots
				onshot_miss_percentage = onshot_miss_percentage * 100
				if onshot_shots > 10 and limb_miss_percentage >= 66.66 then
					ui.set( preferbaim, true )
					ui.set( disablers, "Target resolved", "Safe point headshot" )
				end
			end
		end
	end
end )

local function setup_recommended( )
	ui.set( hitboxes, "Head", "Stomach" )
	ui.set( multipoint, "Head", "Stomach" )
	ui.set( dynamic, true )
	ui.set( norecoil, true )
	ui.set( autofire, true )
	ui.set( autowall, true )
	ui.set( silentaim, true )
	ui.set( resolver, true )
	ui.set( fakelag, true )
	ui.set( infiniteduck, true )
	ui.set( easystrafe, true )
	ui.set( bunnyhop, true )
	ui.set( autostrafe, true )
	ui.set( direction, "View angles", "Movement keys" )
end

local setup = ui.new_button( "Config", "Presets", "Setup recommended options", setup_recommended )