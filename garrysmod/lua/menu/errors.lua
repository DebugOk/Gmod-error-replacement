-- Inject some custom stuff into the error handlerer
CreateConVar("cl_errorenable", '1', "FCVAR_LUA_CLIENT", "Decides if lua errors should be shown")
CreateConVar("cl_fullerror", "0", "FCVAR_LUA_CLIENT")
CreateConVar("cl_errorstext", "Something is fucking creating script errors!", "FCVAR_LUA_CLIENT")
CreateConVar("cl_errorsicon", "icon16/error.png", "FCVAR_LUA_CLIENT", "Decides what icon should be shown")
CreateConVar("errorreplace_version", '1', "FCVAR_LUA_CLIENT")

-- End of the injection

--
-- Here we get a callback from the game/client code on Lua errors, and display a nice notification.
--
-- This should help `newbs` find out which addons are crashing.
--

local Errors = {}

hook.Add( "OnLuaError", "MenuErrorHandler", function( str, realm, addontitle, addonid )
	local text = GetConVarString("cl_errorstext")
	--
	-- This error is caused by a specific addon
	--
	if ( isstring( addonid ) ) then

		--
		-- Down Vote
		--
		--steamworks.Vote( addonid, false )

		--
		-- Disable Naughty Addon
		--
		--timer.Simple( 5, function()
		--	MsgN( "Disabling addon '", addontitle, "' due to lua errors" )
		--	steamworks.SetShouldMountAddon( addonid, false )
		--	steamworks.ApplyAddons()
		--end )
		if(GetConVarNumber("cl_fullerror")==1) then
			text = GetConVarString("cl_errorstext")
		else
			text = string.format( language.GetPhrase( "errors.addon" ), addontitle )
		end
	end

	if ( addonid == nil ) then addonid = 0 end

	if ( Errors[ addonid ] ) then

		Errors[ addonid ].times	= Errors[ addonid ].times + 1
		Errors[ addonid ].last	= SysTime()

		return
	end

	local error = {
		first	= SysTime(),
		last	= SysTime(),
		times	= 1,
		title	= addontitle,
		x		= 32,
		text	= text
	}

	Errors[ addonid ] = error

end )



hook.Add( "DrawOverlay", "MenuDrawLuaErrors", function()
	if ( table.IsEmpty( Errors ) ) then return end

	local idealy = 32
	local height = 30
	local EndTime = SysTime() - 10
	local Recent = SysTime() - 0.5
	local matAlert = Material(GetConVarString("cl_errorsicon"))
	for k, v in SortedPairsByMemberValue( Errors, "last" ) do

		surface.SetFont( "DermaDefaultBold" )
		if ( v.y == nil ) then v.y = idealy end
		if ( v.w == nil ) then v.w = surface.GetTextSize( v.text ) + 48 end

		if(GetConVarNumber("cl_errorenable")==1) then
			draw.RoundedBox( 2, v.x + 2, v.y + 2, v.w, height, Color( 40, 40, 40, 255 ) )
			draw.RoundedBox( 2, v.x, v.y, v.w, height, Color( 240, 240, 240, 255 ) )

			if ( v.last > Recent ) then

				draw.RoundedBox( 2, v.x, v.y, v.w, height, Color( 255, 200, 0, ( v.last - Recent ) * 510 ) )

			end

			surface.SetTextColor( 90, 90, 90, 255 )
			surface.SetTextPos( v.x + 34, v.y + 8 )
			surface.DrawText( v.text )

			surface.SetDrawColor( 255, 255, 255, 150 + math.sin( v.y + SysTime() * 30 ) * 100 )
			surface.SetMaterial( matAlert )
			surface.DrawTexturedRect( v.x + 6, v.y + 6, 16, 16 )
		end
		v.y = idealy

		idealy = idealy + 40

		if ( v.last < EndTime ) then
			Errors[ k ] = nil
		end

	end

end )