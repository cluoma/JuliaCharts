# A basic HTTP api for generating charts using Julia
#
# Copyright Colin Luoma 2016
#
# BSD License

using HttpServer, HttpCommon, Plots
pyplot()

function headers(mime::AbstractString)
  Headers(
    "Server"            => "JuliaCharts/0.0.1",
    "Content-Type"      => "$mime",
    "Content-Language"  => "en",
    "Date" => Dates.format(now(Dates.UTC), Dates.RFC1123Format) )
end

function random_chart()
    my_buf = IOBuffer()
    my_plot = plot(rand(100,6),layout=@layout([a b;c]),title=["A" "B" "C"],title_location=:left,left_margin=[20mm 0mm],bottom_margin=50px,xrotation=60);
    writemime(my_buf, "image/png", my_plot)
    takebuf_array(my_buf)
end

function line_chart(resource::AbstractString)

    # Attempt to parse query strings
    # X values
    x = []
    try
        m = match(r"x=[0-9.,e-]*", resource)
        x = m.match[3:length(m.match)]
        x = map(x->parse(Float64,x),split(x, ','))
    catch
        x = false
    end
    # Y values
    y = []
    try
        m = match(r"y=[0-9.,e-]*", resource)
        y = m.match[3:length(m.match)]
        y = map(x->parse(Float64,x),split(y, ','))
    catch
        y = false
    end

    my_buf = IOBuffer()

    # Print correct chart (missing x and we just plot y)
    my_plot = plot([1:10], [1:10])
    if x == false && y != false
        my_plot = plot(y);
    elseif x != false && y != false
        my_plot = plot(x, y);
    end
    writemime(my_buf, "image/png", my_plot)
    takebuf_array(my_buf)
end

function spiral_chart(resource::AbstractString)

    # Attempt to get number of spirals from query string
    rotations = 10
    try
        m = match(r"n=[0-9]*", resource)
        rotations = m.match[3:length(m.match)]
        rotations = parse(Int, rotations)
    catch
        rotations = 10
    end

    # Create spiral
    x = []
    y = []
    r = 0
    θ = 1
    while θ <= rotations * 2π && θ >= -1 * rotations * 2π

        x = cat(1, x, r * cos(θ))
        y = cat(1, y, r * sin(θ))

        r += 2π / θ
        θ += 0.01 * rotations * abs(2π / θ)

    end

    # Write plot
    my_buf = IOBuffer()
    my_plot = plot(x, y)
    writemime(my_buf, "image/png", my_plot)
    takebuf_array(my_buf)
end

http = HttpHandler() do req::Request, res::Response
    if ismatch(r"^/randomchart",req.resource)
        Response(random_chart(), headers("image/png"))
    elseif ismatch(r"^/linechart",req.resource)
        Response(line_chart(req.resource), headers("image/png"))
    elseif ismatch(r"^/spiralchart",req.resource)
        Response(spiral_chart(req.resource), headers("image/png"))
    else
        Response(400)
    end
end

server = Server( http )
run( server, 4567 )
