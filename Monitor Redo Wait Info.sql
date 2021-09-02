CREATE EVENT SESSION [redo_wait_info] ON SERVER
ADD EVENT sqlos.wait_info(
ACTION(package0.event_sequence,
sqlos.scheduler_id,
sqlserver.database_id,
sqlserver.session_id)
WHERE ( [opcode]=(1)

     AND sqlserver.session_id = (43)

       OR sqlserver.session_id = (48)

       OR sqlserver.session_id = (52)

       OR sqlserver.session_id = (67)

))
ADD TARGET package0.event_file(
SET filename=N'redo_wait_info')
WITH (MAX_MEMORY=4096 KB,
EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,
MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION [redo_wait_info] ON SERVER STATE=START
WAITFOR DELAY '00:02:00'
ALTER EVENT SESSION [redo_wait_info] ON SERVER STATE=STOP