require('boole').setup {
  mappings = {
    increment = '<C-a>',
    decrement = '<C-x>',
  },
  additions = {
    { 'production', 'development', 'test' },
    { 'prod', 'staging', 'develop', 'test', 'test2', 'test3', 'test4' },
    { 'let', 'const' },
    { 'start', 'end' },
    { 'import', 'export' },
    { 'before', 'after' },
    { 'plus', 'minus' },
    { 'left', 'right' },
    { 'FIX', 'TODO', 'HACK', 'WARN', 'PERF', 'NOTE', 'TEST' },
  },
}
