module PromiseExtractor

using Gumbo
using URIParser

const EXTRACT_RULE = [(:script, x -> true, "src"),
                      (:img, x -> true, "src"),
                      (:link, x -> haskey(attrs(x), "rel") && getattr(x, "rel") == "stylesheet", "href")]

function prefixed(url, prefix)
    @assert startswith(prefix, "http")
    prefix_uri = URI(prefix)

    if startswith(url, "http")
        if startswith(url, prefix)
            return Nullable(url)
        else
            return Nullable{AbstractString}()
        end
    elseif startswith(url, "//")
        p = "//" + prefix.host + (prefix.port == 0x0 ? "" : dec(prefix.port)) + prefix.path

        if startswith(url, p)
            return Nullable(url)
        else
            return Nullable{AbstractString}()
        end
    else
        return Nullable(url)
    end
end

function extract_url(elem, prefix)
    for rule in EXTRACT_RULE
        t, f, a = rule[1], rule[2], rule[3]

        if t == tag(elem) && f(elem) && haskey(attrs(elem), a)
            url = getattr(elem, a)
            p = prefixed(url, prefix)

            if !isnull(p)
                return p
            end
        end
    end
    return Nullable{AbstractString}()
end

function promise_for(raw_html, prefix)
    doc = parsehtml(raw_html)

    results = []
    for elem in preorder(doc.root)
        url = extract_url(elem, prefix)

        if !isnull(url)
            push!(results, get(url))
        end
    end

    return results
end

export promise_for

end # module
