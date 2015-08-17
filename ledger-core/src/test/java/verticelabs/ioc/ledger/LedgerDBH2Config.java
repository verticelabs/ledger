package verticelabs.ioc.ledger;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.annotation.PropertySources;

@Configuration
@PropertySources({
	@PropertySource(name = "ledgerProps", value = "classpath:/ledger_test.properties", ignoreResourceNotFound = true)
})
public class LedgerDBH2Config {
}
