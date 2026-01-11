package BDConnection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class BDConnection {
    private String connectionUrl;
    private String sqlserver = "//localhost:1433";
    private String databaseName="deisIMDB";
    private String user="javaUser";
    private String password="ClientS@fe!Passw0rd";
    private String encrypt="true";
    private String trustServerCertificate="true";

    public BDConnection() throws SQLException {
       // connectionUrl = STR."jdbc:sqlserver:\{sqlserver};databaseName=\{databaseName};user=\{user};password=\{password};encrypt=\{encrypt};trustServerCertificate=\{trustServerCertificate};";

        connectionUrl  = "jdbc:sqlserver://localhost:1433;"
                + "databaseName=deisIMDB;"
                + "encrypt=true;"
                + "trustServerCertificate=true";

    }

    public String getConnectionUrl() {
        return connectionUrl;
    }

    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(connectionUrl,user, password);
    }

    @Override
    public String toString() {
        return  connectionUrl.toString();
    }

}
