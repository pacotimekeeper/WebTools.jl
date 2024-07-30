using Revise
using WebTools
using HTTP
using Gumbo, Cascadia
import Cascadia.matchFirst
url = "https://www.dsat.gov.mo/hzmb/car_cross_2024.aspx"
matchFirst(sel"td", url)
resp = HTTP.get(url)
doc = parsehtml(String(resp.body))
matchFirst(sel"td", doc.root)