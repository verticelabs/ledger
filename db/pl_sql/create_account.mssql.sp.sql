SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ledger].[create_account]
  @issuer varchar(20),
  @profile varchar(20),
  @channel varchar(20),
  @account_id bigint OUTPUT,
  @external_ref varchar(32) = NULL
AS
  DECLARE @Erro int

  BEGIN TRAN
    INSERT INTO [ledger].[accounts]
          ([profile_id], [issuer_id], [channel_id], [currency_code], [external_ref])
    SELECT ap.id       , i.id       , ac.id       , i.currency_code, @external_ref
    FROM [ledger].[issuers] i
    INNER JOIN [ledger].[account_profiles] ap ON ap.issuer_id=i.id
    INNER JOIN [ledger].[issuer_allowed_channels] iac ON iac.issuer_id=i.id
    INNER JOIN [ledger].[account_channels] ac ON ac.id=iac.channel_id
    WHERE i.identifier=@issuer
      AND ap.identifier=@profile
      AND ac.identifier=@channel

    SET @Erro = @@ERROR
    IF @@ROWCOUNT <> 1 OR @Erro <> 0
      BEGIN
        ROLLBACK
        RAISERROR('Fail to insert account', 0, 1)
        RETURN(@Erro)
      END

    SET @account_id = @@IDENTITY

    INSERT INTO [ledger].[account_balances]
           ([account_id], [date_ref]              , [balance])
    VALUES (@account_id , CONVERT(DATE, GETDATE()), '0.00'   )

    SET @Erro = @@ERROR
    IF @@ROWCOUNT <> 1 OR @Erro <> 0
      BEGIN
        ROLLBACK
        SET @account_id = NULL
        RAISERROR('Fail to insert account_balance', 0, 1)
        RETURN(@Erro)
      END

  COMMIT TRAN

GO

