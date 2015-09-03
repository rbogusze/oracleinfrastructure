VAR snapper REFCURSOR

DEF snr_query="&1"

@snapper stats,begin 1 1 &mysid
PROMPT RUNNING SELECT * FROM (&snr_query);;
SELECT * FROM (&snr_query);
@snapper stats,end 1 1 &mysid

