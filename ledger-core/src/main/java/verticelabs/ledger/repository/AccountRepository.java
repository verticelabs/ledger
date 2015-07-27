package verticelabs.ledger.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import verticelabs.ledger.domain.Account;

public interface AccountRepository extends JpaRepository<Account, Long> {

}
