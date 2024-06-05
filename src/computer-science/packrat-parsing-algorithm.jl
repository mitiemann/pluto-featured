### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 6e4ef6a6-73fb-416b-9963-f3c059c1651b
# necessary dependencies which are not automatically loaded by Pluto
using PlutoUI, 
	PlutoTeachingTools 

# ╔═╡ b340e590-5661-4f9b-88d6-fb51147dd907
md"""

!!! info "Attribution"

	This notebook is adapted from [slides by Byran Ford](https://pdos.csail.mit.edu/~baford/packrat/icfp02/slides/index.html).

"""

# ╔═╡ 3044d9fa-bade-11ee-066c-e1e6ccf577e1
md"""

# _Packrat_ parsing algorithm

This notebook gives a gentle introduction to _Packrat parsing_.
"""

# ╔═╡ a9835479-3fed-480d-9535-f5de0d3c10ca
TODO("Need a notebook about context-free grammars",
	 heading="CFG explanation page")

# ╔═╡ 10c408bf-6e57-4d42-87ee-af3327b2c6ea
TODO("Need a gentle introduction into parsing expression grammars",
     heading="PEG introduction")

# ╔═╡ b103ef8f-31a3-45c5-8086-a80b2cd14ae5
md"""
## Example grammar

Let's define a simple PEG which describes basic algebraic terms, consisting of **A**dditive terms, **M**ultiplicative terms, **P**rimitives and **D**ecimals.

```math
\begin{aligned}
A \rightarrow\,& M + A\\
  |\,& M\\
M \rightarrow\,& P * M\\
  |\,& P\\
P \rightarrow\,& \text{'('}\, A\, \text{')'}\\
  |\,& D\\
D \rightarrow\,& \text{'0'}\,|\,\text{'1'}\,|\, \dots |\,\text{'9'}
\end{aligned}
```
"""

# ╔═╡ 4a34223c-6b23-494c-bd8b-67bcf9a171b3
md"""
Now let's define a recursive descent parser for this grammar.
"""

# ╔═╡ 32c985b1-32b4-44f0-9597-07a38b3f619c
abstract type Result{V} end

# ╔═╡ 1bd7e1b6-ed6c-4c7f-95c8-fbc5b88bdd98
struct NoParse{V} <: Result{V} end

# ╔═╡ 5ff05889-61e6-4981-ad86-41a37f302cd4
struct Parsed{V} <: Result{V}
	value::V
	rest::String
end

# ╔═╡ 2cefab01-eeee-49e5-a987-46a4478ac096
function parseDecimal(input)
	alldigits = "0123456789"
	if !isempty(input) && occursin(input[1], alldigits)
		return Parsed{Int}(parse(Int, input[1]), input[2:end])
	else
		return NoParse{Int}()
	end
end

# ╔═╡ 83112978-9f28-419e-be92-a1c7d58558fe
function parsePrimitive(input)
	if !isempty(input) && input[1] == '(' && input[end] == ')'
		return parseAdditive(input[2:end-1])
	else
		return parseDecimal(input)
	end
end

# ╔═╡ 93b7488a-7065-43d4-8ca0-0ad57570134c
function parseMultitive(input)
	l = parsePrimitive(input)
	if isa(l, Parsed{Int}) && !isempty(l.rest) && l.rest[1] == '*'
		r = parseMultitive(l.rest[2:end])
		isa(r, Parsed{Int}) ? Parsed{Int}(l.value * r.value, r.rest) : NoParse{Int}
	else
		return l
	end
end

# ╔═╡ 8e6de62d-bf7c-4304-bdbf-6679d8c35fe7
function parseAdditive(input)
	l = parseMultitive(input)
	if isa(l, Parsed{Int}) && !isempty(l.rest) && l.rest[1] == '+'
		r = parseAdditive(l.rest[2:end])
		isa(r, Parsed{Int}) ? Parsed{Int}(l.value + r.value, r.rest) : NoParse{Int}
	else
		return l
	end
end

# ╔═╡ 101cd637-2a48-4274-bf06-6cf8a61729f8
md"""
Now try it for yourself:
"""

