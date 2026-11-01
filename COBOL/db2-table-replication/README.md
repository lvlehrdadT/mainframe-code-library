# DB2 Table Replication Using COBOL

## Overview

This project is an example of a COBOL batch program that copies rows from a source
DB2 table to a target DB2 table. It is based on a practical COBOL/DB2 replication
program and has been sanitized for use as a public portfolio example.

The program uses Embedded SQL, a cursor, incremental processing by record ID,
periodic commits, progress messages, and a record-level INSERT error-recovery path.

> **Important:** This is an illustrative portfolio example, not a drop-in production
> utility. The placeholder schema, table, and column names must be replaced and the
> program must be reviewed, precompiled, compiled, bound, and tested in the target
> DB2 for z/OS environment before execution.

## Main Features

- COBOL with DB2 Embedded SQL
- Cursor-based source-table retrieval
- Incremental processing using source and target maximum IDs
- Limited fetch batches using `FETCH FIRST`
- Cursor declared `WITH HOLD`
- Periodic `COMMIT` operations
- SQLCODE-based handling of INSERT failures
- Tracking of the last successfully inserted ID
- A time-window check to stop processing at the configured boundary
- End-of-run row-count comparison and console reporting

## Processing Flow

1. Read the maximum ID from the target table. This becomes the initial replication
   checkpoint (`P-MAX-ID`).
2. Read the maximum ID from the source table (`S-MAX-ID`).
3. Declare and open a cursor for source rows whose IDs are greater than the target
   checkpoint and less than or equal to the source maximum ID.
4. Fetch a limited batch of rows in ascending ID order.
5. Insert each fetched row into the target table.
6. Commit after the configured number of successful inserts.
7. When the cursor reaches the end of the current batch, commit, close the cursor,
   update the checkpoint, and open the next batch.
8. At completion, compare source and target row counts for the selected date range
   and display a summary.

## Error Handling and Recovery

### INSERT errors

The program checks `SQLCODE` after each INSERT. When an INSERT returns a non-zero
SQLCODE, it transfers control to the `PROG-END2` paragraph.

The current recovery path:

1. Commits previously successful work.
2. Displays the SQLCODE and replication progress.
3. Uses `PREVIOUS-ID` to remember the last successfully inserted ID.
4. Advances the replication checkpoint using `NUM-ERROR-REC`.
5. Reopens the cursor and resumes processing from the updated checkpoint.

This is a record-skipping strategy: it attempts to continue the replication rather
than stopping at the first failed INSERT.

**Important limitation:** the skip logic assumes that advancing the ID checkpoint
is an acceptable way to bypass the failed row. It must be reviewed carefully if
IDs are not consecutive, if multiple rows can share an ID, or if skipped rows must
never be lost. In a production implementation, record-level failures should be
logged with their IDs and SQL diagnostics, and skipped rows should be reconciled
or retried explicitly.

### Other SQL operations

The original control flow does not provide a complete, centralized error-handling
routine for every SQL statement. In particular, production hardening should add
explicit checks and appropriate handling after:

- `SELECT ... INTO`
- `OPEN CURRSP`
- `FETCH CURRSP`
- `COMMIT WORK`
- `CLOSE CURRSP`
- The final `SELECT COUNT(*)` statements

The program treats `SQLCODE = 100` after FETCH as end-of-data. Other FETCH errors
should be handled separately rather than allowing processing to continue with
potentially invalid or stale host-variable values.

## Transaction Management

The `COMMIT-COUNT` working-storage item controls the normal commit interval. The
example initializes it to `50000` and changes it to `10000` during a particular
time window.

Periodic commits limit the amount of uncommitted work and make successful batches
durable. The appropriate value depends on workload, lock duration, log capacity,
and operational requirements.

The error-recovery paragraph also issues a commit before resuming. This means
previous successful inserts may already be committed when a later row fails.

## Time-Based Execution Control

The program reads the current date and time using `FUNCTION CURRENT-DATE`. It
compares the current date and hour with the start date and configured time
conditions. When the time limit is reached, it branches to the time-expiration
summary path.

The hour and minute thresholds in the source are example operational settings.
Review and parameterize them for the intended schedule before using the program.

## Configuration Before Use

Replace the following placeholders with the actual names in a permitted test
environment:

- `SOURCE_SCHEMA.SOURCE_TABLE`
- `TARGET_SCHEMA.TARGET_TABLE`
- Generic column names such as `COL_ID`, `COL_NUM1`, and `COL_REFERENCE`
- The COBOL program name and DB2 package/plan settings in the build and run JCL

Also verify that:

- Source and target columns have compatible data types and lengths.
- The host-variable definitions match the DB2 column definitions.
- The source and target ID strategy is compatible with the checkpoint logic.
- The target table's initial state is handled correctly.
- The required DB2 privileges are available to the execution ID.

The example uses `COALESCE(MAX(...), 0)` for the maximum ID/date queries so that an
empty table returns zero instead of a NULL value for the host variable. Confirm
that zero is a valid initial checkpoint for the actual ID/date domains.

## Important Technical Notes

- The cursor's SELECT list, FETCH host variables, INSERT column list, and INSERT
  values must remain in exactly corresponding order.
- The example uses `WITH UR` on read operations. Review the isolation level and
  consistency requirements before using it for a real replication workload.
- `FETCH FIRST 100 ROWS ONLY` limits each cursor batch. The program reopens the
  cursor with an updated checkpoint to process subsequent batches.
- The example's final count comparison is a basic validation method. Equal counts
  do not prove that every individual row was replicated correctly.
- The code is provided as a learning and portfolio example; it has not been
  certified for every COBOL compiler or DB2 for z/OS function level.

## Environment

- IBM z/OS
- IBM Enterprise COBOL (or a compatible COBOL compiler supporting the syntax used)
- DB2 for z/OS
- DB2 precompiler and bind process

## Repository Structure

```text
db2-table-replication/
├── README.md
└── db2_table_replication.cbl
```

## Disclaimer

All schema, table, and column names in this public example are placeholders.
Do not add production data, credentials, internal dataset names, system identifiers,
or confidential business rules to this repository.
