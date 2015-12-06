SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [ledger].[account_balances](
  [account_id] bigint NOT NULL,
  [date_ref] datetime NOT NULL,
  [balance] money NOT NULL DEFAULT '0.00',
  CONSTRAINT [PK_account_balances] PRIMARY KEY CLUSTERED 
(
  [account_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ledger].[account_balances]  WITH CHECK ADD  CONSTRAINT [FK_account_balances__accounts] FOREIGN KEY([account_id])
REFERENCES [ledger].[accounts] ([id])
ON DELETE NO ACTION

SET ANSI_PADDING OFF
GO

