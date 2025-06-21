--watch -n 5 'echo "SELECT JOB_NAME,SLAVE_OS_PROCESS_ID,ELAPSED_TIME,CPU_USED FROM USER_SCHEDULER_RUNNING_JOBS;" | sqlplus tuantn/*****@cdb1'
SELECT *--JOB_NAME,SLAVE_OS_PROCESS_ID,ELAPSED_TIME,CPU_USED
FROM USER_SCHEDULER_RUNNING_JOBS;

SELECT * FROM ALL_SCHEDULER_JOB_RUN_DETAILS
ORDER BY LOG_ID DESC;

--GRANT EXECUTE ON DBMS_LOCK TO TUANTN;
BEGIN
    -- Stop the job first
    DBMS_SCHEDULER.STOP_JOB(
        job_name => 'TUANTN.INSERT_EMPLOYEE_S01',
        force    => TRUE -- Use force to immediately stop the job
    );
    -- Removed the sleep delay
    -- Now drop the job
    DBMS_SCHEDULER.DROP_JOB(
        job_name => 'TUANTN.INSERT_EMPLOYEE_S01'
    );
END;
/


--CREATE TABLE
CREATE TABLE TUANTN.NGHIEPVU
	(
	  ID          NUMBER,
	  NAME        VARCHAR2(255 BYTE),
	  DATETIME    TIMESTAMP(6),
	  SALARY      NUMBER(10,2),
	  CREDITCARD  CHAR(12 BYTE)
	)
	TABLESPACE DATA
	NOLOGGING 
	NOCOMPRESS 
	NOCACHE
;


--INSERT
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name           => 'INSERT01',
    job_type           => 'PLSQL_BLOCK',
    job_action         => q'[
        DECLARE
		  v_start_date TIMESTAMP := TO_TIMESTAMP('2024-01-01 00:00:01', 'YYYY-MM-DD HH24:MI:SS');
		  v_end_date TIMESTAMP := TO_TIMESTAMP('2024-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS');
		  v_diff_seconds NUMBER;
		  v_name VARCHAR2(255);
		  v_creditcard CHAR(12);
		  v_datetime TIMESTAMP;
		BEGIN
		  -- Calculate the difference in seconds between the start and end dates
		  SELECT (EXTRACT(DAY FROM (v_end_date - v_start_date)) * 86400 +
				  EXTRACT(HOUR FROM (v_end_date - v_start_date)) * 3600 +
				  EXTRACT(MINUTE FROM (v_end_date - v_start_date)) * 60 +
				  EXTRACT(SECOND FROM (v_end_date - v_start_date)))
		  INTO v_diff_seconds
		  FROM dual;

		  FOR i IN 1..1000000 LOOP
			v_name := 'Employee ' || TO_CHAR(i);
			v_creditcard := LPAD(TRUNC(DBMS_RANDOM.VALUE(100000000000, 999999999999)), 12, '0');
			-- Add a random interval, up to the difference calculated, to the start date
			v_datetime := v_start_date + NUMTODSINTERVAL(TRUNC(DBMS_RANDOM.VALUE(0, v_diff_seconds)), 'SECOND');

			INSERT /*+ APPEND*/ INTO TUANTN.NGHIEPVU (ID, Name, Datetime, Salary, CreditCard)
			VALUES (i, v_name, v_datetime, DBMS_RANDOM.VALUE(10000, 20000), v_creditcard);

			IF MOD(i, 500000) = 0 THEN
			  COMMIT;
			  DBMS_LOCK.SLEEP(5); -- Pause for 5 seconds after each commit to reduce load
			END IF;
		  END LOOP;
		  COMMIT; -- Ensure the final commit
		END;
    ]',
    start_date         => SYSTIMESTAMP,
    repeat_interval    => NULL,
    end_date           => NULL,
    enabled            => TRUE,
    auto_drop          => TRUE,
    comments           => ''
  );
END;
/


--GATHER
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name           => 'GATHER_11',
    job_type           => 'PLSQL_BLOCK',
    job_action         => q'[
        DECLARE
           l_table_name VARCHAR2 (30) := 'NGHIEPVU';
        BEGIN
           DBMS_STATS.GATHER_TABLE_STATS (
              ownname => 'TUANTN',
              tabname => l_table_name,
              method_opt => 'FOR ALL COLUMNS SIZE AUTO',
              estimate_percent => NULL,
              granularity => 'ALL',
              cascade => TRUE
           );
        END;
    ]',
    start_date         => SYSTIMESTAMP,
    repeat_interval    => NULL,
    end_date           => NULL,
    enabled            => TRUE,
    auto_drop          => TRUE,
    comments           => ''
  );
END;
/
