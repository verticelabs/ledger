SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [ledger].[ledger_logs](
  [account_id] bigint NOT NULL,
  [date_ref] datetime NOT NULL,
  [entry_type] char(1) NOT NULL,
  [tchannel_id] int NOT NULL,
  [transaction_ref] varchar(32) NOT NULL,
  [amount] money NOT NULL,
  [archived] bit NOT NULL DEFAULT 0,
  [created_at] datetime NOT NULL
) ON [PRIMARY] ([archived]) -- YOU MAY SET ANOTHER PARTITION SCHEME
GO

ALTER TABLE [ledger].[ledger_logs]  WITH CHECK ADD  CONSTRAINT [FK_ledger_logs__accounts] FOREIGN KEY([account_id])
REFERENCES [ledger].[accounts] ([id])
ON DELETE NO ACTION

ALTER TABLE [ledger].[ledger_logs]  WITH CHECK ADD  CONSTRAINT [FK_ledger_logs__transaction_channels] FOREIGN KEY([tchannel_id])
REFERENCES [ledger].[transaction_channels] ([id])
ON DELETE NO ACTION

CREATE NONCLUSTERED INDEX IX_ledger_logs_date_ref ON [ledger].[ledger_logs](date_ref ASC) INCLUDE (account_id, amount)
    WHERE archived = 0;
GO

CREATE NONCLUSTERED INDEX IX_ledger_logs_date_ref_archived ON [ledger].[ledger_logs](date_ref ASC) INCLUDE (account_id, amount)
    WHERE archived = 1;
GO

CREATE CLUSTERED INDEX IX03_ledger_logs ON [ledger].[ledger_logs](account_id, tchannel_id, transaction_ref)
GO


SET ANSI_PADDING OFF
GO


