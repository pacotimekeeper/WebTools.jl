module WebTools

# Write your package code here.

using HTTP, Cascadia, Gumbo
using StringEncodings

export charset, responseContent, contentType
export contenttype, responsecontent
# html_tables
# export read_html

function charset(response::HTTP.Messages.Response; default_encoding::AbstractString = "UTF-8") :: AbstractString
    htmlstr = String(deepcopy(response.body))
    content = parsehtml(htmlstr).root
    metatag = Cascadia.matchFirst(sel"meta", content) |> string
    m = match(r"charset=(.*?)\"", metatag)
    !isnothing(m) ? m.captures[1] : default_encoding
end

function contentType(url::AbstractString) :: Union{AbstractString, Nothing}
    response = HTTP.get(url)
    content_body = String(response.body)
    pattern = r"charset=(.*?)\""
    m = match(pattern, content_body)
    m !== nothing ? m.captures[1] |> String : nothing
end

function contenttype(url::AbstractString) :: Union{AbstractString, Nothing}
    response = HTTP.get(url)
    content_body = String(response.body)
    pattern = r"charset=(.*?)\""
    m = match(pattern, content_body)
    m !== nothing ? m.captures[1] |> String : nothing
end

##
##read_html is an wrapper function for html_tables with default selector and start_row giving dataframes from the url provided

##
# greet() = print("Hello World!")

#=
Renaming the function into CamelCase

=#
function responseContent(response::HTTP.Messages.Response, encoding::AbstractString = "UTF-8")::HTMLElement
    content = try
        parsehtml(decode(deepcopy(response.body), encoding)).root
    catch ## using UTF-8 decoding
        println("Unable to decode with $(encoding), using UTF-8 instead")
        parsehtml(String(deepcopy(response.body))).root
    end
    content
end

function responsecontent(response::HTTP.Messages.Response, encoding::AbstractString = "UTF-8")::HTMLElement
    content = try
        parsehtml(decode(deepcopy(response.body), encoding)).root
    catch ## using UTF-8 decoding
        println("Unable to decode with $(encoding), using UTF-8 instead")
        parsehtml(String(deepcopy(response.body))).root
    end
    content
end

end
