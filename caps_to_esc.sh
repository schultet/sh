#!/bin/bash

# map caps-lock-key to escape-key (improving vim experience)
xmodmap -e 'clear Lock'
xmodmap -e 'keycode 9 = Escape'
xmodmap -e 'keycode 66 = Escape'
