# ---+ Extensions
# ---++ SyntaxHighlightingPlugin

# **COMMAND M**
$Foswiki::cfg{Plugins}{SyntaxHighlightingPlugin}{EnscriptCommand} = '/usr/bin/enscript --color --language=html --output - --silent --highlight=%LANG|S% %FILENAME|F%';

# **BOOLEAN**
$Foswiki::cfg{Plugins}{SyntaxHighlightingPlugin}{Debug} = 0;
1;
