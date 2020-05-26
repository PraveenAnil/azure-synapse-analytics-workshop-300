    -------------------------------------------------------------------------Dynamic Data Masking (DDM)----------------------------------------------------------------------------------------------------------
    /*  Dynamic data masking helps prevent unauthorized access to sensitive data by enabling customers
        to designate how much of the sensitive data to reveal with minimal impact on the application layer.
        Let see how */

    /* Scenario: WWI has identified sensitive information in the CustomerInfo table. They would like us to 
        obfuscate the CreditCard and Email columns of the CustomerInfo table to DataAnalysts */

    -- Step:1 Let us first get a view of CustomerInfo table.
    SELECT TOP (100) * FROM wwi_security.CustomerInfo_#USER_CONTEXT#;

    -- Step:2 Let's confirm that there are no Dynamic Data Masking (DDM) applied on columns.
    SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function  
    FROM sys.masked_columns AS c  
    JOIN sys.tables AS tbl
        ON c.[object_id] = tbl.[object_id]  
    WHERE is_masked = 1
        AND tbl.name = 'CustomerInfo_#USER_CONTEXT#';
    -- No results returned verify that no data masking has been done yet.

    -- Step:3 Now lets mask 'CreditCard' and 'Email' Column of 'CustomerInfo' table.
    ALTER TABLE wwi_security.CustomerInfo_#USER_CONTEXT#
    ALTER COLUMN [CreditCard] ADD MASKED WITH (FUNCTION = 'partial(0,"XXXX-XXXX-XXXX-",4)');
    GO
    ALTER TABLE wwi_security.CustomerInfo_#USER_CONTEXT#
    ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
    GO
    -- The columns are sucessfully masked.

    -- Step:4 Let's see Dynamic Data Masking (DDM) applied on the two columns.
    SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function  
    FROM sys.masked_columns AS c  
    JOIN sys.tables AS tbl
        ON c.[object_id] = tbl.[object_id]  
    WHERE is_masked = 1
        AND tbl.name ='CustomerInfo_#USER_CONTEXT#';

    -- Step:5 Now, let us grant SELECT permission to 'DataAnalystMiami' on the 'CustomerInfo' table.
   GRANT SELECT ON wwi_security.CustomerInfo_#USER_CONTEXT# TO DataAnalystMiami_#USER_CONTEXT#;  

    -- Step:6 Logged in as  'DataAnalystMiami' let us execute the select query and view the result.
    EXECUTE AS USER = 'DataAnalystMiami_#USER_CONTEXT#';  
    SELECT * FROM wwi_security.CustomerInfo_#USER_CONTEXT#;

    -- Step:7 Let us remove the data masking using UNMASK permission
    GRANT UNMASK TO DataAnalystMiami_#USER_CONTEXT#;
    EXECUTE AS USER = 'DataAnalystMiami_#USER_CONTEXT#';  
    SELECT *
    FROM wwi_security.CustomerInfo_#USER_CONTEXT#;
    revert;
    REVOKE UNMASK TO DataAnalystMiami_#USER_CONTEXT#;  

    ----step:8 Reverting all the changes back to as it was.
    ALTER TABLE wwi_security.CustomerInfo_#USER_CONTEXT#
    ALTER COLUMN CreditCard DROP MASKED;
    GO
    ALTER TABLE wwi_security.CustomerInfo_#USER_CONTEXT#
    ALTER COLUMN Email DROP MASKED;
    GO