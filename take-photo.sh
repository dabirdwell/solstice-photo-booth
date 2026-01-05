#!/bin/bash
# Takes a photo via Lumix Tether by clicking the shutter button
# Works regardless of window position

osascript << 'EOF'
tell application "LUMIX Tether" to activate
delay 0.3
tell application "System Events"
    tell process "LUMIX Tether"
        -- Find the GH5 window (name contains "DC-GH5")
        set tetheredWindow to missing value
        repeat with w in windows
            if name of w contains "DC-GH5" then
                set tetheredWindow to w
                exit repeat
            end if
        end repeat
        
        if tetheredWindow is missing value then
            error "Camera not connected - window not found"
        end if
        
        -- Get window position
        set winPos to position of tetheredWindow
        set winX to item 1 of winPos
        set winY to item 2 of winPos
        
        -- Camera button is roughly 275px from left, 140px from top
        set clickX to winX + 275
        set clickY to winY + 140
        
        do shell script "/opt/homebrew/bin/cliclick c:" & clickX & "," & clickY
    end tell
end tell
return "Photo triggered"
EOF
