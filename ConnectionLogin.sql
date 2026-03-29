CREATE LOGIN etl_user WITH PASSWORD = 'StrongPass072!';
GO

USE BigAnalyticsDB;
GO

CREATE USER etl_user FOR LOGIN etl_user;
GO

ALTER ROLE db_owner ADD MEMBER etl_user;
GO

