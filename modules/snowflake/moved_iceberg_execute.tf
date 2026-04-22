# State migration when adding count to snowflake_execute (existing unindexed address).
moved {
  from = snowflake_execute.lambda_logs_iceberg_table
  to   = snowflake_execute.lambda_logs_iceberg_table[0]
}
