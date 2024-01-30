local utils = {}

local api = vim.api
local fmt = string.format
local lib = require("neotest.lib")
local async = require("neotest.async")
local logger = require("neotest.logging")
local patterns = require("neotest-go.patterns")

---Get a line in a buffer, defaulting to the first if none is specified
---@param buf number
---@param nr number?
---@return string
local function get_buf_line(buf, nr)
  nr = nr or 0
  assert(buf and type(buf) == "number", "A buffer is required to get the first line")
  return vim.trim(api.nvim_buf_get_lines(buf, nr, nr + 1, false)[1])
end

-- replace whitespace with underscores and remove surrounding quotes
function utils.transform_test_name(name)
  return name:gsub("[%s]", "_"):gsub('^"(.*)"$', "%1")
end

--- Converts from a given go package and the "/" seperated testname to a
--- format "package::test::subtest". Reverts changes made by suite support.
--- Returns the test in this format as well as the testname of the parent test (if present)
---@param package string
---@param test string
---@return string, string?
function utils.normalize_test_name(package, test)
  test = utils.suite_test_name_to_test_name(test)
  -- sub-tests are structured as 'TestMainTest/subtest_clause'
  local parts = vim.split(test, "/")
  return package .. "::" .. table.concat(parts, "::"), utils.get_parent_test(package, test)
end

--- Gets a parent test name from test. If there's no parent, returns nil
---@param package string
---@param test string
---@return string?
function utils.get_parent_test(package, test)
  local parts = vim.split(test, "/")
  if #parts < 2 then
    return nil
  end
  local parent_parts = vim.list_slice(parts, 1, #parts - 1)
  return package .. "::" .. table.concat(parent_parts, "::")
end

--- Decides if a test id reasonably belongs to a suite. If it does, returns a matching
--- path to be used with -run flag. If it doesn't, returns nil.
---@param id string
---@return string?
function utils.id_to_suite_test_name(id)
  local parts = vim.split(id, "::")
  parts = vim.list_slice(parts, 2, #parts)
  if #parts > 1 and string.match(parts[1], "Suite") then
    parts[1] = "Test" .. parts[1]
    return table.concat(parts, "/")
  end
  return nil
end

--- Decides if test name from output belonged to a suite. If it did, reverses
--- it back to normal form, if not, returns as-is
---@param name string
---@return string
function utils.suite_test_name_to_test_name(name)
  local parts = vim.split(name, "/")
  if #parts > 1 and string.match(parts[1], "Suite") then
    parts[1] = string.sub(parts[1], 5)
    return table.concat(parts, "/")
  end
  return name
end

--- Converts from a given neotest id and go_root / go_module to format
--- "package::test::subtest"
---@param id string
---@param go_root string
---@param go_module string
---@return string
function utils.normalize_id(id, go_root, go_module)
  local root = async.fn.substitute(id, go_root, go_module, "")
  local normalized_id, _ = root:gsub("/[%w_%-%.]*_test.go", "")
  return normalized_id
end

--- Checks if in the given lines contains an error pattern
---@param lines table
---@return boolean
function utils.is_error(lines)
  for _, line in ipairs(lines) do
    line = line:lower()
    for _, pattern in ipairs(patterns.error) do
      if line:match(pattern:lower()) then
        return true
      end
    end
  end
  return false
end

--- Checks if in the given line contains the patterns.testlog pattern
---@param line string
---@return boolean
function utils.is_test_logoutput(line)
  return line and line:match(patterns.testlog) ~= nil
end

---@return string
function utils.get_build_tags()
  local line = get_buf_line(0)
  local tag_format
  for _, item in ipairs({ "// +build ", "//go:build " }) do
    if vim.startswith(line, item) then
      tag_format = item
    end
  end
  if not tag_format then
    return ""
  end
  local tags = vim.split(line:gsub(tag_format, ""), " ")
  if #tags < 1 then
    return ""
  end
  return fmt("-tags=%s", table.concat(tags, ","))
end

function utils.get_go_package_name(_)
  local line = get_buf_line(0)
  return vim.startswith("package", line) and vim.split(line, " ")[2] or ""
end

--- gets the root directory of the go project
---@param start_file string
---@return string?
function utils.get_go_root(start_file)
  return lib.files.match_root_pattern("go.mod")(start_file)
end

--- gets the go module name
---@param go_root string
---@return string?
function utils.get_go_module_name(go_root)
  local gomod_file = go_root .. "/go.mod"
  local gomod_success, gomodule = pcall(lib.files.read_lines, gomod_file)
  if not gomod_success then
    logger.error("neotest-go: couldn't read go.mod file: " .. gomodule)
    return
  end
  for _, line in pairs(gomodule) do
    local module = line:match("module (.+)")
    if module then
      return module
    end
  end
end

--- Extracts the file name from a neotest id
---@param id string
---@return string
function utils.get_filename_from_id(id)
  local filename = string.match(id, "/([%w_-]*_test.go)::")
  return filename
end

--- Extracts testfile and linenumber of go test output in format
--- "    main_test.go:12: Some error message\n"
---@param line string
---@return string?, number?
function utils.get_test_file_info(line)
  if line then
    local file, linenumber = string.match(line, patterns.testfile)
    return file, tonumber(linenumber)
  end
  return nil, nil
end

--- Converts from test (as created by marshal_gotest_output) to error (as needed by neotest)
---@param test table
---@param file_name string
---@return table?
function utils.get_errors_from_test(test, file_name)
  if not test.file_output[file_name] then
    return nil
  end
  local errors = {}
  for line, output in pairs(test.file_output[file_name]) do
    if utils.is_error(output) then
      table.insert(errors, { line = line - 1, message = table.concat(output, "") })
    end
  end
  return errors
end

---@param tree neotest.Tree
---@param name string
---@return string
function utils.get_prefix(tree, name)
  local parent_tree = tree:parent()
  if not parent_tree or parent_tree:data().type == "file" then
    return name
  end
  local parent_name = parent_tree:data().name
  return parent_name .. "/" .. name
end

return utils
