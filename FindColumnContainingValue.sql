
declare @Value nvarchar(255) = '%nfr%'

 
DECLARE @TablesFound TABLE(
      EntityName varchar(255),
      ColumnName varchar(255)
)
 
DECLARE TABLES_CURSOR CURSOR FOR
SELECT '[' + SCHEMA_NAME(t.schema_id) + '].[' + so.name + ']' as table_name, 
	'[' + sc.name + ']' as column_name  FROM sysobjects so 
	INNER JOIN syscolumns sc
		ON so.id = sc.id 
	INNER JOIN sys.types st
		ON st.user_type_id = sc.xtype
	INNER JOIN sys.tables t
		ON t.object_id = so.id

	WHERE so.type = 'U' AND st.name IN ('char', 'varchar', 'nchar', 'nvarchar')
	ORDER BY so.name
 
DECLARE @EntityName varchar(255)
DECLARE @ColumnName varchar(255)
 
OPEN TABLES_CURSOR
 
FETCH NEXT FROM TABLES_CURSOR INTO @EntityName, @ColumnName
WHILE(@@FETCH_STATUS = 0)
BEGIN
      DECLARE @sql nvarchar(255);
      SET @sql ='SELECT @found = COUNT(' + @ColumnName + ') FROM  ' + @EntityName + 
                              ' WHERE ' + @ColumnName + ' LIKE ''' + @Value + '''';
       
      DECLARE @found int
      exec sp_executesql @sql, N'@found int output', @found=@found output
      IF(@found > 0)
      BEGIN
            INSERT INTO @TablesFound VALUES (@EntityName, @ColumnName)
      END
 
      FETCH NEXT FROM TABLES_CURSOR INTO @EntityName, @ColumnName
END
 
CLOSE TABLES_CURSOR
DEALLOCATE TABLES_CURSOR
 
SELECT EntityName, ColumnName FROM @TablesFound