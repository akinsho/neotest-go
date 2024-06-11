local M = {}

local fmt = string.format
local colors_patterns = require("neotest-go.patterns").colors

local term = os.getenv("COLORTERM")
local fullcolor = (term == "truecolor") or (term == "24bit")

-- Function:	hex_to_rgb(arg)
-- Argument:	Hex string value in the form '#cccccc' or 'cccccc'
-- 						HEX shorthand is supported
-- Returns:		Three RGB values
-- 						Red value from 0-255
-- 						Green value from 0-255
-- 						Blue value from 0-255
-- Source:    forum.rainmeter.net/viewtopic.php?t=29419
local function hex_to_rgb(hexArg)
  hexArg = hexArg:gsub("#", "")
  if string.len(hexArg) == 3 then
    return tonumber("0x" .. hexArg:sub(1, 1)) * 17,
      tonumber("0x" .. hexArg:sub(2, 2)) * 17,
      tonumber("0x" .. hexArg:sub(3, 3)) * 17
  elseif string.len(hexArg) == 6 then
    return tonumber("0x" .. hexArg:sub(1, 2)),
      tonumber("0x" .. hexArg:sub(3, 4)),
      tonumber("0x" .. hexArg:sub(5, 6))
  else
    return 0, 0, 0
  end
end

-- Get color from config, of default if not present in config.
-- @param config {}
-- @param section string
-- @param color_class string
-- @return string
local function get_color(config, section, index, color_class)
  local color = colors_patterns[section][color_class]
  if
    config[section] ~= nil
    or config[section][color_class] ~= nil and #config[section][color_class] ~= 0
  then
    color = config[section][color_class]
  end
  if type(color) ~= "table" then
    return color
  end
  return color[index]
end

-- Add 24bit console color to a line.
-- @param line string
-- @param hex_color string
-- @return string
local function add_24bit_color(line, hex_color)
  local r, g, b = hex_to_rgb(hex_color)
  local start_code = fmt("[38;2;%d;%d;%dm", r, g, b)
  local end_code = "[0m"
  return start_code .. line .. end_code
end

-- Add 8bit term color to a line.
--@param line string
--@param color string
--@return string
local function add_8bit_color(line, color)
  local start_code = fmt("[%dm", color)
  local end_code = "[0m"
  return start_code .. line .. end_code
end

-- Colorize a line.
-- @param line string
-- @param config table
-- @param section string
-- @return string
local function add_color(section, line, config, i)
  if fullcolor then
    local color = get_color(config, section, i, "gui")
    return add_24bit_color(line, color)
  end
  local color = get_color(config, section, i, "term")
  return add_8bit_color(line, color)
end

local function is_table(a)
  return type(a) == "table"
end

-- Highlight output.
-- @param output string
-- @param config table
-- @return string
function M.highlight_output(output, opts)
  if not output then
    return output
  end
  -- Fetch patterns
  local config = colors_patterns
  if is_table(opts) and opts.colors ~= nil then
    config = opts.colors
  end
  -- Iterate over all patterns to colorize
  for name, c in pairs(colors_patterns) do
    local res = { output:find(c.pattern) }
    if #res > 2 then
      -- Colorize all groups in pattern
      for i, match_group in ipairs(vim.list_slice(res, 3)) do
        local colorized = add_color(name, match_group, config, i)
        output = output:gsub(vim.pesc(match_group), vim.pesc(colorized))
      end
    elseif #res > 0 then
      output = add_color(name, output, config)
    end
  end
  return output
end

return M
