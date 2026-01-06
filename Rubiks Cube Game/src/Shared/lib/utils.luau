local utils = {}

function utils.deep_copy(t: table)
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = utils.deep_copy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

function utils.compare_tables(t1: table, t2: table)
	for k, v in pairs(t1) do
		if type(v) == "table" then
			if not utils.compare_tables(v, t2[k]) then
				return false
			end
		else
			if v ~= t2[k] then
				return false
			end
		end
	end
	return true
end

function utils.find_first_in_dictionary(t, value)
	for k, v in pairs(t) do
		if v == value then
			return k
		end
	end
	return nil
end

return utils
