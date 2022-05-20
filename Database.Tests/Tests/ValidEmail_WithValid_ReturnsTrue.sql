CREATE PROCEDURE tests.[ValidEmail_WithValid_ReturnsTrue] AS

-- arrange
DECLARE @expected BIT = 1;

-- act
DECLARE @actual BIT = dbo.ValidEmail('jnixon@microsoft.com');

-- assert
EXEC assert.Equal @expected, @actual;