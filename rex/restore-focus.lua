-- Gives focus back to the pane you were in once a popup closes.
-- Rex otherwise focuses the last pane of the tab when a popup's program exits.
-- Run with: rex do restore-focus.lua popup=<block id> origin=<block id>
-- A popup that already closed before this script started is not waited for,
-- and the wait gives up after a day so no process is left behind.
local one_day = 24 * 60 * 60
local _, popup_is_gone = rex.session.describe_block { block_id = rex.args.popup }
local closed = popup_is_gone or rex.wait('block_closed', { block_id = rex.args.popup }, one_day)
if closed then
  rex.session.focus_block { block_id = rex.args.origin }
end
