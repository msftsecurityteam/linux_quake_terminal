# linux_quake_terminal
Quake-style scroll down terminal from top of desktop for Linux. This shellscript
configures a terminal to "slide" down from the top of the desktop screen, slow
enough to where you can see it scroll down like a "scroll" of paper being
unfolded. Fans of Quake 2 will know what I'm talking about.

## Why?
Why not?

## Does it work with any terminal?
This should work with any terminal, yes. I was using *alacritty* for a while
with this setup, but now I have it configured out of the box to be working
with *kitty*.

## What about window manager?
I have only tested this on awesomewm, but conceivably this should work with
any window manager.

## How does it work?
I have step-by-step instructions below for getting this setup exactly how I have
setup on my machine (awesomewm+kitty), but overall this works by using common
X11 tools (**xprop**, **xdotool**)  combined with a simple bash script to
toggle a terminal that starts at 1% height, and via `for-loop`, slowly (or quickly)
increase the height of the terminal to the desired percentage (*default: 30%*).

## Installation instructions
1. Place the `quake-terminal.sh` file in `~/.config/quake-terminal.sh`.
2. chmod 755 ~/.config/quake-terminal.sh
3. Make changes to `quake-terminal.sh` you may want (such as terminal emulator
change, speed the quake terminal opens, size of quake terminal, etc.)
4. Set a key-binding in your window manager's settings to run this shell script
(probably want to bind it with ~ for moar of that Quake 2 nostalgia).

## Example setup with awesomewm
1. I have bound my kitty-quake terminal to be ran when I hit my `Mod + ~` key-binding (awesomewm
users should know what I mean by Mod-key). That is found in my `~/.config/awesomewm/rc.lua`:

```
[...]
-- Bind Quake-dropdown terminal to key                                      
    awful.key({ modkey }, "`", function() run_once({"/home/m/.config/quake_term.sh"}) end,
             {description = "Toggle dropdown terminal", group = "launcher"}),
[...]
```
2. Further down the `rc.lua` file, you will find generic rules that are applied
to new clients in awesomewm. Add the following rule to make sure your kitty-quake
is always set to floating:

```
awful.rules.rules = {
[...]
{ rule = { instance = "kitty_launcher" }, properties = { floating = true } },
[...]
}
```
This rule is specific to awesomewm (and im sure similar for other tiling WMs like
i3 because if this rule is not specified, as soon as you launch your
kitty-quake, it will become tiled and stuck on your desktop.

## Caveats
- As briefly mentioned above, rather than setting kitty's *class* to XYZ, I set the
**classname** to XYZ. The difference between the two are that in x11, you can set
the WM_CLASS property, and the WM_NAME property. Typically, the name of a
program will be the WM_CLASS property (in kitty's case, WM_CLASS = kitty by default, WM_NAME
is unset by default). Most terminal emulators allow you to set both, and to not
get in the way of the window manager or other utilities, I decided to use the
WM_NAME / classname portion.

- Try to keep other windows further from the top of the screen than the bottom --
some terminals will notice there is more room on the bottom and start from there
instead of the top of the screen.

## Troubleshooting
I whipped this README.md up really fast. Honestly, this should be pretty straight-
forward on getting it to work. But if you find any bugs, have any problems, or
have questions, feel free to reach out to me at `@DUK3NUK3M` on Telegram or
`blackh4t@icloud.com`.
