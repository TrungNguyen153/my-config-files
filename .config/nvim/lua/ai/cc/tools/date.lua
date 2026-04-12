local handlers = require('ai.cc.utils')

--- Parse an operation string like "+1d", "-3m", "+2w" into {sign, number, metric}
local function parse_operation(op)
    local sign_str, num_str, metric = op:match('^([+-])(%d+)([ymwdHMS])$')
    if not sign_str then
        return nil, 'Invalid operation format: ' .. op
    end
    local value = tonumber(num_str)
    if sign_str == '-' then
        value = -value
    end
    return { value = value, metric = metric }
end

--- Map metric character to os.date table field and multiplier
local metric_map = {
    y = 'year',
    m = 'month',
    w = 'day', -- weeks are converted to days (* 7)
    d = 'day',
    H = 'hour',
    M = 'min',
    S = 'sec',
}

return handlers.create_tool({
    name = 'date',
    description = 'Provide date calculations based on today',
    properties = {
        format = {
            type = 'string',
            description = 'Date format using Lua os.date specifiers (strftime). Example: %A, %d. %B %Y at %H:%M:%S to get for example Tuesday, 26. August 2025 at 20:36:19',
        },
        operations = {
            type = 'array',
            description = 'Array of operations to add/subtract from the date',
            items = {
                type = 'string',
                description = [[Each operation to execute. Follows the format of [+|-][NUMBER][METRIC]. Where:
+ means add and - means minus
NUMBER is the value to be added or subtracted
METRIC means what field should be operated on (month, day, hour, etc). Possible values are: y|m|w|d|H|M|S
y: year
m: month
w: week
d: day
H: hour
M: minute
S: second]],
            },
        },
    },
    ui_log = '󰸗 Date',
    func = function(_, schema_params, opts)
        local output_handler = opts.output_cb
        local operations = schema_params.operations or {}
        local format = schema_params.format or '%Y-%m-%d %H:%M:%S'

        -- Start with current time as a table
        local t = os.date('*t')

        -- Apply each operation
        for _, op_str in ipairs(operations) do
            local parsed, err = parse_operation(op_str)
            if not parsed then
                output_handler({ status = 'error', data = err })
                return
            end

            local field = metric_map[parsed.metric]
            local value = parsed.value
            if parsed.metric == 'w' then
                value = value * 7
            end

            t[field] = t[field] + value
        end

        -- os.time normalizes overflows (e.g., month 13 → Jan next year)
        local timestamp = os.time(t)
        local result = os.date(format, timestamp)

        output_handler({ status = 'success', data = result or '' })
    end,
    system_prompt = [[Perform date calculations and formatting. This tool allows you to get the current date/time with custom formatting and perform relative date calculations. Works on all platforms (Windows, macOS, Linux).

**Formatting**: Use the `format` parameter with standard strftime specifiers (e.g., "%Y-%m-%d" for 2025-01-15, "%A, %d. %B %Y at %H:%M:%S" for "Tuesday, 26. August 2025 at 20:36:19").

**Operations**: Use the `operations` array to add or subtract time from the current date. Each operation follows the format `[+|-][NUMBER][METRIC]`:
- `+` to add, `-` to subtract
- NUMBER: the value to add/subtract
- METRIC: y (year), m (month), w (week), d (day), H (hour), M (minute), S (second)

Examples:
- Get tomorrow: operations: ["+1d"]
- Get date 3 months ago: operations: ["-3m"]
- Get date 2 weeks and 3 days from now: operations: ["+2w", "+3d"]

All operations are read-only and execute immediately. This is useful for scheduling, date calculations, and generating timestamps.]],
})
