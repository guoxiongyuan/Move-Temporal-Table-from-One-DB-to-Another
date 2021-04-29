-------------------------------------------------------------------------------
-- Part 1 - Preparation of Source Database
-------------------------------------------------------------------------------
-- 1. Create a source test database TestDB1
-- 2. Create a temporal table Customer with history table CustomerHistory
-- 3. Insert some sample data to Customer
-- 4. Make some data changes which will be stored in the table CustomerHistory
-------------------------------------------------------------------------------
-- 1. Create a source test database TestDB1
USE [master];
GO
CREATE DATABASE [TestDB1];
GO

-- 2. Create a temporal table Customer with history table CustomerHistory
USE [TestDB1];
GO
CREATE TABLE [dbo].[Customer] (
    [CustomerId] int CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED NOT NULL,
    [CustomerName] varchar(32) NOT NULL,
    [Address] varchar(128) NOT NULL,
    [City] varchar(64) NOT NULL,
    [State] varchar(32) NOT NULL,
    [IsActive] bit CONSTRAINT [DF_Customer_IsActive] DEFAULT (1) NOT NULL,
    [SysStartTime] datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    [SysEndTime] datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime]),
) WITH (SYSTEM_VERSIONING = ON(HISTORY_TABLE = [dbo].[CustomerHistory], DATA_CONSISTENCY_CHECK = ON));
GO

-- 3. Insert some sample data to Customer
INSERT INTO [dbo].[Customer] ([CustomerId], [CustomerName], [Address], [City], [State]) VALUES
(1, 'Customer01', 'Address01', 'New York', 'New York'),
(2, 'Customer02', 'Address02', 'Jersey', 'New Jersey'),
(3, 'Customer03', 'Address02', 'Miami', 'Florida');
GO

-- 4. Make some data changes which will be stored in the table CustomerHistory
UPDATE [dbo].[Customer] SET [IsActive] = 0 WHERE [CustomerId] = 2;
UPDATE [dbo].[Customer] SET [Address] = 'NewAddress3' WHERE [CustomerId] = 3;
GO

-- Check data in both Customer and CustomerHistory
SELECT * FROM [dbo].[Customer];
SELECT * FROM [dbo].[CustomerHistory];
GO


-------------------------------------------------------------------------------
-- Part 2 - Preparation of Destination Database
-------------------------------------------------------------------------------
-- 1. Create a destination test database TestDB2
-- 2. Create tables Customer and CustomerHistory
-------------------------------------------------------------------------------
-- 1. Create a destination test database TestDB2
USE [master];
GO
CREATE DATABASE [TestDB2];
GO

-- 2. Create tables Customer and CustomerHistory with the same columns and data types as those in the source DB
USE [TestDB2];
GO
CREATE TABLE [dbo].[Customer] (
    [CustomerId] int CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED NOT NULL,
    [CustomerName] varchar(32) NOT NULL,
    [Address] varchar(128) NOT NULL,
    [City] varchar(64) NOT NULL,
    [State] varchar(32) NOT NULL,
    [IsActive] bit CONSTRAINT [DF_Customer_IsActive] DEFAULT (1) NOT NULL,
    [SysStartTime] datetime2 NOT NULL,
    [SysEndTime] datetime2 NOT NULL
);
GO
CREATE TABLE [dbo].[CustomerHistory] (
    [CustomerId] int NOT NULL,
    [CustomerName] varchar(32) NOT NULL,
    [Address] varchar(128) NOT NULL,
    [City] varchar(64) NOT NULL,
    [State] varchar(32) NOT NULL,
    [IsActive] bit NOT NULL,
    [SysStartTime] datetime2 NOT NULL,
    [SysEndTime] datetime2 NOT NULL
);
GO


-------------------------------------------------------------------------------
-- Part 3 - Convert Existing Table to Temporal Table
-------------------------------------------------------------------------------
-- 1. Copy data to Customer and CustomerHistory from source DB to destination DB
-- 2. Convert table Customer to temporal table in the destination DB
--		1) Add both datetime2 columns to period for system time
--		2) Turn on system versioning
-------------------------------------------------------------------------------
-- 1. Copy data to Customer and CustomerHistory from source DB to destination DB
USE [TestDB2];
GO
INSERT INTO [dbo].[Customer]
SELECT * FROM [TestDB1].[dbo].[Customer];
GO
INSERT INTO [dbo].[CustomerHistory]
SELECT * FROM [TestDB1].[dbo].[CustomerHistory];
GO

-- 2. Convert table Customer to temporal table in the destination DB
-- 1) Add both datetime2 columns to period for system time
ALTER TABLE [dbo].[Customer]
ADD PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime]);
-- 2) Turn on system versioning
ALTER TABLE [dbo].[Customer]
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[CustomerHistory], DATA_CONSISTENCY_CHECK = ON));
GO


-------------------------------------------------------------------------------
-- Part 4 - Drop temporal table from source DB
-- 1. Set SYSTEM_VERSIONING off
-- 2. Drop history table CustomerHistory
-- 3. Drop table Customer
-------------------------------------------------------------------------------
USE [TestDB1];
GO
-- 1. Set SYSTEM_VERSIONING off
ALTER TABLE [dbo].[Customer] SET (SYSTEM_VERSIONING = OFF);
-- 2. Drop history table CustomerHistory
DROP TABLE IF EXISTS [dbo].[CustomerHistory];
-- 3. Drop table Customer
DROP TABLE IF EXISTS [dbo].[Customer];
GO