define _ed_tmp_editor="&_editor"
define _editor="&_editor"

ed &1

define _editor="&_ed_tmp_editor"
undefine _ed_tmp_editor

-- for unix use smth like:
--     define _editor="host xterm -c vi &1 &#"
-- or
--     define _editor="host nedit &1 &#"
