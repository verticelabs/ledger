SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    Procedure: add_charge
    Sumary: Add charge amount to account
    Author: Marcelo Manzan

    Returns:
       0: Success
      10: Unprocessable amount (must be abs and != 0.00)
      11: Unprocessable transaction_ref (must not be blank)
      20: Invalid account_id or tchannel
      30: Internal error
*/
CREATE PROCEDURE [ledger].[add_charge]
  @account_id bigint,
  @tchannel varchar(20),
  @date_ref datetime,
  @transaction_ref varchar(32),
  @amount money
AS
  DECLARE @Erro int
  DECLARE @ErrorMsg varchar
  DECLARE @tchannel_id int
  DECLARE @date_ref_balance datetime
  DECLARE @Now datetime

  IF NULLIF(@transaction_ref, '') IS NULL
      RETURN 11 -- Unprocessable transaction_ref (must not be blank)

  IF @amount IS NULL OR @amount < '0.01'
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

  SET @Now = GETDATE()
  IF @date_ref IS NULL OR @date_ref < DATEADD(s, -1, @Now)
      SET @date_ref = @Now

  BEGIN TRAN
    INSERT INTO [ledger].[ledger_logs]
           ([account_id], [date_ref], [entry_type], [tchannel_id], [transaction_ref], [amount], [created_at])
    VALUES (@account_id , @date_ref , 'C'         , @tchannel_id , @transaction_ref , @amount , @Now        )

    SET @Erro = @@ERROR
    IF @@ROWCOUNT <> 1 OR @Erro <> 0
      BEGIN
        ROLLBACK
        SET @ErrorMsg = 'Fail adding charge. Rowcount:'+CONVERT(varchar, @@ROWCOUNT)+' Error:'+CONVERT(varchar, @Erro)
        RAISERROR(@ErrorMsg, 0, 1)
        RETURN 30 -- Internal error
      END

  COMMIT TRAN

GO

