-- The query below checks if all the views are running without errors and aren't empty


USE TSQL2012
GO


CREATE TABLE TSQL2012.dbo.VIEWS_TESTING 
(
  View_Name varchar(255)
, Result varchar(50)
, Error_Message varchar(1000)
, Run_Time datetime2
)
GO

CREATE PROCEDURE dbo.VIEWS_TESTING
AS
BEGIN 

DECLARE @main_query nvarchar (1000)
DECLARE @error_query nvarchar (1000)
DECLARE @view_name nvarchar(255)
DECLARE @cur cursor

DELETE FROM TSQL2012.dbo.VIEWS_TESTING

SELECT  CONCAT(TABLE_CATALOG, '.', TABLE_SCHEMA, '.', TABLE_NAME) AS view_name 
INTO #views
FROM TSQL2012.INFORMATION_SCHEMA.VIEWS


SET @cur = CURSOR FOR
SELECT view_name
FROM #views   

OPEN @cur
FETCH NEXT
FROM @cur INTO @view_name
WHILE @@FETCH_STATUS = 0

BEGIN TRY
  
	SET @main_query = 'INSERT INTO TSQL2012.dbo.VIEWS_TESTING (View_Name, Result, Error_Message, Run_Time)' +

			          'SELECT ' + char(39) + @view_name + char(39) + 'as View_Name, 
						CASE WHEN COUNT(*) = 0 THEN ' + char(39) + 'NO DATA' + char(39) +
					        'WHEN COUNT(*) = 1 THEN ' + char(39) + 'PASS' + char(39) +
							'END AS Result, 
					    NULL as Error_Message, 
					    GETDATE() as Run_Time 

					    FROM  (SELECT TOP(1)1 as cnt FROM ' + @view_name + ') s'

    EXEC sp_executesql @main_query, N'@view_name varchar(255)', @view_name = @view_name
    FETCH NEXT
    FROM @cur INTO @view_name
END TRY

BEGIN CATCH

	SET @error_query = 'INSERT INTO TSQL2012.dbo.VIEWS_TESTING (View_Name, Result, Error_Message, Run_Time)' +

			           'SELECT ' + char(39) + @view_name + char(39) + 'as View_Name,' +
					    char(39) + 'FAIL' + char(39) +'as Result,' +
					   'ERROR_MESSAGE() AS ErrorMessage, 
					    GETDATE() as Run_Time'

	EXEC sp_executesql @error_query, N'@view_name varchar(255)', @view_name = @view_name
	FETCH NEXT
	FROM @cur INTO @view_name
END CATCH


CLOSE @cur
DEALLOCATE @cur

DROP TABLE #views

END 
GO

EXEC dbo.VIEWS_TESTING
GO

SELECT View_Name, Result, Error_Message, Run_Time 
FROM TSQL2012.dbo.VIEWS_TESTING
WHERE Result <> 'PASS'
