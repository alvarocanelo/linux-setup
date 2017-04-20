HISTSIZE=10000
HISTFILESIZE=10000
if [ -f ~/.alvaro-toshiba_utils.sh ] && [ -r ~/.alvaro-toshiba_utils.sh ] ; then
    source  $HOME/.alvaro-toshiba_utils.sh
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

aliasfile_list="
$HOME/.bash_aliases
$HOME/.bash_functions
$HOME/.vu_remote
$HOME/.bash_profile_course_udacity_git_and_github
"
for aliasfile in $aliasfile_list ; do
    if [ -r $aliasfile ] ; then
	    source $aliasfile
    else
        echo "Alias file [$aliasfile] does not exist or is not readable."
        echo "Skipping it from alises sourcing."
    fi
done

PATH="$PATH":/usr/local/bin/venues_utils
