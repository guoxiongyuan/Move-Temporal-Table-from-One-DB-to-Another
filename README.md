# Move Temporal Table from One Database to Another
Temporal tables (also known as system-versioned temporal tables) was introduced in SQL Server 2016, which is a new built-in feature to support storing a full history of data changes and to easily analysing data changes. This feature can be used for the auditing purpose.

If you want to move a temporal table from one database to another, you cannot easily export data to the new temporal table due to its versioning history table. This T-SQL script  Move_Temporal_Table_from_One_DB_to_Another.sql demonstrate how to move a temporal table from one database to another in the SQL server.

See the article "SQL Server: How to Move Temporal Table from One Database to Another Database" at https://social.technet.microsoft.com/wiki/contents/articles/53563.sql-server-how-to-move-temporal-table-from-one-database-to-another-database.aspx for the details.
