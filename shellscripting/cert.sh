#cat /etc/secrets/gls-atlas-fes-api-kafka.nonprod.walmart.com.jks > /etc/secrets/SslTruststoreLocation.txt
#cat /etc/secrets/gls-atlas-fes-api-kafka.nonprod.walmart.com.jks > /etc/secrets/SslKeyStoreLocation.txt
#cat /etc/secrets/gls-atlas-order-tracker-kafka.nonprod.walmart.com.jks > /etc/secrets/SslTruststoreLocation.txt
#cat /etc/secrets/gls-atlas-order-tracker-kafka.nonprod.walmart.com.jks > /etc/secrets/SslKeyStoreLocation.txt
#liquibase --driver=com.microsoft.sqlserver.jdbc.SQLServerDriver --classpath=/Users/a0s01hy/Downloads/apache-tomcat-9.0.52/webapps/ROOT/WEB-INF/lib/mssql-jdbc-8.4.1.jre8.jar --changeLogFile=./initial-ddl.sql --url="jdbc:sqlserver://localhost:1433;database=NDOF_TRIP_EXEC" --username=sa --password=A_Str0ng_Required_Password update


