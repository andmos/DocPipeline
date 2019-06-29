CONTEXT_HOME=/opt/context
. $CONTEXT_HOME/tex/setuptex > /dev/null 2>&1

export OSFONTDIR="/usr/share/fonts//;$HOME/.fonts//;$OSFONTDIR"
export TEXMFCACHE="$CONTEXT_HOME/tex/texmf-cache"
