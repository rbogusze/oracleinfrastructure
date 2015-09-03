select latch#, name, level# from v$latch where latch# in (&1);
