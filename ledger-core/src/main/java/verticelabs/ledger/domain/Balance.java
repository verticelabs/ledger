package verticelabs.ledger.domain;

import java.math.BigDecimal;
import java.util.Calendar;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
@Table(name="account_balances")
public class Balance {

	@Id
	@Column(name = "account_id")
	private Long accountId;

	@Column
	private BigDecimal balance;

	@Column(name = "date_ref")
	@Temporal(TemporalType.TIMESTAMP)
	private Calendar dateRef;

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public BigDecimal getBalance() {
		return balance;
	}

	public void setBalance(BigDecimal balance) {
		this.balance = balance;
	}

	public Calendar getDateRef() {
		return dateRef;
	}

	public void setDateRef(Calendar dateRef) {
		this.dateRef = dateRef;
	}

}
