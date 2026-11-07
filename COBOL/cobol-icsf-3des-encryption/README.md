# COBOL – IBM ICSF 3DES Encryption and Decryption

A COBOL program demonstrating 3DES encryption and decryption using IBM Integrated Cryptographic Service Facility (ICSF) callable services, with DB2 for z/OS integration.

The program retrieves data from a DB2 table, encrypts it using an ICSF callable service, stores the encrypted result in another DB2 table, and then decrypts the ciphertext to verify the result.

## Overview

This project demonstrates how COBOL applications can use IBM ICSF cryptographic services to perform symmetric encryption and decryption on IBM z/OS.

The example uses the following ICSF callable services:

- `CSNBSYE` – Symmetric Key Encipher
- `CSNBSYD` – Symmetric Key Decipher

It also demonstrates how to integrate cryptographic operations with DB2 using Embedded SQL.

## Key Management Approaches in IBM ICSF

IBM ICSF supports different approaches for providing cryptographic keys to its callable services.

### 1. Clear Key

In this approach, the cryptographic key is provided directly by the application program.

- The key value is defined in the COBOL program.
- The application passes the key directly to the ICSF callable service.
- The current `ENCLEAR` program demonstrates this approach.
- A 24-byte test key is used to demonstrate Triple DES (3DES).

**Note:** The key included in this example is for testing and educational purposes only. Clear keys should not be embedded in production application code.

### 2. Key Label

In this approach, the cryptographic key is managed by ICSF rather than being directly defined in the application program.

- A key is created and stored through ICSF key management facilities.
- The key is identified by a Key Label.
- The application passes the Key Label to the ICSF callable service instead of providing the clear key value.
- ICSF resolves the label and accesses the corresponding key from the Cryptographic Key Data Set (CKDS).
- Access to keys can be controlled through security profiles.

This project currently implements the Clear Key approach. Key Label is described for comparison and is not implemented in the provided source code.

## Program Workflow

The `ENCLEAR` program performs the following operations:

1. Opens a DB2 cursor to retrieve `PAN_ID` and `PAN` from the source table.
2. Fetches one record from the source table.
3. Passes the input data to the ICSF encryption service (`CSNBSYE`).
4. Converts the encrypted output into hexadecimal representation for display.
5. Inserts the encrypted data and corresponding identifier into the target DB2 table.
6. Calls the ICSF decryption service (`CSNBSYD`).
7. Displays the decrypted result for verification.
8. Closes the cursor and commits the DB2 transaction.

## Hexadecimal Representation of Encrypted Data

Encrypted data is binary and may contain non-printable characters.

In z/OS, displaying binary ciphertext directly using COBOL `DISPLAY` may produce unreadable or misleading output.

To make the encrypted result readable, this program converts each byte of the ciphertext into its two-character hexadecimal representation.

For example:

- Each byte is represented by two hexadecimal characters.
- The hexadecimal representation makes the encrypted output easier to display and inspect.
- This conversion is only for presentation purposes and does not change the original encrypted data.

The original binary ciphertext remains in `WS-CIPHER-TEXT` and is passed directly to the decryption service (`CSNBSYD`).

## DB2 Integration

The program uses COBOL Embedded SQL to retrieve and store data.

### Source Table

The program retrieves the following fields:

- `PAN_ID`
- `PAN`

### Target Table

The encrypted data is inserted into the target table with its corresponding identifier.

The schema and table names in the source code should be replaced with the appropriate names in the target environment.

## ICSF Parameters

The example uses the following cryptographic parameters:

| Parameter | Value |
|---|---|
| Encryption algorithm | Triple DES (3DES) |
| Key length | 24 bytes |
| Block size | 8 bytes |
| IV length | 8 bytes |
| Rule array | DES |
| Encryption service | CSNBSYE |
| Decryption service | CSNBSYD |

The actual cryptographic behavior depends on the ICSF service parameters and the configuration of the z/OS environment.

## Requirements

- IBM z/OS
- COBOL compiler
- DB2 for z/OS
- IBM ICSF configured and available
- Required ICSF callable service access
- Appropriate DB2 privileges for source table access and target table insertion

## Security Considerations

- The example uses a test clear key and must not be used for production encryption.
- Do not include real PAN values, customer information, or production cryptographic keys in source code or repository files.
- Clear keys should be handled through approved secure key-management procedures.
- Key Label provides a way to reference keys managed by ICSF without embedding their clear values in application code.
- 3DES is a legacy encryption algorithm and is not recommended for new security designs.
- This example is intended for educational purposes and does not represent a production-ready payment-data encryption solution.

## Notes

This project demonstrates the integration of COBOL, DB2 Embedded SQL, and IBM ICSF callable services on z/OS.

It focuses on understanding symmetric encryption, decryption, key-management approaches, and the handling of binary encrypted data in a mainframe environment.

**Language:** COBOL  
**Database:** DB2 for z/OS  
**Cryptographic Service:** IBM ICSF  
**Platform:** IBM z/OS
