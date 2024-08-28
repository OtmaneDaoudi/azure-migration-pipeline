USE gold_db
GO

CREATE OR ALTER PROC create_views @ViewName nvarchar(100)
AS
BEGIN
DECLARE @statement VARCHAR(MAX)

    SET @statement = N'CREATE OR ALTER VIEW ' + @ViewName + ' AS
        SELECT *
        FROM
            OPENROWSET(
                BULK ''https://datastorage69.dfs.core.windows.net/gold/' + @ViewName + '/'',
                FORMAT = ''DELTA''
            ) as [result]
    '

EXEC (@statement)

END
GO