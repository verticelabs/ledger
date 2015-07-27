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
	@PropertySource(value = "classpath:/ledger_test.properties", ignoreResourceNotFound = true)
})
@ComponentScan(basePackages = "verticelabs.ledger")
@EnableJpaRepositories(
		basePackages = "verticelabs.ledger.repository",
		entityManagerFactoryRef = "emfLedgerDB",
		transactionManagerRef = "txLedgerDB")
@EnableTransactionManagement
public class LedgerDBH2Config {

	@Autowired
	private Environment env;

	@Bean(name = "dsLedgerDB")
	public DataSource dsLedgerDB() {
//		EmbeddedDatabaseBuilder builder = new EmbeddedDatabaseBuilder();
//		return builder.setType(EmbeddedDatabaseType.H2).build();
		ComboPooledDataSource ds = new ComboPooledDataSource();
		try {
//			System.out.println("ledgerdb.driver=" + env.getProperty("ledgerdb.driver"));
			ds.setDriverClass(env.getProperty("ledgerdb.driver"));
		} catch (PropertyVetoException e) {
			return null;
		}
//		System.out.println("ledgerdb.user="+env.getProperty("ledgerdb.user"));
		ds.setUser(env.getProperty("ledgerdb.user"));
//		System.out.println("ledgerdb.password="+env.getProperty("ledgerdb.password"));
		ds.setPassword(env.getProperty("ledgerdb.password"));
//		System.out.println("ledgerdb.url="+env.getProperty("ledgerdb.url"));
		ds.setJdbcUrl(env.getProperty("ledgerdb.url"));

//		System.out.println("c3p0.minsize="+env.getProperty("c3p0.minsize"));
		ds.setMinPoolSize(env.getProperty("c3p0.minsize", Integer.class));
//		System.out.println("c3p0.maxsize="+env.getProperty("c3p0.maxsize"));
		ds.setMaxPoolSize(env.getProperty("c3p0.maxsize", Integer.class));
//		System.out.println("c3p0.maxidletime="+env.getProperty("c3p0.maxidletime"));
		ds.setMaxIdleTime(env.getProperty("c3p0.maxidletime", Integer.class));
//		System.out.println("c3p0.acquireincrement="+env.getProperty("c3p0.acquireincrement"));
		ds.setAcquireIncrement(env.getProperty("c3p0.acquireincrement",
				Integer.class));
//		System.out.println("c3p0.acquireretryattempts="+env.getProperty("c3p0.acquireretryattempts"));
		ds.setAcquireRetryAttempts(env.getProperty("c3p0.acquireretryattempts",
				Integer.class));
//		System.out.println("c3p0.initialsize="+env.getProperty("c3p0.initialsize"));
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
		vendorAdapter.setDatabase(Database.valueOf(env.getProperty("jpa.database")));
		vendorAdapter.setDatabasePlatform(env.getProperty("jpa.platform"));
		vendorAdapter.setGenerateDdl(env.getProperty("jpa.generateddl", Boolean.class));
//		System.out.println("jpa.showsql="+env.getProperty("jpa.showsql", Boolean.class));
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
