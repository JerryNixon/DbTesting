CREATE SCHEMA assert;

GO

/*
	assert.Contain
	Ensure fragment is inside string.
	@fragment: String to search for
	@string: String to search in
	@msg: (optional) Append custom error message - default: NULL
*/

CREATE PROC assert.Contain
	  @fragment VARCHAR(1000)
	, @string VARCHAR(1000)
	, @msg VARCHAR(1000) = 'Contain'
AS
BEGIN

	IF (@fragment IS NULL OR @string IS NULL)
	BEGIN
		SET @msg = CONCAT('Hint: Check for nulls. ', @msg);
		EXEC assert.Fail @msg, @fragment, @string, 'assert.Contain';
	END

	IF (charindex(@fragment, @string) = 0)
	BEGIN
		EXEC assert.Fail @msg, @fragment, 'NOT FOUND', 'assert.Contain';
	END
		
END;

GO

/*
	assert.Equal
	Ensure two values are equal.
	@expected: Left value to check equality.
	@actual: Right value to check equality.
	@msg: (optional) Append custom error message - default: NULL
*/

CREATE PROC assert.Equal
	  @expected SQL_VARIANT
	, @actual SQL_VARIANT
	, @msg VARCHAR(1000) = 'Equal'
AS
BEGIN

	DECLARE @e NVARCHAR(1000) = CONVERT(NVARCHAR(1000), @expected);
	DECLARE @a NVARCHAR(1000) = CONVERT(NVARCHAR(1000), @actual);

	IF (@expected IS NULL OR @actual IS NULL)
	BEGIN
		SET @msg = CONCAT('Hint: Check for nulls. ', @msg);
		EXEC assert.Fail @msg, @e, @a, 'assert.Equal';
	END

	IF (@expected != @actual)
	BEGIN
		IF (@e = @a)
		BEGIN
			SET @msg = CONCAT('Hint: Check datatypes. ', @msg);
			EXEC assert.Fail @msg, @e, @a, 'assert.Equal';
		END
	ELSE
		EXEC assert.Fail @msg, @e, @a, 'assert.Equal';
	END

END;

GO

/*
	assert.Error
	Ensure latests error values match.
	@expected: (optional) Ensure @error_number matches @expected - default: NULL
	@contains: (optional) Ensure @error_message contains @contains - default: NULL
	@msg: Append custom error message
*/

CREATE PROC assert.ErrInfo
	  @expected INT = NULL
	, @contains VARCHAR(50) = NULL
	, @msg VARCHAR(1000) = 'Error'
AS
BEGIN

	IF (@expected IS NOT NULL)
	BEGIN
		DECLARE @error_number INT = error_number();
		EXEC assert.Equal @expected, @error_number, 'Error Number Equals';
	END

	IF (@contains IS NOT NULL)
	BEGIN
		DECLARE @error_message VARCHAR(1000) = error_message();
		EXEC assert.Contain @contains, @error_message, 'Error Message Contains';
	END

END;

GO

/*
	assert.Fail
	Used to raise an exception, generally only used by assert methods
	@message: error_message()
	@expected: (optional) Builds the Expected<@expected> Actual<> substring 
		Note: if not passed in, the substring is not built.
	@contains: (optional) Builds the Expected<> Actual<@actual> substring 
		Note: if not passed in, the substring is not built.
	@caller: (optional) Prepends caller to message - default: 'assert.Fail'
	@number: (optional) error_number() - default: 50000
*/

CREATE PROC assert.Fail
	  @message VARCHAR(1000)
  	, @expected VARCHAR(1000) = NULL
	, @actual VARCHAR(1000) = NULL
	, @caller VARCHAR(1000) = 'assert.Fail'
	, @number INT = 50000
AS 
BEGIN

	IF NOT (@expected = 'assert.Fail' OR @actual = 'assert.Fail')
	BEGIN
		SET @message = CONCAT(
			'[[ Expected<', COALESCE(@expected, 'NULL'), '>, ',
			'Actual<', COALESCE(@actual, 'NULL'),'>. ',
			@message, ' ]]');
	END

	EXEC assert.Throw @number = @number, @caller = @caller, @message = @message, @withdate = 0;

END;

GO

/*
	assert.NotEqual
	Ensure two values are not equal.
	@expected: Left value to check equality.
	@actual: Right value to check equality.
	@msg: (optional) Append custom error message - default: NULL
*/

CREATE PROC assert.NotEqual
	  @expected SQL_VARIANT
	, @actual SQL_VARIANT
	, @msg VARCHAR(1000) = 'NotEqual'
AS
BEGIN

	IF (@expected IS NULL)
	BEGIN
		RETURN;
	END

	IF (@actual IS NULL)
	BEGIN
		RETURN;
	END

	IF (@expected = @actual)
	BEGIN
		DECLARE @e NVARCHAR(1000) = CONCAT('NOT ', CONVERT(NVARCHAR(1000), @expected));
		DECLARE @a NVARCHAR(1000) = CONVERT(NVARCHAR(1000), @actual);
		EXEC assert.Fail @msg, @e, @a, 'assert.NotEqual';
	END

END;

GO

/*
	assert.NotNull
	Ensure value is not NULL.
	@msg: (optional) Append custom error message - default: NULL
*/

CREATE PROC assert.NotNull
	  @actual SQL_VARIANT
	, @msg VARCHAR(1000) = 'NotNull'
AS
BEGIN

	IF (@actual IS NULL)
	BEGIN
		EXEC assert.Fail @msg, 'NOT NULL', 'NULL', 'assert.NotNull';
	END

