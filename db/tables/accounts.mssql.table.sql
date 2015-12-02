SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [ledger].[accounts](
  [id] bigint IDENTITY(1,1) NOT NULL,
  [profile_id] int NOT NULL,
  [issuer_id] int NOT NULL,
  [channel_id] int NOT NULL,
  [currency_code] char(3) NOT NULL,
  [external_ref] varchar(32),
  CONSTRAINT [PK_accounts] PRIMARY KEY CLUSTERED 
(
  [id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ledger].[accounts]  WITH CHECK ADD  CONSTRAINT [FK_accounts__issuers] FOREIGN KEY([issuer_id])
REFERENCES [ledger].[issuers] ([id])
ON DELETE NO ACTION

ALTER TABLE [ledger].[accounts]  WITH CHECK ADD  CONSTRAINT [FK_accounts__account_channels] FOREIGN KEY([channel_id])
REFERENCES [ledger].[account_channels] ([id])
ON DELETE NO ACTION

ALTER TABLE [ledger].[accounts]  WITH CHECK ADD  CONSTRAINT [FK_accounts__account_profiles] FOREIGN KEY([profile_id])
REFERENCES [ledger].[account_profiles] ([id])
ON DELETE NO ACTION

SET ANSI_PADDING OFF
GO

