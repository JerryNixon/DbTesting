CREATE FUNCTION [dbo].[ValidEmail] (@email VARCHAR(150))
RETURNS BIT AS
BEGIN
	IF (RIGHT(@email, 14) = '@microsoft.com')
		RETURN 1
	RETURN 0
END