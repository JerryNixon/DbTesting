CREATE PROCEDURE [dbo].[InsertUser]
	  @Id INT
	, @name VARCHAR(150)
	, @email VARCHAR(150)
AS

IF (dbo.ValidEmail(@email) = 1)
BEGIN

	INSERT INTO Users (Id, Name, Email)
	VALUES (@Id, @name, @email)

END
