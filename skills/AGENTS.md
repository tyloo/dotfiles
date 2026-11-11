# Local skill maintenance

After editing a skill here, refresh its installed copy from the local checkout with `pnpx skills@latest add ~/dotfiles --skill <name> --global --agent <existing-agent-ids> --yes`. Refresh only the edited skills and preserve their installed agent targets, listed by `pnpx skills@latest list --global --json`. Verify the installed skill and bundled files match the source before reporting done.
