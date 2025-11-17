create or replace connection myconn  storage_type='s3' access_key_id='x' secret_access_key='x' region=='us-east-1';

create or replace stage mystage 's3://mydata/mystage/' connection=(connection_name='myconn');
