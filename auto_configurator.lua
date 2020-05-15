local multipoint = ui.reference( "Rage", "Aimbot", "Multi-point" )
local pointscale = ui.reference( "Rage", "Aimbot", "Multi-point scale" )
local autofire = ui.reference( "Rage", "Aimbot", "Automatic fire" )
local autowall = ui.reference( "Rage", "Aimbot", "Automatic penetration" )
local silentaim = ui.reference( "Rage", "Aimbot", "Silent aim" )
local hitchance = ui.reference( "Rage", "Aimbot", "Minimum hit chance" )
local damage = ui.reference( "Rage", "Aimbot", "Minimum damage" )
local hitboxes = ui.reference( "Rage", "Aimbot", "Target hitbox" )
local norecoil = ui.reference( "Rage", "Other", "Remove recoil" )
local resolver = ui.reference( "Rage", "Other", "Anti-aim correction" )

local fakelag = ui.reference( "AA", "Fake lag", "Enabled" )

local infiniteduck = ui.reference( "Misc", "Movement", "Infinite duck" )
local easystrafe = ui.reference( "Misc", "Movement", "Easy strafe" )
local bunnyhop = ui.reference( "Misc", "Movement", "Bunny hop" )
local autostrafe = ui.reference( "Misc", "Movement", "Air strafe" )
local direction = ui.reference( "Misc", "Movement", "Air strafe direction" )

client.set_event_callback( "aim_miss", function( event_data )
	if event_data.reason == "spread" then
		if ui.get( hitchance ) < 84 then
			ui.set( hitchance, ui.get( hitchance ) + 2 )
		else
			if ui.get( pointscale ) > 25 then
				ui.set( pointscale, ui.get( pointscale ) - 2 )
			end
		end
	end
end )

local function setup_recommended( )
	ui.set( hitboxes, "Head", "Stomach" )
	ui.set( multipoint, "Head", "Stomach" )
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