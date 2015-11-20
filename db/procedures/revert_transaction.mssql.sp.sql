SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    Procedure: revert_transaction
    Sumary: Revert amount to account balance
    Author: Marcelo Manzan

    Returns:
       0: Success
       1: Success (partial revert)
       2: Success (had already been reverted)
       3: Success (transaction_ref not found, nothing to do)
      10: Unprocessable amount (must be abs and != 0.00)
      11: Unprocessable transaction_ref (must not be blank)
      15: Unprocessable amount (exceeded)
      20: Invalid account_id or tchannel
      21: Invalid transaction_ref (charge and debit with same ref)
      30: Internal error
*/
CREATE PROCEDURE [ledger].[revert_transaction]
  @account_id bigint,
  @tchannel varchar(20),
  @date_ref datetime,
  @transaction_ref varchar(32),
  @amount money = NULL OUTPUT,
  @reason varchar(200) = null
AS
  DECLARE @Erro int
  DECLARE @ErrorMsg varchar
  DECLARE @tchannel_id int
  DECLARE @date_ref_balance datetime
  DECLARE @Now datetime = GETDATE()
  DECLARE @basedate date = '2011-01-01'
  DECLARE @signal int = 1
  DECLARE @balance money

  DECLARE @is_charge int
  DECLARE @is_debit int
  DECLARE @tdate_ref datetime
  DECLARE @zeromoney money = '0.00'
  DECLARE @minbalance money = '0.01'
  DECLARE @tamount money
  DECLARE @ramount money
  DECLARE @rest money

  IF NULLIF(@transaction_ref, '') IS NULL
      RETURN 11 -- Unprocessable transaction_ref (must not be blank)

  IF @amount < @minbalance -- null is OK
      RETURN 10 -- Unprocessable amount (must be abs and != 0.00)

  SELECT @date_ref_balance = ab.date_ref, @tchannel_id = tc.id
  FROM [ledger].[accounts] a (NOLOCK)
  INNER JOIN [ledger].[profile_allowed_transactions] pat (NOLOCK) ON pat.profile_id=a.profile_id
  INNER JOIN [ledger].[transaction_channels] tc (NOLOCK) ON tc.id=pat.tchannel_id
  INNER JOIN [ledger].[account_balances] ab ON ab.account_id=a.id
  WHERE tc.identifier=@tchannel
    AND a.id=@account_id

  IF @date_ref_balance IS NULL
      RETURN 20 -- Invalid account_id or tchannel

  SELECT @is_charge = SUM(CASE ll.entry_type WHEN 'C' THEN 1 ELSE 0 END),
         @is_debit = SUM(CASE ll.entry_type WHEN 'D' THEN 1 ELSE 0 END),
         @tdate_ref = MAX(CASE WHEN ll.entry_type IN ('C', 'D') THEN ll.date_ref ELSE @basedate END),
         @tamount = SUM(CASE WHEN ll.entry_type IN ('C', 'D') THEN ll.amount ELSE @zeromoney END),
         @ramount = SUM(CASE ll.entry_type WHEN 'R' THEN ll.amount ELSE @zeromoney END)
  FROM [ledger].[ledger_logs] ll (NOLOCK)
  WHERE ll.account_id=@account_id
    AND ll.tchannel_id=@tchannel_id
    AND ll.transaction_ref=@transaction_ref

  IF @is_charge = 0 AND @is_debit = 0 OR @is_charge IS NULL AND @is_debit IS NULL
      RETURN 3 -- Success (transaction_ref not found, nothing to do)

  IF @is_charge > 0 AND @is_debit > 0
      RETURN 21 -- Invalid transaction_ref (charge and debit with same ref)

  SET @rest = ABS(@tamount + @ramount)
  IF @amount IS NULL
    BEGIN
      SET @amount = @rest
      IF @is_charge > 0 AND @tdate_ref < GETDATE()
        BEGIN
          SET @balance = ledger.get_account_balance_fn(@account_id)
          IF @balance <= @zeromoney
              RETURN 15 -- Unprocessable amount (exceeded)
          IF @amount > @balance
              SET @amount = @balance
        END
    END

  IF @rest < @minbalance
      RETURN 2 -- Success (had already been reverted)

  IF @rest < @amount
      RETURN 15 -- Unprocessable amount (exceeded)

  SET @Now = GETDATE()
  IF @date_ref IS NULL OR @date_ref < DATEADD(s, -1, @Now)
      SET @date_ref = @Now

  SET @date_ref = (CASE WHEN @tdate_ref > @Now THEN @tdate_ref ELSE @Now END)
  IF @is_charge > 0
      SET @signal = -1

  BEGIN TRAN
    INSERT INTO [ledger].[ledger_logs]
           ([account_id], [date_ref], [entry_type], [tchannel_id], [transaction_ref],
            [amount]         , [created_at])
    VALUES (@account_id , @date_ref , 'R'         , @tchannel_id , @transaction_ref ,
            @amount * @signal, @Now        )

    SET @Erro = @@ERROR
    IF @@ROWCOUNT <> 1 OR @Erro <> 0
      BEGIN
        ROLLBACK
        SET @ErrorMsg = 'Fail reverting transaction. Rowcount:'+CONVERT(varchar, @@ROWCOUNT)+' Error:'+CONVERT(varchar, @Erro)
        RAISERROR(@ErrorMsg, 0, 1)
        RETURN 30 -- Internal error
      END

    IF @reason IS NOT NULL
        INSERT INTO [ledger].[reversal_logs]
               ([account_id], [created_at], [reason])
        VALUES (@account_id , @Now        , @reason )
  COMMIT TRAN
  RETURN (CASE WHEN @rest > @amount THEN 1 ELSE 0 END)

GO

