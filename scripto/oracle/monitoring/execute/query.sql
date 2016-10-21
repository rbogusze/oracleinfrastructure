select count(*) from APPS.GL_JE_BATCHES AS OF TIMESTAMP to_timestamp('&1','YYYY-MM-DD--HH24:MI:SS') a where a.JE_BATCH_ID=228639;
