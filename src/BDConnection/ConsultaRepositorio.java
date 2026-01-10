
package BDConnection;


import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ConsultaRepositorio {

    private final BDConnection bd;
    private String tipoEntidate;

    public ConsultaRepositorio() throws SQLException {
        this.bd = new BDConnection();
        tipoEntidate = null;
    }

    //contar participacoes de actores ou directores em filmes
    private int obterDado(String idName, int valueSearch, String entity) {
        String sql = "SELECT COUNT(*) FROM dbo." + entity + " WHERE " + idName + " = ?";

        try (Connection con = bd.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, valueSearch);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    return 0;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao contar participações de " + entity, e);
        }
    }


    //lista de directores com top limit
    public List<Map<String, Object>> listarTodosDirectores(int limit) throws SQLException {

        tipoEntidate = "Dir";

        String sql = "SELECT TOP "+limit+" * FROM dbo.Directors where hidden = 0 order by created_at desc";

        try (Connection con = bd.getConnection();

             PreparedStatement ps = con.prepareStatement(sql)){
            try (ResultSet rs = ps.executeQuery()) {
                return mapRows(rs);
            }
        }
        catch (SQLException e) {
              throw new RuntimeException("Erro ao consultar Directors", e);
        }

    }

    //lista de actores com top limit
    public List<Map<String, Object>> listarTodosActores(int limit) throws SQLException {

        tipoEntidate = "Act";
        String sql = "SELECT TOP "+limit+" * FROM dbo.Actors order by created_at desc";

        try (Connection con = bd.getConnection();

             PreparedStatement ps = con.prepareStatement(sql)){
            try (ResultSet rs = ps.executeQuery()) {
                return mapRows(rs);
            }
        }
        catch (SQLException e) {
            throw new RuntimeException("Erro ao consultar Actores", e);
        }
    }


    // Retorna actores por genero + continente
    public List<Map<String, Object>> findActorsByGenderAndContinent(String gender, String continentName) {
        final String sql = """
        SELECT DISTINCT 
            a.actorId, 
            a.actorName, 
            a.actorGender,
            ct.continentName
        FROM Actors a
        INNER JOIN MovieActor va ON a.actorId = va.actorId
        INNER JOIN MovieCountry vc ON va.movieId = vc.movieId
        INNER JOIN Country c ON vc.countryId = c.countryId
        INNER JOIN Continent ct ON c.continentId = ct.continentId
        WHERE a.actorGender = ? AND ct.continentName = ?
        """;

        try (Connection conn = bd.getConnection();

            PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, gender);
            ps.setString(2, continentName);

            try (ResultSet rs = ps.executeQuery()) {
                return mapRows(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao consultar atores por gênero e continente", e);
        }
    }


    // Retorna Top 5 Diretores a partir da view dbo.vw_Top5Directors
    public List<Map<String, Object>> getTop5Directors() {
        final String sql = "SELECT * FROM dbo.vw_Top5Directors";

        try (Connection conn = bd.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            return mapRows(rs);
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao consultar vw_Top5Directors", e);
        }
    }


    // Retorna lista do AuditLog de Directors por ObjectId
    public List<Map<String, Object>> getAuditLog() {
        final String sql = "SELECT * FROM dbo.AuditLog";

        try (Connection conn = bd.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                return mapRows(rs);
            }
            } catch (SQLException e) {
                throw new RuntimeException("Erro ao consultar AuditLog de Directors", e);
            }
    }


    // Executa a stored procedure TOP_MOVIES_WITH_MORE_GENDER e retorna a lista
    public List<Map<String, Object>> getTopMoviesWithMoreGender(int topN, int year, String gender) {
        final String call = "{ CALL dbo.TOP_MOVIES_WITH_MORE_GENDER(?, ?, ?) }";
        try (Connection conn = bd.getConnection();
             CallableStatement cs = conn.prepareCall(call)) {

            cs.setInt(1, topN);
            cs.setInt(2, year);
            cs.setString(3, gender);

            try (ResultSet rs = cs.executeQuery()) {

                return mapRows(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao executar TOP_MOVIES_WITH_MORE_GENDER", e);
        }
    }



    private List<Map<String, Object>> mapRows(ResultSet rs) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        ResultSetMetaData md = rs.getMetaData();
        int columns = md.getColumnCount();

        while (rs.next()) {
            // LinkedHashMap preserva ordem de inserção
            Map<String, Object> row = new LinkedHashMap<>(columns + 1);

            // 1) Primeiro adiciona TODAS as colunas originais na ordem do ResultSet
            for (int i = 1; i <= columns; i++) {
                String colName = md.getColumnLabel(i);
                if (colName == null || colName.isBlank()) {
                    colName = md.getColumnName(i);
                }
                row.put(colName, rs.getObject(i));
            }

            // 2) Depois adiciona o campo calculado (vai para o final)
            if (java.util.Objects.equals(tipoEntidate, "Dir")) {
                // ajuste o nome da coluna conforme existe no seu banco: "directorId" ou "DirectorId"
                int directorId = rs.getInt("directorId");
                int count = obterDado("directorId", directorId, "MovieDirector");
                row.put("Filmes_Dirigidos", count);

            } else if (java.util.Objects.equals(tipoEntidate, "Act")) {
                // ajuste o nome da coluna conforme existe no seu banco: "actorId" ou "ActorId"
                int actorId = rs.getInt("actorId");
                int count = obterDado("actorId", actorId, "MovieActor");
                row.put("Filmes_Participados", count);
            }

            rows.add(row);
        }
        return rows;
    }





}
