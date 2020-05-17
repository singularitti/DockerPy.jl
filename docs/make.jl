using DockerPy
using Documenter

makedocs(;
    modules=[DockerPy],
    authors="Qi Zhang <singularitti@outlook.com>",
    repo="https://github.com/singularitti/DockerPy.jl/blob/{commit}{path}#L{line}",
    sitename="DockerPy.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://singularitti.github.io/DockerPy.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/DockerPy.jl",
)
