USE TSQL2012
GO

CREATE TABLE TSQL2012.dbo.VIEWS_TESTING_RESULTS 
(
  View_Name varchar(255)
, Result varchar(50)
, Error_Message varchar(1000)
, Run_Time datetime2
)
GO

CREATE PROCEDURE dbo.SP_VIEWS_TESTING
AS
BEGIN 

DECLARE @main_query nvarchar (1000)
DECLARE @error_query nvarchar (1000)
DECLARE @view_name nvarchar(255)
DECLARE @cur cursor

DELETE FROM TSQL2012.dbo.VIEWS_TESTING_RESULTS

SELECT  CONCAT(TABLE_CATALOG, '.', TABLE_SCHEMA, '.', TABLE_NAME) AS view_name 
INTO #VIEWS
FROM TSQL2012.INFORMATION_SCHEMA.VIEWS

SET @cur = CURSOR FOR
SELECT view_name
FROM #VIEWS   

OPEN @cur
FETCH NEXT
FROM @cur INTO @view_name
WHILE @@FETCH_STATUS = 0

BEGIN TRY
	SET @main_query = 'INSERT INTO TSQL2012.dbo.VIEWS_TESTING_RESULTS (View_Name, Result, Error_Message, Run_Time)' +

			          'SELECT '''  + @view_name + ''' as View_Name, 
						CASE WHEN COUNT(*) = 0 THEN ''' + 'NO DATA''' +
					            'WHEN COUNT(*) = 1 THEN ''' + 'PASS'''  +
					        'END AS Result, 
					    NULL as Error_Message, 
					    GETDATE() as Run_Time 
					    FROM  (SELECT TOP(1) 1 as cnt FROM ' + @view_name + ') s'

    EXECUTE sp_executesql @main_query, N'@view_name varchar(255)', @view_name = @view_name
    FETCH NEXT
    FROM @cur INTO @view_name
END TRY

BEGIN CATCH
	SET @error_query = 'INSERT INTO TSQL2012.dbo.VIEWS_TESTING_RESULTS (View_Name, Result, Error_Message, Run_Time)' +

			           'SELECT ''' + @view_name + '''as View_Name,' +
					    '''FAIL'''  +' as Result,' +
					    'ERROR_MESSAGE() AS ErrorMessage, 
					     GETDATE() as Run_Time'

	EXECUTE sp_executesql @error_query, N'@view_name varchar(255)', @view_name = @view_name
	FETCH NEXT
	FROM @cur INTO @view_name
END CATCH


CLOSE @cur
DEALLOCATE @cur

DROP TABLE #VIEWS

END 
GO

EXECUTE dbo.SP_VIEWS_TESTING
GO

SELECT * FROM TSQL2012.dbo.VIEWS_TESTING_RESULTS
