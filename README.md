# Tyloo's Dotfiles

This repository serves as my way to help me setup and maintain my Mac. It takes the effort out of installing everything manually. Everything needed to install my preferred setup of macOS is detailed in this readme. Feel free to explore, learn and copy parts for your own dotfiles. Enjoy! :smile:

## A Fresh macOS Setup

These instructions are for when you've already set up your dotfiles. If you want to get started with your own dotfiles you can [find instructions below](#your-own-dotfiles).

### Before you re-install

First, go through the checklist below to make sure you didn't forget anything before you wipe your hard drive.

- Did you commit and push any changes/branches to your git repositories?
- Did you remember to save all important documents from non-iCloud directories?
- Did you save all of your work from apps which aren't synced through iCloud?
- Did you remember to export important data from your local database?

### Installing macOS cleanly

After going to our checklist above and making sure you backed everything up, we're going to cleanly install macOS with the latest release. Follow [this article](https://www.imore.com/how-do-clean-install-macos) to cleanly install the latest macOS version.

### Setting up your Mac

If you did all of the above you may now follow these install instructions to setup a new Mac.

1. Update macOS to the latest version with the App Store
2. Install Xcode from the App Store, open it and accept the license agreement
4. Copy your public and private SSH keys to `~/.ssh` and make sure they're set to `600`
5. Clone this repo to `~/dotfiles`
6. Run `sh ~/dotfiles/install/setup.sh` to start the installation
8. Restart your computer to finalize the process

Your Mac is now ready to use!

## Your Own Dotfiles

If you want to start with your own dotfiles from this setup, it's pretty easy to do so. First of all you'll need to fork this repo. After that you can tweak it the way you want.

Go through [`install/macos.sh`](./install/macos.sh) and adjust the settings to your liking. You can find more settings in [the original script by Mathias Bynens](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) and [Kevin Suttle's macOS Defaults project](https://github.com/kevinSuttle/MacOS-Defaults).

Check out [`dotfiles/.Brewfile`](./dotfiles/.Brewfile) and adjust the apps you want to install for your machine.

Check out [`dotfiles/aliases.zsh`](./dotfiles/aliases.zsh) to add aliases. If you need to tweak your `$PATH`, edit [`dotfiles/path.zsh`](./dotfiles/path.zsh). Adjust [`dotfiles/.zshrc`](./dotfiles/.zshrc) to customize Oh My Zsh, and [`dotfiles/.zshenv`](./dotfiles/.zshenv) for Zsh environment setup. More information about customizing Oh My Zsh is [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Customization).

Enjoy your own Dotfiles!

## Thanks To...

I first got the idea for starting this project by visiting the [Github does dotfiles](https://dotfiles.github.io/) project. Both [Zach Holman](https://github.com/holman/dotfiles) and [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) were great sources of inspiration. Also, these dotfiles are forked from [Dries Vints](https://github.com/driesvints/dotfiles)!
[Sourabh Bajaj](https://twitter.com/sb2nov/)'s [Mac OS X Setup Guide](http://sourabhbajaj.com/mac-setup/) proved to be invaluable. Thanks to [@denysdovhan](https://github.com/denysdovhan) for [his awesome Zsh theme](https://github.com/denysdovhan/spaceship-prompt)! And lastly, I'd like to thank [Maxime Fabre](https://twitter.com/anahkiasen) for [his excellent presentation on Homebrew](https://speakerdeck.com/anahkiasen/a-storm-homebrewin) which made me migrate a lot to a [`Brewfile`](./dotfiles/.Brewfile).

In general, I'd like to thank every single one who open-sources their dotfiles for their effort to contribute something to the open-source community. Your work means the world! :earth_africa: :heart:
