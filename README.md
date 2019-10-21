# Ledger
> A book or other collection of financial accounts of a particular type.

## Introduction

The purpose of this project is to define a common specification on how to store data of financial transactions in a way that allows adequate control, summarization and purging of data already summarized.

![Diagram](https://raw.githubusercontent.com/verticelabs/ledger/master/db/ledger_diagram.png)

## Tables

- **transaction_channels**: This table maps external services that can interact with the accounts table (according to allowed profiles).
- **ledger_logs**: The effective transactions that changes the account balance.
- **account_channels**: This table maps external services that can require or create new accounts (according to allowed issuers).
- **account_balance**: This table handle de account balance already summarized.
