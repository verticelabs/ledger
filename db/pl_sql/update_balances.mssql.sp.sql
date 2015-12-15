SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    Procedure: update_balances
    Sumary: Schedule this job to keep account balances up to date

    Strategies:
      -- once a day, verify all accounts
      EXEC update_balances @Strategy = 'all_accounts'

      -- job executed every 5 minutes, verifying changed accounts from last period
      EXEC update_balances @Strategy = 'recent_accounts', @Period = 5

      -- archive summarized logs
      EXEC update_balances @Strategy = 'archive'
*/
CREATE PROCEDURE [ledger].[update_balances]
  @Strategy varchar(MAX) = 'all_accounts',
  @Period int = 5,
  @Top int = 100
AS
  DECLARE @Now datetime = DATEADD(s, -2, GETDATE())
  DECLARE @CountOperations int = 100
  DECLARE @end_date datetime = DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @Now)-(DATEPART(MINUTE, @Now)%@Period), 0)
  DECLARE @start_date datetime = DATEADD(MINUTE, -@Period, @end_date)

  IF @Top IS NULL
      SET @Top = 100

  WHILE @CountOperations > 0
    BEGIN
      SET @CountOperations = @CountOperations - 1
      IF @Strategy = 'all_accounts'
        BEGIN
          ; WITH changed_accounts AS (
            SELECT MAX(ll.date_ref) [last_date_ref]
                 , SUM(ll.amount) [diff_amount]
                 , ab.account_id
            FROM [ledger].[account_balances] ab
            INNER JOIN [ledger].[ledger_logs] ll (NOLOCK) ON ll.account_id=ab.account_id
            WHERE ll.date_ref > ab.date_ref AND ll.date_ref <= @Now
              AND ll.archived = 0
            GROUP BY ab.account_id
            HAVING SUM(ll.amount) <> '0.00'
          )
          UPDATE TOP (@Top) ab
          SET ab.date_ref=ca.last_date_ref, ab.balance=ab.balance+ca.diff_amount
          FROM [ledger].[account_balances] ab
          INNER JOIN changed_accounts ca ON ca.account_id=ab.account_id
        END
      ELSE IF @Strategy = 'recent_accounts'
        BEGIN
          ; WITH recent_accounts AS (
            SELECT DISTINCT ll.account_id
            FROM [ledger].[ledger_logs] ll (NOLOCK)
            WHERE ll.date_ref BETWEEN @start_date AND @end_date
              AND ll.archived = 0
          ), changed_accounts AS (
            SELECT MAX(ll.date_ref) [last_date_ref]
                 , SUM(ll.amount) [diff_amount]
                 , ab.account_id
            FROM recent_accounts ra
            INNER JOIN [ledger].[account_balances] ab ON ab.account_id=ra.account_id
            INNER JOIN [ledger].[ledger_logs] ll (NOLOCK) ON ll.account_id=ab.account_id
            WHERE ll.date_ref > ab.date_ref AND ll.date_ref <= @Now
              AND ll.archived = 0
            GROUP BY ab.account_id
          )
          UPDATE TOP (@Top) ab
          SET ab.date_ref=ca.last_date_ref, ab.balance=ab.balance+ca.diff_amount
          FROM [ledger].[account_balances] ab
          INNER JOIN changed_accounts ca ON ca.account_id=ab.account_id
        END
      ELSE IF @Strategy = 'archive'
          UPDATE TOP (@Top) ll
          SET ll.archived = 1
          FROM [ledger].[ledger_logs] ll (NOLOCK)
          INNER JOIN [ledger].[account_balances] ab (NOLOCK) ON ab.account_id=ll.account_id
          WHERE ll.date_ref<=ab.date_ref
            AND ll.archived=0
      ELSE
          BREAK

      IF @@ROWCOUNT = 0
          -- No more accounts to process
          BREAK
    END

GO

