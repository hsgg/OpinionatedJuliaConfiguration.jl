@doc raw"""
    OpinionatedJuliaConfiguration

This module is intended to be called from `~/.julia/config/startup.jl` to setup
sane defaults. Key is to achieve reproducible results more easily, and that
includes reducing the number of times things get updated.
"""
module OpinionatedJuliaConfiguration

using Revise
# using Distributed  # preload for Revise
using TestEnv
using Pkg
# using Reexport

export TestEnv
# @reexport using LanguageServer


function __init__()
    # Don't update all the time.
    Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true

    ## Really don't update all the time
    #ENV["JULIA_CONDAPKG_OFFLINE"] = true  # doesn't work... unclear what is going on

    # Don't load from the main environment. (Because not in Manifest.toml)
    filter!(x -> x != "@v#.#", LOAD_PATH)

    # activate temporary environment (because need to prevent spamming main environment)
    if isnothing(Base.active_project())
        Pkg.activate(temp=true)
    end
end


function update()
    current_env = Base.active_project()
    @show current_env

    major, minor, patch = split(string(VERSION), ".")
    base_env = "v$major.$minor"
    Pkg.activate(base_env, shared=true)
    Pkg.update()
    Pkg.status()

    Pkg.activate(current_env)
end


end # module OpinionatedJuliaConfiguration
