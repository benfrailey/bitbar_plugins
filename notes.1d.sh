#!/bin/bash

#<bitbar.title>Notes</bitbar.title>
#<bitbar.version>v1.0</bitbar.version>
#<bitbar.author>Kevin Bowers</bitbar.author>
#<bitbar.author.github>kevinbowers73</bitbar.author.github>
#<bitbar.desc>A simple plugin to store single line notes</bitbar.desc>
#<bitbar.image>https://i.imgur.com/NFSsKs6.png</bitbar.image>
#<bitbar.dependencies>bash</bitbar.dependencies>
#<bitbar.abouturl></bitbar.abouturl>



# Variable for path of notes file
# !!! Change the file path to whatever you want. For ease of use and plug 'n' play functionality, the default is the home directory
notefile=~/.notes.txt

# Ensures notes.txt exists
touch $notefile

# Create variable which refreshes only the notes.sh plugin
refresh="open bitbar://refreshPlugin?name=notes.1d.sh"

# Function to delete the selected note
if [ "$1" = "delete" ]; then
    # equivalent to: sed -i '' <linenumber>d ~/bitbar_plugins/support_files/notes.txt
    sed -i '' "$2""$3" $notefile
    $refresh
fi

# Function to copy note to clipboard
## Note: for some unknown reason, it adds a new line character (\n) to the end of what is copied
if [ "$1" = "copy" ]; then
    sed -n "$2""$3" $notefile | pbcopy
fi

# Function that overrites the notes.txt file with nothing, clearing all notes
if [ "$1" = "clear" ]; then
    true > "$notefile"
    $refresh
fi

# Function to create new note
if [ "$1" = "new" ]; then
    # Opens a system dialog box and saves input to notes file
	text=$(osascript -e 'Tell application "System Events" to display dialog "New Note:" default answer "" ' -e 'text returned of result')
	if [ "$text" != "" ]; then
		echo "$text" >> $notefile
	fi
	$refresh
fi

lineNum=0;
while read -r line; do
    lineNum=$((lineNum+1))
done < $notefile

if [ "$lineNum" = "1" ]; then
echo "To Do - 1 Task"
echo "---"
else
echo "To Do - $lineNum Tasks"
echo "---"
fi

# variable to track which line is being read
lineNum=1;

# Read through every line of the file
while read -r line; do
    echo "$line | color=#6F6F6F bash=$0 param1=copy param2=$lineNum param3=p terminal=false"
    echo "--Delete | bash=$0 param1=delete param2=$lineNum param3=d terminal=false"
    lineNum=$((lineNum+1))
done < $notefile

echo "---"
echo "New Note | bash=$0 param1=new terminal=false"

# Function which only displays the option to clear notes if at least one note exists
if [ -s $notefile ]; then
echo "Clear Notes | color=red"
echo "--I'm sure | bash=$0 param1=clear terminal=false"
fi



echo ---
echo "Edit plugin | bash=$0 param1=edit terminal=false "
if [ "$1" = "edit" ]; then
    open "${0}"
fi
