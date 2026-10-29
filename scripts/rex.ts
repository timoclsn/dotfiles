// Rex sets REX_SESSION in its terminals and tmux sets TMUX in its panes. tmux
// running inside a Rex terminal has both, and counts as tmux.
export const runsInRex = () => !process.env.TMUX && !!process.env.REX_SESSION;
