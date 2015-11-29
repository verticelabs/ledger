SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [ledger].[profile_allowed_transactions](
  [profile_id] int NOT NULL,
  [tchannel_id] int NOT NULL,
  CONSTRAINT [PK_profile_allowed_transactions] PRIMARY KEY CLUSTERED 
(
  [profile_id] ASC,
  [tchannel_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ledger].[profile_allowed_transactions]  WITH CHECK ADD  CONSTRAINT [FK_profile_allowed_transactions__account_profiles] FOREIGN KEY([profile_id])
REFERENCES [ledger].[account_profiles] ([id])
ON DELETE CASCADE

ALTER TABLE [ledger].[profile_allowed_transactions]  WITH CHECK ADD  CONSTRAINT [FK_profile_allowed_transactions__transaction_channels] FOREIGN KEY([tchannel_id])
REFERENCES [ledger].[transaction_channels] ([id])
ON DELETE CASCADE

SET ANSI_PADDING OFF
GO


