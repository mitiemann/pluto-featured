abstract type Result{V} end

struct NoParse{V} <: Result{V} end

struct Parsed{V} <: Result{V}
	value::V
	rest::String
end

function parseDecimal(input)
	alldigits = "0123456789"
	if !isempty(input) && occursin(input[1], alldigits)
		return Parsed{Int}(parse(Int, input[1]), input[2:end])
	else
		return NoParse{Int}()
	end
end

function parsePrimary(input)
	if !isempty(input) && input[1] == '(' && input[end] == ')'
		return parseAdditive(input[2:end-1])
	else
		return parseDecimal(input)
	end
end

function parseMultitive(input)
	l = parsePrimary(input)
	if isa(l, Parsed{Int}) && !isempty(l.rest) && l.rest[1] == '*'
		r = parseMultitive(l.rest[2:end])
		isa(r, Parsed{Int}) ? Parsed{Int}(l.value * r.value, r.rest) : NoParse{Int}
	else
		return l
	end
end

function parseAdditive(input)
	l = parseMultitive(input)
	if isa(l, Parsed{Int}) && !isempty(l.rest) && l.rest[1] == '+'
		r = parseAdditive(l.rest[2:end])
		isa(r, Parsed{Int}) ? Parsed{Int}(l.value + r.value, r.rest) : NoParse{Int}
	else
		return l
	end
end

parseAdditive("2*(3+4)")
parseAdditive("(3+4)*2") # TODO why is this failing?

# I don't know yet how this works
# function applyRule(r, p)
# 	m = memo(r, p)
# 	if isa(m, missing)

# 	else
# 		return m.ans
# 	end
# end
