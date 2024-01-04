module WebTools

# Write your package code here.

using DataFrames, DFExt
using HTTP, Cascadia, Gumbo
using StringEncodings

export charset, response_content, content_type, html_tables

function charset(response::HTTP.Messages.Response; default_encoding::AbstractString = "UTF-8") :: AbstractString
    htmlstr = String(deepcopy(response.body))
    content = parsehtml(htmlstr).root
    metatag = Cascadia.matchFirst(sel"meta", content) |> string
    m = match(r"charset=(.*?)\"", metatag)
    !isnothing(m) ? m.captures[1] : default_encoding
end

function response_content(response::HTTP.Messages.Response, encoding::AbstractString = "UTF-8") ::HTMLElement
    content = try
        parsehtml(decode(deepcopy(response.body), encoding)).root
    catch ## using UTF-8 decoding
        println("Unable to decode with $(encoding), using UTF-8 instead")
        parsehtml(String(deepcopy(response.body))).root
    end
    content
end

function content_type(url::AbstractString) :: Union{AbstractString, Nothing}
    response = HTTP.get(url)
    contentBody = String(response.body)
    pattern = r"charset=(.*?)\""
    m = match(pattern, contentBody)
    m !== nothing ? m.captures[1] |> String : nothing
end

function html_tables(html::HTMLElement; selector::AbstractString="", startrow=1) ::Vector{AbstractDataFrame}
    tables = eachmatch(Selector("table$(selector)"), html)
    dfs = DataFrame[]
    for table in tables
        tableRows = eachmatch(sel"tr", table)
        tableHeader = try
            text.(tableRows[startrow] |> children)
        catch
            continue
        end
        
        fill_missing_headers(tableHeader)
        df = DataFrame(map(th-> th => [], tableHeader), makeunique=true) # create emtpy dataframe with colnames
        
        for tableRow in tableRows[startrow+1:end]
            tableData = text.(tableRow |> children)
            if length(tableData) == length(tableHeader)
                push!(df, tableData)
            end
        end
        push!(dfs, df)
    end
    dfs
end

# greet() = print("Hello World!")

end
