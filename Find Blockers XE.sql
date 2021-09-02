-- Perform cleanup.   
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='FindBlockers')  
    DROP EVENT SESSION FindBlockers ON SERVER  
GO  
-- Use dynamic SQL to create the event session and allow creating a -- predicate on the AdventureWorks database id.  
--  
DECLARE @dbid int  

SELECT @dbid = db_id('EOC_TRAN')  

IF @dbid IS NULL  
BEGIN  
    RAISERROR('EOC_TRAN Not Found!', 17, 1)  
    RETURN  
END  

DECLARE @sql nvarchar(1024)  
SET @sql = '  
CREATE EVENT SESSION FindBlockers ON SERVER  
ADD EVENT sqlserver.lock_acquired   
    (action   
        ( sqlserver.sql_text, sqlserver.database_id, sqlserver.tsql_stack,  
         sqlserver.plan_handle, sqlserver.session_id)  
    WHERE ( database_id=' + cast(@dbid as nvarchar) + ' AND resource_0!=0)   
    ),  
ADD EVENT sqlserver.lock_released   
    (WHERE ( database_id=' + cast(@dbid as nvarchar) + ' AND resource_0!=0 ))  
ADD TARGET package0.pair_matching   
    ( SET begin_event=''sqlserver.lock_acquired'',   
            begin_matching_columns=''database_id, resource_0, resource_1, resource_2, transaction_id, mode'',   
            end_event=''sqlserver.lock_released'',   
            end_matching_columns=''database_id, resource_0, resource_1, resource_2, transaction_id, mode'',  
    respond_to_memory_pressure=1)  
WITH (max_dispatch_latency = 1 seconds)'  

EXEC (@sql)  
--   
-- Create the metadata for the event session  
-- Start the event session  
--  
ALTER EVENT SESSION FindBlockers ON SERVER  
STATE = START