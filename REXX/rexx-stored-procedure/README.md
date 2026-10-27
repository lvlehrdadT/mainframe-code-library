# DB2 for z/OS Stored Procedures Using REXX

## Overview

This guide describes key configuration concepts for running REXX programs as external stored procedures in a DB2 for z/OS environment.

It focuses on three main areas:

- Configuring a WLM application environment for REXX stored procedures.
- Making REXX execs available through the `SYSEXEC` DD statement.
- Submitting JCL from a REXX stored procedure through the JES internal reader.

## 1. Architecture and Execution Flow

A REXX stored procedure typically involves the following components:

1. **DB2 for z/OS** receives a stored procedure call.
2. **WLM** manages the execution environment used by the stored procedure.
3. **The REXX runtime environment** executes the REXX program.
4. **SYSEXEC** provides access to REXX exec libraries, according to the environment configuration.
5. **JES Internal Reader**, when configured and authorized, can receive JCL submitted by the REXX program.

The exact configuration depends on the DB2 version, z/OS environment, WLM setup, and site-specific procedures.

## 2. WLM Environment for REXX

A REXX stored procedure requires an appropriately configured execution environment.

The WLM application environment must be configured for the stored procedure's runtime requirements. Its associated startup procedure and DD statements depend on the site's installation and configuration.

Consult your site's DB2 and z/OS configuration before changing the WLM environment.

## 3. SYSEXEC DD Statement

The `SYSEXEC` DD statement is used to make REXX exec libraries available to the REXX execution environment.

The relevant library allocation must point to the data set containing the REXX program, using the configuration appropriate for the environment.

The library name and allocation details are installation-specific and should not be copied from another system without verification.

## 4. Submitting JCL Through the Internal Reader

A REXX stored procedure may need to submit a batch job dynamically.

One possible DD statement for an internal-reader allocation is:

```jcl
//JCLJOB DD SYSOUT=(,INTRDR)
```

This allocation directs output written to the `JCLJOB` DD to the JES internal reader, where it can be interpreted as submitted JCL.

The REXX program must generate valid JCL and write it to the appropriate DD. The job's submission and execution are subject to JES configuration, security permissions, and site policies.

**Important:** The DD statement alone does not guarantee that job submission will succeed. The WLM execution environment must have the required allocation and authorization, and the program must handle allocation and submission errors.

## 5. Security and Operational Considerations

Before implementing this approach, verify:

- The REXX exec library is available to the runtime environment.
- The WLM environment is configured for the required runtime.
- The stored procedure's execution identity has the necessary permissions.
- Internal-reader access and job submission are permitted by site security policies.
- Allocation failures and submission errors are handled appropriately.

Avoid embedding production data set names, credentials, internal system identifiers, or other confidential configuration in public examples.

## Summary

The main configuration points covered in this guide are the WLM execution environment, the `SYSEXEC` allocation for REXX execs, and the `JCLJOB` DD statement for submitting JCL through the JES internal reader.

These components must work together for a REXX-based DB2 stored procedure to execute reliably in a z/OS environment.
