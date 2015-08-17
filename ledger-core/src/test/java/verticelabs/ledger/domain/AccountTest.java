package verticelabs.ledger.domain;

import static org.junit.Assert.*;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import verticelabs.ledger.repository.AccountRepository;
import verticelabs.test.ledger.AbstractTestSuite;

public class AccountTest extends AbstractTestSuite {

	@Autowired
	private AccountRepository accountRepository;

	@Test
	public void testJpaMapping() {
		assertNotNull(accountRepository);
		assertEquals(0, accountRepository.count());
	}
}
