CREATE PROCEDURE tests.[ValidEmail_WithInvalid_ReturnsFalse] AS

-- arrange
DECLARE @expected BIT = 0;

-- act
DECLARE @actual BIT = dbo.ValidEmail('jnixon@other.com');

-- assert
EXEC assert.Equal @expected, @actual;