WITH queries as (
	SELECT
		pid
	    , CASE WHEN cardinality(pg_blocking_pids(pid)) > 0 THEN TRUE END AS blocked
	    , CASE WHEN cardinality(pg_blocking_pids(pid)) >= 1 THEN pg_blocking_pids(pid) END AS blocked_by
	    , state
	    , DATE_TRUNC('second', query_start - backend_start) AS wait_time
	    , DATE_TRUNC('second', (CURRENT_TIMESTAMP - query_start)) AS time_running
	    , query
	    , application_name
	FROM pg_stat_activity
	WHERE state IS NOT NULL
)
SELECT
	q1.pid
	, blocked
	, state
	, wait_time
	, time_running
	, q1.query
	, q2.query AS blocked_by
	, application_name
FROM queries q1
LEFT OUTER JOIN (SELECT pid, query FROM queries) q2
ON q2.pid = ANY(q1.blocked_by)
