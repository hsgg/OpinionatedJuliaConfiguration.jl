#!/usr/bin/env julia


using Pkg
Pkg.activate(; temp=true)
Pkg.add("LocalRegistry"); using LocalRegistry
Pkg.add("TOML"); using TOML
Pkg.add("CompatHelperLocal"); using CompatHelperLocal


# check if we can update compat section
all_uptodate = CompatHelperLocal.check(".")
if !all_uptodate && !("--no-compat" in ARGS)
    error("Please update compat section first.")
end


# edit Project.toml
run(`nano Project.toml`)
run(`$(Base.julia_cmd()) --project -e 'using Pkg; Pkg.resolve()'`)  # update Manifest.toml
run(`git add -p`)


# determine default tag name and commit message
proj = TOML.parsefile("Project.toml")
tagname = "v" * proj["version"]
if occursin("WATCosmologyJuliaLib", pwd())
    tagname = proj["name"] * "_" * tagname
end
print("Brief message for tag $tagname: ")
msg = readline()


# commit new version
is_commitable = !success(run(`git diff --quiet --cached --exit-code`, wait=false))
if is_commitable
    run(`git commit -e -m "$tagname: $msg"`)
end


# register in registry
register(; registry="WATCosmologyJuliaRegistry")


# tag and push the tag
run(`git tag $tagname -m $msg`)
run(`git push --tag`)
run(`git push`)  # also push branch, because I sometimes forget
