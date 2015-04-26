# dfm
Dotfile Manager

This is a simple dotfile tracker. The master script (``bin/dfm.sh``) handles installation,
pulling in updates from Git, and pushing out local updates to Git.

Layout:

    bin/
        dfm.sh         # The main script.
    data/
        your dotfiles  # e.g; .zshrc, .vimrc, .gitconfig
    secure/
        "secure files" # e.g; .ssh/authorized_keys2

To install dfm (installs in ``${HOME}/bin`` and your dotfiles from ``data/``)
> % bin/dfm.sh -i

To upgrade:
> % dfm -p

After you've made a local change:
> % dfm -u


Other flags:

    -c: Add a cron job to automatically pull dotfile changes.
    -s: Update secure files.
    -t: Automatically timeout (useful for -p only).

At the moment, adding new dotfiles or renaming them is a frustration. This is an area for improvement
