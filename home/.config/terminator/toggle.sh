#!/bin/bash

# Script to toggle terminator's visibility state, and bring to current
# workspace if necessary

# To use, add a keyboard shortcut that executes this script
# In Ubuntu, this is done in Settings > Keyboard > Shortcuts

TM_STATE=/tmp/tm_stat
WIN=$( wmctrl -lGx | awk '{print $1,$7}' | grep -i terminator | awk '{print $1}' );

if [[ $WIN == "" ]]
then
   terminator&
   exit 0
else

   if [[ -e $TM_STATE ]]
   then

      # Get the dimensions of a single workspace
      XDPYINFO_OUT=`xdpyinfo | grep 'dimensions:'`
      WORKSPACE_WIDTH=`echo "$XDPYINFO_OUT" | sed -r 's/.*:\s+([0-9]+)x.*/\1/'`
      WORKSPACE_HEIGHT=`echo "$XDPYINFO_OUT" \
          | sed -r 's/.*:\s+[0-9]+x([0-9]+).*/\1/'`
 
      # Get the X and Y offset of the current workspace
      XPROP_OUT=`xprop -root -notype _NET_DESKTOP_VIEWPORT`
      CURRENT_X=`echo "$XPROP_OUT" | sed -r 's/.*= ([0-9]+),.*/\1/'`
      CURRENT_Y=`echo "$XPROP_OUT" | sed -r 's/.*= [0-9]+,\s*([0-9]+).*/\1/'`
 
      # Get the coordinates of the top left corner of the window
      XWININFO_OUT=`xwininfo -id "$WIN"`
      WINDOW_X=`echo "$XWININFO_OUT" | grep 'Absolute upper-left X' \
          | sed -r 's/.*:\s+([0-9-]+).*/\1/'`
      WINDOW_Y=`echo "$XWININFO_OUT" | grep 'Absolute upper-left Y' \
          | sed -r 's/.*:\s+([0-9-]+).*/\1/'`
 
      # Calculate the new location of the window
      NEW_WINDOW_X=`echo "($CURRENT_X + ($WINDOW_X)) % $WORKSPACE_WIDTH" | bc`
      NEW_WINDOW_Y=`echo "($CURRENT_Y + ($WINDOW_Y)) % $WORKSPACE_HEIGHT" | bc`
 
      # Move the window to the new location and raise it
      wmctrl -i -r "$WIN" -e 10,"$NEW_WINDOW_X","$NEW_WINDOW_Y",-1,-1
      wmctrl -i -R "$WIN"

      rm $TM_STATE

   else
    
      # Minimize
      xdotool windowminimize $WIN

      touch $TM_STATE
   fi

fi
