-- https://docs.databend.com/sql/sql-commands/ddl/connection/create-connection
CREATE CONNECTION myconn
    STORAGE_TYPE = 's3'
    ACCESS_KEY_ID = '<your-access-key-id>'
    SECRET_ACCESS_KEY = '<your-secret-access-key>';
