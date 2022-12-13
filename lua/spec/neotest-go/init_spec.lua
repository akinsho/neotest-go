local async = require("plenary.async.tests")
local plugin = require("neotest-go")

describe(
    "is_test_file",
    function()
        it(
            "matches Go files",
            function()
                assert.equals(true, plugin.is_test_file("foo_test.go"))
            end
        )
    end
)

describe(
    "discover_positions",
    function()
        async.it(
            "discovers positions in unit tests in many_table_test.go",
            function()
                local path = vim.loop.cwd() .. "/neotest_go/many_table_test.go"
                local positions = plugin.discover_positions(path):to_list()

                local expected_positions = {
                    {
                        id = vim.loop.cwd() .. "/neotest_go/many_table_test.go",
                        name = "many_table_test.go",
                        path = vim.loop.cwd() .. "/neotest_go/many_table_test.go",
                        range = {0, 0, 32, 0},
                        type = "file"
                    },
                    {
                        {
                            id = vim.loop.cwd() .. "/neotest_go/many_table_test.go::TestSomeTest",
                            name = "TestSomeTest",
                            path = vim.loop.cwd() .. "/neotest_go/many_table_test.go",
                            range = {8, 0, 31, 1},
                            type = "test"
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/many_table_test.go::TestSomeTest::AccessDenied1",
                                name = '"AccessDenied1"',
                                path = vim.loop.cwd() .. "/neotest_go/many_table_test.go",
                                range = {16, 2, 16, 118},
                                type = "test"
                            }
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/many_table_test.go::TestSomeTest::AccessDenied2",
                                name = '"AccessDenied2"',
                                path = vim.loop.cwd() .. "/neotest_go/many_table_test.go",
                                range = {17, 2, 17, 118},
                                type = "test"
                            }
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/many_table_test.go::TestSomeTest::AccessDenied3",
                                name = '"AccessDenied3"',
                                path = vim.loop.cwd() .. "/neotest_go/many_table_test.go",
                                range = {18, 2, 18, 118},
                                type = "test"
                            }
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/many_table_test.go::TestSomeTest::AccessDenied4",
                                name = '"AccessDenied4"',
                                path = vim.loop.cwd() .. "/neotest_go/many_table_test.go",
                                range = {19, 2, 19, 118},
                                type = "test"
                            }
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/many_table_test.go::TestSomeTest::AccessDenied5",
                                name = '"AccessDenied5"',
                                path = vim.loop.cwd() .. "/neotest_go/many_table_test.go",
                                range = {20, 2, 20, 118},
                                type = "test"
                            }
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/many_table_test.go::TestSomeTest::AccessDenied6",
                                name = '"AccessDenied6"',
                                path = vim.loop.cwd() .. "/neotest_go/many_table_test.go",
                                range = {21, 2, 21, 118},
                                type = "test"
                            }
                        }
                    }
                }
                assert.are.same(positions, expected_positions)
            end
        )
        async.it(
            "discovers positions in unit tests in cases_test.go",
            function()
                local path = vim.loop.cwd() .. "/neotest_go/cases_test.go"
                local positions = plugin.discover_positions(path):to_list()
                local expected_positions = {
                    {
                        id = vim.loop.cwd() .. "/neotest_go/cases_test.go",
                        name = "cases_test.go",
                        path = vim.loop.cwd() .. "/neotest_go/cases_test.go",
                        range = {0, 0, 49, 0},
                        type = "file"
                    },
                    {
                        {
                            id = vim.loop.cwd() .. "/neotest_go/cases_test.go::TestSubtract",
                            name = "TestSubtract",
                            path = vim.loop.cwd() .. "/neotest_go/cases_test.go",
                            range = {8, 0, 33, 1},
                            type = "test"
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/cases_test.go::TestSubtract::test_one",
                                name = '"test one"',
                                path = vim.loop.cwd() .. "/neotest_go/cases_test.go",
                                range = {15, 2, 20, 3},
                                type = "test"
                            }
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/cases_test.go::TestSubtract::test_two",
                                name = '"test two"',
                                path = vim.loop.cwd() .. "/neotest_go/cases_test.go",
                                range = {21, 2, 26, 3},
                                type = "test"
                            }
                        }
                    },
                    {
                        {
                            id = vim.loop.cwd() .. "/neotest_go/cases_test.go::TestAdd",
                            name = "TestAdd",
                            path = vim.loop.cwd() .. "/neotest_go/cases_test.go",
                            range = {35, 0, 48, 1},
                            type = "test"
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/cases_test.go::TestAdd::test_one",
                                name = '"test one"',
                                path = vim.loop.cwd() .. "/neotest_go/cases_test.go",
                                range = {36, 1, 38, 3},
                                type = "test"
                            }
                        },
                        {
                            {
                                id = vim.loop.cwd() .. "/neotest_go/cases_test.go::TestAdd::test_two",
                                name = '"test two"',
                                path = vim.loop.cwd() .. "/neotest_go/cases_test.go",
                                range = {40, 1, 42, 3},
                                type = "test"
                            }
                        }
                    }
                }

                assert.are.same(positions, expected_positions)
            end
        )
    end
)

