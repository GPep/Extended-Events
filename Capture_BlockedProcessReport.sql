EXECUTE sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXECUTE sp_configure 'blocked process threshold', 15;
GO
RECONFIGURE;
GO
EXECUTE sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO


/*
check to see if the event session exists
*/
IF EXISTS ( SELECT  1
FROM    sys.server_event_sessions
WHERE   name = 'Capture_BlockedProcessReport' )
DROP EVENT SESSION [Capture_BlockedProcessReport] ON SERVER;
GO
 
/*
create the event session
edit the filename entry if C:\temp is not appropriate
*/
CREATE EVENT SESSION [Capture_BlockedProcessReport]
ON SERVER
ADD EVENT sqlserver.blocked_process_report
ADD TARGET package0.event_file(
SET filename=N'C:\Temp\Capture_BlockedProcessReport.xel'
)
WITH (MAX_MEMORY=8192 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO
 
/*
start the event session
*/
ALTER EVENT SESSION [Capture_BlockedProcessReport]
ON SERVER
STATE = START;
GO



/* Read the extended event file 

SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    event_data.query('(event/data[@name="blocked_process"]/value/blocked-process-report)[1]') as [blocked_process_report]
FROM
(
    SELECT CAST(event_data AS XML) AS event_data
    FROM sys.fn_xe_file_target_read_file('C:\Temp\Capture_BlockedProcessReport*.xel', NULL, NULL, NULL)
) AS sub;
GO

*/