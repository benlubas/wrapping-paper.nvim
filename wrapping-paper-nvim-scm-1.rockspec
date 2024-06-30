local MODREV, SPECREV = "scm", "-1"
rockspec_format = "3.0"
package = "wrapping-paper.nvim"
version = MODREV .. SPECREV

description = {
	summary = "Temporarily wrap a single line at a time with floating windows and virtual text trickery",
	labels = { "neovim" },
	homepage = "https://github.com/benluas/wrapping-paper.nvim",
	license = "MIT",
}

source = {
	url = "http://github.com/benlubas/wrapping-paper.nvim/archive/v" .. MODREV .. ".zip",
}

if MODREV == "scm" then
	source = {
		url = "git://github.com/benlubas/wrapping-paper.nvim",
	}
end

dependencies = {
	"nui.nvim ~> 0",
}
