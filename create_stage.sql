create or replace stage mystage 's3://mydata/mystage/' connection=(
endpoint_url='http://127.0.0.1:9900',
access_key_id='minioadmin',
secret_access_key='minioadmin',
region='us-east-1'
);