END;

GO

/*
	assert.Null
	Ensure value is NULL.
	@msg: (optional) Append custom error message - default: NULL
*/

CREATE PROC assert.[Null]
	  @actual SQL_VARIANT
	, @msg VARCHAR(1000) = 'Null'
AS
BEGIN

	IF (@actual IS NOT NULL)
	BEGIN
		DECLARE @a NVARCHAR(1000) = CONVERT(NVARCHAR(1000), @actual);
		EXEC assert.Fail @msg, 'NULL', @a, 'assert.Null';
	END

END;

GO

/*
	assert.PrintLine
	Prints line, even when in a loop (which is the special part)
	@message: string to print
	@withdate: (optional) prepends datetime to message - default: 1
*/

CREATE PROCEDURE assert.PrintLine
	  @message VARCHAR(1000)
	, @withdate BIT = 1
AS
BEGIN
	IF (@withdate = 1)
	BEGIN
		DECLARE @PRINT VARCHAR(1000) = CONCAT(SYSDATETIME(), ' ', @message); 
		RAISERROR (@PRINT, 0, 1) WITH NOWAIT;
	END
	ELSE
	BEGIN
		RAISERROR (@message, 0, 1) WITH NOWAIT;
	END
END;

GO

/*
	assert.Throw
	Throws new exception with additional, optional information
	@caller: prepends caller to message
	@message: string to print
	@withdate: (optional) prepends datetime to message - default: 1
	@number: (optional) the error number to throw - default: 51000
*/

CREATE PROC assert.[Throw]
	  @caller VARCHAR(50)
	, @message VARCHAR(1000)
	, @withdate BIT = 0
	, @number INT = 51000
AS
BEGIN

	IF (@withdate = 1)
	BEGIN
		SET @message = CONCAT(SYSDATETIME(), ' ', @message); 
	END
	SET @message = CONCAT(@caller, ': ', @message);
	DECLARE @print VARCHAR(1500) = CONCAT('#', @number, ' ', @message);
	EXEC assert.PrintLine @print, 0;
	THROW @number, @message, 1;

END;

GO

CREATE FUNCTION assert.ActualRows
(@schema_name VARCHAR(100), @table_name VARCHAR(100)) 
RETURNS BIGINT AS
BEGIN

	DECLARE @actual BIGINT = -1

	SELECT @actual = MAX(p.rows) 
	FROM sys.tables AS t
	JOIN sys.schemas AS s 
		ON t.schema_id = s.schema_id
	JOIN sys.indexes AS i 
		ON t.OBJECT_ID = i.object_id
	JOIN sys.partitions AS p 
		ON i.object_id = p.OBJECT_ID 
		AND i.index_id = p.index_id
	WHERE s.name = @schema_name
		AND t.name = @table_name
	GROUP BY t.Name, s.Name

	RETURN @actual

END;

GO

CREATE PROC assert.[Rows]
	  @schema_name VARCHAR(100)
	, @table_name VARCHAR(100)
	, @expected BIGINT
	, @msg VARCHAR(1000) = NULL
AS
BEGIN

	DECLARE @actual BIGINT;
	SELECT @actual = assert.ActualRows(@schema_name, @table_name);

	DECLARE @a VARCHAR(1000) = @actual;
	DECLARE @e VARCHAR(1000) = @expected;
	SET @msg = CONCAT(@schema_name, '.', @table_name, ' row count should match. ', @msg);
	IF NOT (@expected = @actual)
	BEGIN
		EXEC assert.Fail @msg, @e, @a, 'assert.Rows';
	END

END;

GO

CREATE PROC assert.NotRows
	  @schema_name VARCHAR(100)
	, @table_name VARCHAR(100)
	, @expected BIGINT
	, @msg VARCHAR(1000) = NULL
AS
BEGIN

	DECLARE @actual BIGINT;
	SELECT @actual = assert.ActualRows(@schema_name, @table_name);

	DECLARE @a VARCHAR(1000) = @actual;
	DECLARE @e VARCHAR(1000) = CONCAT('NOT ', @expected);
	SET @msg = CONCAT(@schema_name, '.', @table_name, ' row count should not match.', @msg);
	IF (@expected = @actual)
	BEGIN
		EXEC assert.Fail @msg, @e, @a, 'assert.NotRows';
	END

END;

GO

CREATE PROC assert.HasNoRows
	  @schema_name VARCHAR(100)
	, @table_name VARCHAR(100)
	, @msg VARCHAR(1000) = NULL
AS
BEGIN

	DECLARE @actual BIGINT;
	SELECT @actual = assert.ActualRows(@schema_name, @table_name);

	SET @msg = CONCAT(@schema_name, '.', @table_name, ' should have no rows.', @msg);
	IF (0 != @actual)
	BEGIN
		DECLARE @a VARCHAR(1000) = @actual;
		EXEC assert.Fail @msg, '0', @a, 'assert.HasNoRows';
	END

END;

GO

CREATE PROC assert.HasRows
	  @schema_name VARCHAR(100)
	, @table_name VARCHAR(100)
	, @msg VARCHAR(1000) = NULL
AS
BEGIN

	DECLARE @actual BIGINT;
	SELECT @actual = assert.ActualRows(@schema_name, @table_name);

	SET @msg = CONCAT(@schema_name, '.', @table_name, ' should have some rows.', @msg);
	IF (0 = @actual)
	BEGIN
		DECLARE @a VARCHAR(1000) = @actual;
		EXEC assert.Fail @msg, 'NOT 0', @a, 'assert.HasRows';
	END

END;