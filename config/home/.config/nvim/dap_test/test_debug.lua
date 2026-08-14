local numbers = { 1, 2, 3, 4 }
local total = 0

for index, value in ipairs(numbers) do
  local doubled = value * 2
  total = total + doubled
  print(("loop %d: val e=%d doubled=%d total=%d"):format(index, value, doubled, total))
end

local function summarize(sum, count)
  local average = sum / count
  local status = average > 4 and "large" or "small"

  return {
    sum = sum,
    average = average,
    status = status,
  }
end

local result = summarize(total, #numbers)
print(("summary: sum=%d average=%.1f status=%s"):format(result.sum, result.average, result.status))
