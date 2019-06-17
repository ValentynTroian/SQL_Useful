USE TSQL2012
GO

DECLARE @main_query nvarchar (255)
DECLARE @view_name nvarchar(255)
DECLARE @cur cursor

CREATE TABLE #results (View_Name varchar(255), Result varchar(1))

SELECT  CONCAT(TABLE_CATALOG, '.', TABLE_SCHEMA, '.', TABLE_NAME) AS view_name 
INTO #views
FROM INFORMATION_SCHEMA.VIEWS

SET @cur = CURSOR FOR
SELECT view_name
FROM #views   

OPEN @cur
FETCH NEXT
FROM @cur INTO @view_name
WHILE @@FETCH_STATUS = 0
BEGIN
  -- 1 - True (the table has records), 0 - False (the table doesn't have records)
SET @main_query = 'insert into #results (View_Name, Result)' +
			      'select ' + char(39) + @view_name + char(39) + 'as View_Name, 
                   count(*) as Result from   
                   (select top(1) 1 as cnt from ' + @view_name + ') s'

    EXEC sp_executesql @main_query, N'@view_name varchar(255)', @view_name = @view_name
    FETCH NEXT
    FROM @cur INTO @view_name
END

CLOSE @cur
DEALLOCATE @cur

SELECT * FROM #results

DROP TABLE #views
DROP TABLE #results