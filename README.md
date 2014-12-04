Bashline
========

Tiny, fast Powerline-like Bash prompt with max exec time

![Bashline image](http://www.superjer.com/lies/bashline.png)

What you get
------------

  * Color-coded hostnames when you SSH to different machines.
  * Powerline-like path with abbreviations for favorite dirs.
  * Git branch, detached head, merge- or rebase-state (__git_ps1).
  * Color-coded Git working dir indicators:
      * D - dirty   - blue  - tracked files have modifications
      * I - index   - green - files have been indexed / added
      * U - unknown - red   - untracked files present
  * Git status is not allowed to take more than 1 second.
      * If it takes too long you will see a ? instead of D/I/U.
  * Error code from last ran command ($?).

Dependencies (you should already have these)
--------------------------------------------

  * 256-color term  - needed for this to work at all
  * git             - to enable working dir status indicators
  * __git_ps1       - to see branch name, merge status, etc.
  * timeout         - to enable max exec time feature
  * Bash 4+         - to enable host colors, fav dirs, & Git status colors

Powerline Fonts
---------------

  You need to install a font with the special Powerline symbols.

  <https://github.com/Lokaltog/powerline-fonts>

  Fonts only need to be installed on your client machine. If you are using
  SSH there is no need to install the fonts on the remote machine.

Install and personalize Bashline
--------------------------------

  To install, just source bashline.sh in your .bashrc file.

  Here's an example that also adds host colors and favorite dirs: (Bash 4+ required)

    # .bashrc contents
    . /path/to/bashline.sh
    bashline_hosts[lala]="230 128" # 230 foreground, 128 background
    bashline_hosts[lois]="201 55"
    bashline_hosts[clark]="231 160"
    bashline_hosts[swamp]="148 22"
    bashline_hosts[xenon]="160 234"
    bashline_hosts[kristi]="17 214"
    bashline_hosts[tengen]="231 198"
    bashline_hosts[creeper]="16 112"
    bashline_hosts[infocom]="226 211"
    bashline_hosts[krypton]="99 54"
    bashline_hosts[macpork]="87 99"
    bashline_hosts[icecrown]="51 18"
    bashline_hosts[magellan]="226 202"
    bashline_hosts[ferdinand]="88 172"
    bashline_hosts[swingline]="124 228"
    bashline_hosts[snickerdoodle]="214 25"
    bashline_favs[/var/www/html/superjer.com]="♥ j"
    bashline_favs[/var/www/html/mcdiddys.com]="♥ mcd"
    bashline_favs[/weirdly/long/path/that/makes/the/prompt/sad]="♥ a short name"

  256-color terminal palette in pictures:

    <http://blog.yjl.im/2013/02/terminal-256-colors-scripts.html>

  You can also shorten host and usernames to your liking:

    # .bashrc again
    bashline_shorten=5  # shorten to just 5 characters

Note
----

  Bashline will attempt to degrade gracefully if there are missing
  dependencies. If you are missing a feature, you probably need to
  install or upgrade the relevant program.
