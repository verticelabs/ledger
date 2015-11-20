SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [ledger].[get_account_balance_fn](@account_id bigint)
RETURNS money
AS
BEGIN
  DECLARE @balance money
  DECLARE @addendum money
  DECLARE @date_ref_start datetime
  DECLARE @date_ref_end datetime = CURRENT_TIMESTAMP

  SELECT @balance = ab.[balance], @date_ref_start = ab.date_ref
  FROM [ledger].[account_balances] ab (NOLOCK)
  WHERE ab.account_id=@account_id

  SELECT @addendum = SUM(ll.amount)
  FROM [ledger].[ledger_logs] ll (NOLOCK)
  WHERE ll.account_id=@account_id
    AND ll.date_ref > @date_ref_start AND ll.date_ref <= @date_ref_end
    AND ll.archived = 0

  RETURN (@balance + ISNULL(@addendum, 0))
END
GO
