local iter_env_vars = require('cmp_env.util').iter_env_vars
local file = assert(io.open('./tests/cmp_env/cases/expected_values.json', 'r'))
local expected = vim.json.decode(file:read("*a"))
file:close()
describe(string.format('Test iter_env_vars for a files with %s environment variables:', #expected), function()
  local length
  local cases
  before_each(function()
    cases = vim.deepcopy(expected)
  end)
  it('read and parse env(with export) file', function()
    for k, v in iter_env_vars('./tests/cmp_env/cases/test_envs') do
      -- vim.print({ k, v }, "\n----\n")
      local case = table.remove(cases, 1)
      -- io.write(vim.inspect(case))
      assert.are.same(case, { k, v })
      -- print("\x1b[1;32m V\x1b[0m")
    end
    -- parsed the expected number of environment variables
    assert.are.equal(0, #cases)
  end)
  it('read and parse env(with export) file with comments', function()
    for k, v in iter_env_vars('./tests/cmp_env/cases/test_envs_with_comments') do
      -- vim.print({ k, v }, "\n----\n")
      local case = table.remove(cases, 1)
      -- io.write(vim.inspect(case))
      assert.are.same(case, { k, v })
      -- print("\x1b[1;32m V\x1b[0m")
    end
    -- parsed the expected number of environment variables
    assert.are.equal(0, #cases)
  end)
  it('read and parse env(without export) file', function()
    for k, v in iter_env_vars('./tests/cmp_env/cases/test_envs_without_export') do
      -- vim.print({ k, v }, "\n----\n")
      local case = table.remove(cases, 1)
      -- io.write(vim.inspect(case))
      assert.are.same(case, { k, v })
      -- print("\x1b[1;32m V\x1b[0m")
    end
    -- parsed the expected number of environment variables
    assert.are.equal(0, #cases)
  end)
  it('read and parse env(without export) file with comments', function()
    for k, v in iter_env_vars('./tests/cmp_env/cases/test_envs_without_export_with_comments') do
      -- vim.print({ k, v }, "\n----\n")
      local case = table.remove(cases, 1)
      -- io.write(vim.inspect(case))
      assert.are.same(case, { k, v })
      -- print("\x1b[1;32m V\x1b[0m")
    end
    -- parsed the expected number of environment variables
    assert.are.equal(0, #cases)
  end)
end)
