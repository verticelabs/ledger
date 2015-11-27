SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [ledger].[issuer_allowed_channels](
  [issuer_id] int NOT NULL,
  [channel_id] int NOT NULL,
  CONSTRAINT [PK_issuer_allowed_channels] PRIMARY KEY CLUSTERED 
(
  [issuer_id] ASC,
  [channel_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ledger].[issuer_allowed_channels]  WITH CHECK ADD  CONSTRAINT [FK_issuer_allowed_channels__issuers] FOREIGN KEY([issuer_id])
REFERENCES [ledger].[issuers] ([id])
ON DELETE CASCADE

ALTER TABLE [ledger].[issuer_allowed_channels]  WITH CHECK ADD  CONSTRAINT [FK_issuer_allowed_channels__account_channels] FOREIGN KEY([channel_id])
REFERENCES [ledger].[account_channels] ([id])
ON DELETE CASCADE

SET ANSI_PADDING OFF
GO


