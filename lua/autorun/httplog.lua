/*---------------------------------------------------------------------------
Http log
By Velkon.
---------------------------------------------------------------------------*/

httpl = httpl or {}

httpl.log = httpl.log or {} -- actual log

/*---------------------------------------------------------------------------
Begin detouring
---------------------------------------------------------------------------*/

if not httpl.HTTP then
	httpl.HTTP = HTTP
end

CreateConVar("httplog_print",1)

local function log(t,extra)
	if GetConVar("httplog_print"):GetBool() then
		MsgC(Color(255,0,0),"[HTTP] ",Color(0,255,0),t.url,Color(255,255,255)," | ",Color(0,0,255),t.method)
		if extra then
			MsgC(Color(255,255,255)," | ",extra)
		end
		Msg("\n")
	end
	table.insert(httpl.log,t)

end

concommand.Add("httplog_printlog",function()
	PrintTable(httpl.log)
end)

concommand.Add("httplog_save",function()

	local s = "HttpLog By Velkon or something\n"

	local function a(b)
		if TAB then
			s = s .. "\t" .. b .. "\n"
		else
			s = s .. b .. "\n"
		end
	end

	local function t()
		TAB = not TAB
	end

	a("Log saved on: " .. os.date( "%d/%m/%Y" , os.time() ))
	a("Hint: You can ctrl+f for !=== or something to find new shit")
	a("Starting log...\n\n")

	for k,v in pairs(httpl.log) do

		a("!=================== HTTP " .. v.method:upper() .." ===================!")
		a("URL: " .. v.url)
		if v.parameters then

			a("Parameters: ")
			t()
			for _,h in pairs(v.parameters) do
				a("\t" .. h)
			end
			t()
		end
		if v.headers then

			a("Headers:")
			t()
			for _,h in pairs(v.headers) do
				a("\t" .. h)
			end
			t()

		end


		if v.code then
			a("Reply:")
			t()
			a("Code: " .. v.code)
			if v.head then
				a("Headers:")
				for _,h in pairs(v.head) do
					a("\t" .. h)
				end
			end
			if v.body then
				v.body = v.body:gsub("\n","\n\t")
				if #v.body > 600 then
					a("Body:\n\t" .. string.sub(v.body,0,600) .. "\n...REST OF BODY IS ON URL PROBABLY OK JUST USE CORRECT HEADERS.")
				else
					a("Body:\n\t" .. v.body)
				end
			end
			t()
		end

		if v.err then
			a("ERROR: " .. v.err)
		end

		a("!=================== END OF HTTP " .. v.method:upper() .. " ===================!\n\n")

	end

	file.Write("httplog " .. os.date( "%d-%m-%Y" , os.time() ) .. ".txt",s)

	print("Saved to data/httplog " .. os.date( "%d-%m-%Y" , os.time() ) .. ".txt!" )


end)

function HTTP(args)

	if not args then return end
	if not istable(args) then return end

	local a = {} -- temp http table

	a.url = args.url

	a.method = args.method

	if args.parameters then

		a.parameters = args.parameters

	end

	if args.headers then

		a.headers = args.headers

	end

	a.success = function(code,body,head)

		a.code = code
		a.body = body
		a.head = head
		log(a,"Code: "..code)

		if args.success then
			return args.success(code,body,head)
		end

	end

	a.failed = function(err)
		a.err = err
		log(a,"Error: " .. err)
		if args.failed then
			return args.failed(err)
		end
	end

	return httpl.HTTP(a)

	
end

MsgC(Color(255,0,0),"[HTTP] ",Color(255,255,255),"Started http log...\n")

/*---------------------------------------------------------------------------
Rest of module
---------------------------------------------------------------------------*/

--[[---------------------------------------------------------

	Get the contents of a webpage.
	
	Callback should be 
	
	function callback( (args optional), contents, size )
	
-----------------------------------------------------------]]
function http.Fetch( url, onsuccess, onfailure )

	local request = 
	{
		url			= url,
		method		= "get",

		success		= function( code, body, headers )
	
			if ( !onsuccess ) then return end

			onsuccess( body, body:len(), headers, code )

		end,

		failed		= function( err )

			if ( !onfailure ) then return end

			onfailure( err )

		end
	}

	HTTP( request )

end


function http.Post( url, params, onsuccess, onfailure )

	local request = 
	{
		url			= url,
		method		= "post",
		parameters	= params,

		success		= function( code, body, headers )
	
			if ( !onsuccess ) then return end

			onsuccess( body, body:len(), headers, code )

		end,

		failed		= function( err )

			if ( !onfailure ) then return end

			onfailure( err )

		end
	}

	HTTP( request )

end