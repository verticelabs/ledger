package verticelabs.ledger.test;

import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.annotation.Transactional;

import verticelabs.ioc.ledger.LedgerDBH2Config;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = { LedgerDBH2Config.class })
@TransactionConfiguration(transactionManager = "txLedgerDB", defaultRollback = true)
@Transactional(value = "txLedgerDB", readOnly = false)
public class AbstractTestSuite {

}
