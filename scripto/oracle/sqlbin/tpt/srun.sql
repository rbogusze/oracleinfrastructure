DEF cmd="&1"

VAR snapper REFCURSOR
@snapper4 stats,begin 1 1 &mysid

clear buffer
1 &cmd
/

@snapper4 stats,end 1 1 &mysid

