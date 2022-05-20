IF NOT EXISTS(SELECT 1 FROM Users WHERE Id = 1)
BEGIN

	EXEC InsertUser @id = 1, @name = 'Jerry', @email = 'jnixon@microsoft.com';

END