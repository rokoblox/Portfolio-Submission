local debug_utils = {}

function debug_utils.print_2d_table(t: table)
	for y, row in pairs(t) do
		print(string.format("%d: {%s}", y, table.concat(row, ", ")))
	end
end

return debug_utils
