CREATE PROCEDURE tests.[ValidEmail_WithNull_ReturnsFalse] AS

-- arrange
DECLARE @expected BIT = 0;

-- act
DECLARE @actual BIT = dbo.ValidEmail(NULL);

-- assert
EXEC assert.Equal @expected, @actual;