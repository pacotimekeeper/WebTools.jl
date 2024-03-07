module WebTools

# Write your package code here.

using DataFrames
using HTTP, Cascadia, Gumbo
using StringEncodings

export charset, response_content, content_type
# html_tables
# export read_html

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
    content_body = String(response.body)
    pattern = r"charset=(.*?)\""
    m = match(pattern, content_body)
    m !== nothing ? m.captures[1] |> String : nothing
end

function html_tables(html::HTMLElement; selector::AbstractString="", start_row=1) ::Vector{AbstractDataFrame}
    function fill_missing_headers(headers)
        count = 1
        for (index, value) in enumerate(headers)
            if value == ""
                headers[index] = "missing_"*string(count)
                count += 1
            end
        end
    end
    
    tables = eachmatch(Selector("table$(selector)"), html)
    dfs = DataFrame[]
    for table in tables
        table_rows = eachmatch(sel"tr", table)
        table_headers = try
            text.(table_rows[start_row] |> children)
        catch
            continue
        end
        
        fill_missing_headers(table_headers)
        df = DataFrame(map(th-> th => [], table_headers), makeunique=true) # create emtpy dataframe with colnames
        
        for table_row in table_rows[start_row+1:end]
            table_data = text.(table_row |> children)
            if length(table_data) == length(table_headers)
                push!(df, table_data)
            end
        end
        push!(dfs, df)
    end
    dfs
end


##
##read_html is an wrapper function for html_tables with default selector and start_row giving dataframes from the url provided

##
function read_html(response::HTTP.Messages.Response, selector::abstractstring="", start_row=1) ::vector{abstractdataframe}
    # content = response_content(response, charset(response))
    content = response_content(response)
    html_tables(content, selector=selector, start_row=start_row)
end
# greet() = print("Hello World!")

#=
Renaming the function into CamelCase

=#
function responseContent(response::HTTP.Messages.Response, encoding::AbstractString = "UTF-8") ::HTMLElement
    content = try
        parsehtml(decode(deepcopy(response.body), encoding)).root
    catch ## using UTF-8 decoding
        println("Unable to decode with $(encoding), using UTF-8 instead")
        parsehtml(String(deepcopy(response.body))).root
    end
    content
end


function htmlTables(html::HTMLElement; selector::AbstractString="", startRow=1) ::Vector{AbstractDataFrame}
    function fillMissingHeaders(headers)
        count = 1
        for (index, value) in enumerate(headers)
            if value == ""
                headers[index] = "missing_"*string(count)
                count += 1
            end
        end
    end
    
    tables = eachmatch(Selector("table$(selector)"), html)
    dfs = DataFrame[]
    for table in tables
        tableRows = eachmatch(sel"tr", table)
        tableHeaders = try
            text.(tableRows[start_row] |> children)
        catch
            continue
        end
        
        fill_missing_headers(tableHeaders)
        df = DataFrame(map(th-> th => [], tableHeaders), makeunique=true) # create emtpy dataframe with colnames
        
        for tableRow in tableRows[start_row+1:end]
            tableData = text.(tableRow |> children)
            if length(tableData) == length(tableHeaders)
                push!(df, tableData)
            end
        end
        push!(dfs, df)
    end
    dfs
end


function readHTML(response::HTTP.Messages.Response, selector::abstractstring="", startRow=1) ::vector{abstractdataframe}
    # content = response_content(response, charset(response))
    content = responseContent(response)
    htmlTables(content, selector=selector, startRow=startRow)
end

end
