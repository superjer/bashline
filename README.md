Bashline
========

Tiny, fast Powerline-like Bash prompt with max exec time

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

Install Bashline
----------------

  Add this to your .bashrc (use full path to bashline.sh):

    PROMPT_COMMAND='PS1=$(bashline.sh "$?" "$(__git_ps1)")'

Personalize
-----------

  Customize your hosts colors and fav dirs below. Bash 4+ only.

Note
----

  Bashline will attempt to degrade gracefully if there are missing
  dependencies. If you are missing a feature, you probably need to
  install or upgrade the relevant program.
