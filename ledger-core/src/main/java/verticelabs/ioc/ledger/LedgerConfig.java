package verticelabs.ioc.ledger;

import java.beans.PropertyVetoException;

import javax.persistence.EntityManagerFactory;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.annotation.PropertySources;
import org.springframework.core.env.Environment;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.Database;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import com.mchange.v2.c3p0.ComboPooledDataSource;

@Configuration
@PropertySources({
	@PropertySource(name = "ledgerProps", value = "classpath:/ledger.properties", ignoreResourceNotFound = true)
})
@ComponentScan(basePackages = "verticelabs.ledger")
@EnableJpaRepositories(
		basePackages = "verticelabs.ledger.repository",
		entityManagerFactoryRef = "emfLedgerDB",
		transactionManagerRef = "txLedgerDB")
@EnableTransactionManagement
public class LedgerConfig {

	@Autowired
	private Environment env;

	@Bean(name = "dsLedgerDB", destroyMethod = "close")
	public DataSource dsLedgerDB() {
		ComboPooledDataSource ds = new ComboPooledDataSource();
		try {
			ds.setDriverClass(env.getProperty("ledgerdb.driver"));
		} catch (PropertyVetoException e) {
			return null;
		}
		ds.setUser(env.getProperty("ledgerdb.user"));
		ds.setPassword(env.getProperty("ledgerdb.password"));
		ds.setJdbcUrl(env.getProperty("ledgerdb.url"));

		ds.setMinPoolSize(env.getProperty("c3p0.minsize", Integer.class));
		ds.setMaxPoolSize(env.getProperty("c3p0.maxsize", Integer.class));
		ds.setMaxIdleTime(env.getProperty("c3p0.maxidletime", Integer.class));
		ds.setAcquireIncrement(env.getProperty("c3p0.acquireincrement",
				Integer.class));
		ds.setAcquireRetryAttempts(env.getProperty("c3p0.acquireretryattempts",
				Integer.class));
		ds.setInitialPoolSize(env
				.getProperty("c3p0.initialsize", Integer.class));
		ds.setMaxStatements(env
				.getProperty("c3p0.maxstatements", Integer.class));
		ds.setIdleConnectionTestPeriod(env.getProperty(
				"c3p0.idleconntestperiod", Integer.class));
		ds.setTestConnectionOnCheckout(env.getProperty("c3p0.validate",
				Boolean.class));
		return ds;
	}

	@Bean(name = "emfLedgerDB")
	public EntityManagerFactory emfLedgerDB() {
		HibernateJpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
		vendorAdapter.setDatabase(Database.valueOf(env
				.getProperty("jpa.database")));
		vendorAdapter.setDatabasePlatform(env.getProperty("jpa.platform"));
		vendorAdapter.setGenerateDdl(env.getProperty("jpa.generateddl",
				Boolean.class));
		vendorAdapter.setShowSql(env.getProperty("jpa.showsql", Boolean.class));

		LocalContainerEntityManagerFactoryBean emf = new LocalContainerEntityManagerFactoryBean();
		emf.setPersistenceUnitName("ledgerdb");
		emf.setDataSource(dsLedgerDB());
		emf.setPackagesToScan("verticelabs.ledger.domain");
		emf.setJpaVendorAdapter(vendorAdapter);
		emf.afterPropertiesSet();
		return emf.getObject();
	}

	@Bean(name = "txLedgerDB")
	public JpaTransactionManager txLedgerDB() {
		JpaTransactionManager transactionManager = new JpaTransactionManager();
		transactionManager.setEntityManagerFactory(emfLedgerDB());
		return transactionManager;
	}

}
