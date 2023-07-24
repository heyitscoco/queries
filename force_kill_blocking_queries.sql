SELECT
	pid
	, usename
	, pg_blocking_pids(pid) as blocked_by
	, blocked_query
	, pg_terminate_backend(pid) AS cancelled
FROM (
	SELECT
		pid 
	    , usename
	    , pg_blocking_pids(pid) as blocked_by
	    , query as blocked_query
	FROM pg_stat_activity
	WHERE cardinality(pg_blocking_pids(pid)) > 0
) AS blocking_queries