# ╔═╡ 8854c9cb-affb-42dc-b4d0-3423bddadbd2
@bind expression TextField()

# ╔═╡ 6c0ee3d1-f419-4c88-ab95-d95a46dd8758
filtered = filter(c -> !isspace(c), expression)

# ╔═╡ e5154a0b-1022-4320-a423-b6338dff79b3
parseAdditive(filtered)

# ╔═╡ 29f30785-dfe8-43eb-9b1b-8de17e6c368f
TODO("Need to visualize the call stack", heading="Call-stack representation")

# ╔═╡ 69899ad3-e64f-4945-9c7f-713fca9073de
md"""
## References and further reading

- [Bryan Ford's Packrat Parsing and PEG Page](https://bford.info/packrat/)
- [Wikipedia entry on Packrat parser](https://en.wikipedia.org/wiki/Packrat_parser)
- Warth, Alessandro; Douglass, James R.; Millstein, Todd: "Packrat Parsers Can Support Left Recursion". PEPM' 08. [URL](https://web.cs.ucla.edu/~todd/research/pepm08.pdf).
"""

# ╔═╡ 8eca6030-4427-45c6-b021-6b22943978d1
md"""
## Engine room

Below you'll find technical details required to run the page which are not necessary to understand the contents. Feel free to look under every rock you'll find :-)
"""

# ╔═╡ 0615c194-135d-4a46-b9ad-7a9399488307
# displays the table of contents floating box on the right
TableOfContents()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoTeachingTools = "~0.2.14"
PlutoUI = "~0.7.54"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0f748c81756f2e5e6854298f11ad8b2dfae6911a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.0"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "c0216e792f518b39b22212127d4a84dc31e4e386"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.5"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "e9648d90370e2d0317f9518c9c6e0841db54a90b"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.31"

[[LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "cad560042a7cc108f5a4c24ea1431a9221f22c1b"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "31e27f0b0bf0df3e3e951bfcc43fe8c730a219f6"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.4.5"

[[MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "89f57f710cc121a7f32473791af3d6beefc59051"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.14"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "71a22244e352aa8c5f0f2adde4150f62368a3f2e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.58"

[[PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "12aa2d7593df490c407a3bbd8b86b8b515017f3e"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.14"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─b340e590-5661-4f9b-88d6-fb51147dd907
# ╠═3044d9fa-bade-11ee-066c-e1e6ccf577e1
# ╠═a9835479-3fed-480d-9535-f5de0d3c10ca
# ╠═10c408bf-6e57-4d42-87ee-af3327b2c6ea
# ╟─b103ef8f-31a3-45c5-8086-a80b2cd14ae5
# ╠═4a34223c-6b23-494c-bd8b-67bcf9a171b3
# ╠═32c985b1-32b4-44f0-9597-07a38b3f619c
# ╠═1bd7e1b6-ed6c-4c7f-95c8-fbc5b88bdd98
# ╠═5ff05889-61e6-4981-ad86-41a37f302cd4
# ╠═8e6de62d-bf7c-4304-bdbf-6679d8c35fe7
# ╠═93b7488a-7065-43d4-8ca0-0ad57570134c
# ╠═83112978-9f28-419e-be92-a1c7d58558fe
# ╠═2cefab01-eeee-49e5-a987-46a4478ac096
# ╟─101cd637-2a48-4274-bf06-6cf8a61729f8
# ╠═8854c9cb-affb-42dc-b4d0-3423bddadbd2
# ╠═6c0ee3d1-f419-4c88-ab95-d95a46dd8758
# ╠═e5154a0b-1022-4320-a423-b6338dff79b3
# ╠═29f30785-dfe8-43eb-9b1b-8de17e6c368f
# ╠═69899ad3-e64f-4945-9c7f-713fca9073de
# ╟─8eca6030-4427-45c6-b021-6b22943978d1
# ╠═6e4ef6a6-73fb-416b-9963-f3c059c1651b
# ╠═0615c194-135d-4a46-b9ad-7a9399488307
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002