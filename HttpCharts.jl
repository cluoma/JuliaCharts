# A basic HTTP api for generating charts using Julia
#
# Copyright Colin Luoma 2016
#
# BSD License

using HttpServer, HttpCommon, Plots

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
  # X values
  m = match(r"x=([0-9.],*)+", resource)
  x = m.match[3:length(m.match)]
  # Y values
  m = match(r"y=([0-9.],*)+", resource)
  y = m.match[3:length(m.match)]

  x = map(x->parse(Float64,x),split(x, ','))
  y = map(x->parse(Float64,x),split(y, ','))

  my_buf = IOBuffer()
  my_plot = plot(x, y);
  writemime(my_buf, "image/png", my_plot)
  takebuf_array(my_buf)
end

http = HttpHandler() do req::Request, res::Response
  if ismatch(r"^/randomchart",req.resource)
    Response(random_chart(), headers("image/png"))
  elseif ismatch(r"^/linechart",req.resource)
    Response(line_chart(req.resource), headers("image/png"))
  else
    Response(400)
  end
end

server = Server( http )
run( server, 4567 )
