package BDConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;


public class CrudActorDirectorDAO {

    BDConnection ConnectionProvider;

    public CrudActorDirectorDAO() throws SQLException {
        ConnectionProvider = new BDConnection();
    }

    //criar um actor
    public int createActor(String actorName, String gender) {
        final String sql = "INSERT INTO actors (actorid, actorname, actorgender) VALUES (?,?, ?)";
        try (Connection conn = ConnectionProvider.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1,generarID());
            ps.setString(2, actorName);
            ps.setString(3, ""+gender.charAt(0));

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {return rs.getInt(1);}
                throw new SQLException("Falha ao obter ID gerado para Actor.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao criar Actor: " + e.getMessage(), e);
        }
    }

    //actulizar actor
    public boolean updateActor(int actorId, String actorName, String gender) {

        final String sql = "UPDATE actors SET actorname = ?, actorgender = ? WHERE actorid = ?";
        try (Connection conn = ConnectionProvider.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, actorName.trim());
            ps.setString(2,gender.trim().substring(0,1));
            ps.setInt(3, actorId);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao atualizar Actor: " + e.getMessage(), e);
        }
    }

    // Apaga um Director pelo ID.
    public boolean deleteActor(int actorId) {
        final String sql = "DELETE FROM actors WHERE actorid = ?";
        try (Connection conn = ConnectionProvider.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, actorId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao apagar actor: " + e.getMessage(), e);
        }
    }

    // ========= DIRECTOR =========
     //Cria um Director na base.
       public int createDirector(String directorName) {

        final String sql = "INSERT INTO directors (directorid,directorName) VALUES (?,?)";
        try (Connection conn = ConnectionProvider.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, generarID());
            ps.setString(2, directorName.trim());

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
                throw new SQLException("Falha ao obter ID gerado para Director.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao criar Director: " + e.getMessage(), e);
        }
    }

    //Atualiza um Director existente.
    public boolean updateDirector(int directorId, String directorName) {

        final String sql = "UPDATE directors SET directorName = ? WHERE directorid = ?";
        try (Connection conn = ConnectionProvider.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, directorName.trim());
            ps.setInt(2, directorId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao atualizar Director: " + e.getMessage(), e);
        }
    }


     // Apaga um Director pelo ID.
      public boolean deleteDirector(int directorId) {
        final String sql = "DELETE FROM directors WHERE directorid = ?";
        try (Connection conn = ConnectionProvider.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, directorId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao apagar Director: " + e.getMessage(), e);
        }
    }

    private int generarID(){
        LocalDateTime now = LocalDateTime.now();

        // Format: yyMMddHHmmss (yy = last two digits of year)
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyMMddmmss");

        return (int) (System.currentTimeMillis() / 1000 % Integer.MAX_VALUE);

    }

}
