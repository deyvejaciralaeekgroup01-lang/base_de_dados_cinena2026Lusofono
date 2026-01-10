
package control;

import BDConnection.ConsultaRepositorio;
import view.Tarefas;
import view.Toast;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

public class Estatisticas {

    // Repositório e helpers
    private ConsultaRepositorio repositorio;
    private Tarefas tar;

    // Painel raiz
    private JPanel raiz;

    // Dados iniciais
    private List<Map<String, Object>> rowsA;
    private List<Map<String, Object>> rowsB;
    private List<Map<String, Object>> rowsC;
    private List<Map<String, Object>> rowsD;

    // ====== TABELA A (Top Movies With More Gender) ======
    private JTable tableA;
    private DefaultTableModel modelA;
    private JTextField txtTopA;
    private JTextField txtAnoA;
    private JTextField txtGeneroA;

    // ====== TABELA B (Top 5 Diretores) ======
    private JTable tableB;
    private DefaultTableModel modelB;

    // ====== TABELA C (Actors By Gender and Continent) ======
    private JTable tableC;
    private DefaultTableModel modelC;
    private JTextField txtGeneroC;
    private JTextField txtContNomeC;

    // ====== TABELA D (Audit Log) ======
    private JTable tableD;
    private DefaultTableModel modelD;

    Estatisticas() throws SQLException {
        repositorio = new ConsultaRepositorio();
        tar = new Tarefas();

        // Carrega dados iniciais (ajuste os parâmetros conforme desejar)
        rowsA = repositorio.getTopMoviesWithMoreGender(10, 2000, "M");
        rowsB = repositorio.getTop5Directors();
        rowsC = repositorio.findActorsByGenderAndContinent("M", "Asia");
        rowsD = repositorio.getAuditLog();
    }

    public JPanel procViewTrigSelec() throws SQLException {
        raiz = new JPanel(new GridLayout(2, 2, 12, 12));
        raiz.setBorder(new EmptyBorder(12, 12, 12, 12));

        // ====== A ======
        JPanel celulaA = criarPainelVertical();
        celulaA.add(criarLinhaLabelEsquerda("2.11 TOP_MOVIES_WITH_MORE_GENDER"));
        celulaA.add(criarLinhaPesquisaA()); // cria inputs e botao (mantém refs)
        {
            String[] colA = tar.cols(rowsA);
            Object[][] dadosA = tar.dados(rowsA, colA);
            JScrollPane sc = criarTabelaScrollPersistente(colA, dadosA, 'A'); // cria tableA/modelA
            celulaA.add(sc);
        }

        // ====== B ======
        String[] colB = tar.cols(rowsB);
        Object[][] dadosB = tar.dados(rowsB, colB);
        JPanel celulaB = criarPainelLabelETabelaPersistente("1.1. View de 5 Top diretores", colB, dadosB, 'B');

        // ====== C ======
        JPanel celulaC = criarPainelVertical();
        celulaC.add(criarLinhaLabelEsquerda("4.3 Lista de atores pelo sexo e continente"));
        celulaC.add(criarLinhaFiltrosC()); // cria inputs e botao (mantém refs)
        {
            String[] colC = tar.cols(rowsC);
            Object[][] dadosC = tar.dados(rowsC, colC);
            JScrollPane sc = criarTabelaScrollPersistente(colC, dadosC, 'C'); // cria tableC/modelC
            celulaC.add(sc);
        }

        // ====== D ======
        String[] colD = tar.cols(rowsD);
        Object[][] dadosD = tar.dados(rowsD, colD);
        JPanel celulaD = criarPainelLabelETabelaPersistente("3.2 Lista de Auditoria para Actor e Diretores", colD, dadosD, 'D');

        // Adiciona 2x2
        raiz.add(celulaA);
        raiz.add(celulaC);
        raiz.add(celulaB);
        raiz.add(celulaD);

        return raiz;
    }

    // ===========================
    //    Construçao de painéis
    // ===========================
    private JPanel criarPainelVertical() {
        JPanel p = new JPanel();
        p.setLayout(new BoxLayout(p, BoxLayout.Y_AXIS));
        p.setBorder(new EmptyBorder(10, 10, 10, 10));
        return p;
    }

    private JPanel criarLinhaLabelEsquerda(String titulo) {
        JPanel linha = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 0));
        JLabel label = new JLabel(titulo);
        label.setFont(label.getFont().deriveFont(Font.BOLD, 14f));
        linha.add(label);
        return linha;
    }

    // ===========================
    //   Linha de pesquisa A
    // ===========================
    private JPanel criarLinhaPesquisaA() {
        JPanel linha = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 0));

        JLabel lblTop = new JLabel("Top:");
        txtTopA = new JTextField(6);

        JLabel lblAno = new JLabel("Ano:");
        txtAnoA = new JTextField(6);

        JLabel lblGenero = new JLabel("Genero (M/F):");
        txtGeneroA = new JTextField(2);

        JButton btnPesquisar = new JButton("Buscar na BD");
        btnPesquisar.addActionListener(e -> {
            try {
                onPesquisarA();
            } catch (Exception ex) {
                ex.printStackTrace();
                JOptionPane.showMessageDialog(raiz, "Erro na pesquisa A: " + ex.getMessage());
            }
        });

        linha.add(lblTop);
        linha.add(txtTopA);
        linha.add(lblAno);
        linha.add(txtAnoA);
        linha.add(lblGenero);
        linha.add(txtGeneroA);
        linha.add(btnPesquisar);
        return linha;
    }

    private void onPesquisarA() {
        String sTop = safeText(txtTopA);
        String sAno = safeText(txtAnoA);
        String sGen = safeText(txtGeneroA);

        if (sTop.isEmpty() || sAno.isEmpty() || sGen.isEmpty()) {
            JOptionPane.showMessageDialog(raiz, "Os campos nao podem ser vazios!");
            return;
        }

        int top;
        int ano;
        try {
            top = Integer.parseInt(sTop);
            ano = Integer.parseInt(sAno);
        } catch (NumberFormatException nfe) {
            JOptionPane.showMessageDialog(raiz, "Top e Ano devem ser numéricos.");
            return;
        }

        String genero = normalizeGenderChar(sGen);
        if (genero == null) {
            JOptionPane.showMessageDialog(raiz, "Genero deve ser 'M' ou 'F'.");
            return;
        }

        List<Map<String, Object>> resultado = repositorio.getTopMoviesWithMoreGender(top, ano, genero);
        if (resultado == null || resultado.isEmpty()) {
            Toast.show(raiz, "Nao existem dados para sua consulta, tente com outros", Toast.warning(), 30000);
            // Opcional: limpar tabela A
            refreshModel(modelA, new String[]{"Sem dados"}, new Object[][]{{"—"}}, tableA);
            return;
        }

        String[] cols = resultado.get(0).keySet().toArray(new String[0]);
        Object[][] dados = resultado.stream()
                .map(row -> Arrays.stream(cols).map(row::get).toArray())
                .toArray(Object[][]::new);

        refreshModel(modelA, cols, dados, tableA);
    }

    // ===========================
    //   Linha de pesquisa C
    // ===========================
    private JPanel criarLinhaFiltrosC() {
        JPanel linha = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 0));

        JLabel lblGenero = new JLabel("Genero (M/F):");
        txtGeneroC = new JTextField(2);

        JLabel lblCont = new JLabel("Continente:");
        txtContNomeC = new JTextField(10);

        JButton btnPesquisar = new JButton("Buscar na BD");
        btnPesquisar.addActionListener(e -> {
            try {
                onPesquisarC();
            } catch (Exception ex) {
                ex.printStackTrace();
                JOptionPane.showMessageDialog(raiz, "Erro na pesquisa C: " + ex.getMessage());
            }
        });

        linha.add(lblGenero);
        linha.add(txtGeneroC);
        linha.add(lblCont);
        linha.add(txtContNomeC);
        linha.add(btnPesquisar);
        return linha;
    }

    private void onPesquisarC() {
        String sGen = safeText(txtGeneroC);
        String contiName = safeText(txtContNomeC);

        if (sGen.isEmpty() || contiName.isEmpty()) {
            JOptionPane.showMessageDialog(raiz, "Os campos nao podem ser vazios!");
            return;
        }

        String genero = normalizeGenderChar(sGen);
        if (genero == null) {
            JOptionPane.showMessageDialog(raiz, "Genero deve ser 'M' ou 'F'.");
            return;
        }

        List<Map<String, Object>> resultado = repositorio.findActorsByGenderAndContinent(genero, contiName);
        if (resultado == null || resultado.isEmpty()) {
            Toast.show(raiz, "Nao existem dados para sua consulta, tente com outros", Toast.danger(), 10000);
            // Opcional: limpar tabela C
            refreshModel(modelC, new String[]{"Sem dados"}, new Object[][]{{"—"}}, tableC);
            return;
        }

        String[] cols = resultado.get(0).keySet().toArray(new String[0]);
        Object[][] dados = resultado.stream()
                .map(row -> Arrays.stream(cols).map(row::get).toArray())
                .toArray(Object[][]::new);

        refreshModel(modelC, cols, dados, tableC);
    }

    // ===========================
    //   Criacao das tabelas
    // ===========================
    private JScrollPane criarTabelaScrollPersistente(String[] colunas, Object[][] dados, char qualTabela) {
        DefaultTableModel modelo = new DefaultTableModel(dados, colunas) {
            @Override public boolean isCellEditable(int row, int column) { return false; }
        };
        JTable tabela = new JTable(modelo);
        tabela.setFillsViewportHeight(true);
        tabela.setAutoResizeMode(JTable.AUTO_RESIZE_ALL_COLUMNS);
        tabela.setRowHeight(22);
        JScrollPane scroll = new JScrollPane(tabela);
        scroll.setPreferredSize(new Dimension(400, 250));

        switch (qualTabela) {
            case 'A' -> { tableA = tabela; modelA = modelo; }
            case 'B' -> { tableB = tabela; modelB = modelo; }
            case 'C' -> { tableC = tabela; modelC = modelo; }
            case 'D' -> { tableD = tabela; modelD = modelo; }
        }
        return scroll;
    }

    // Para B e D com label + tabela (e também persistente)
    private JPanel criarPainelLabelETabelaPersistente(String titulo, String[] colunas, Object[][] dados, char qualTabela) {
        JPanel painel = criarPainelVertical();
        painel.add(criarLinhaLabelEsquerda(titulo));
        painel.add(criarTabelaScrollPersistente(colunas, dados, qualTabela));
        return painel;
    }

    // ===========================
    //   Utilitários
    // ===========================
    private void refreshModel(DefaultTableModel model, String[] cols, Object[][] data, JTable table) {
        if (model == null) return;
        // Atualiza as colunas e os dados
        model.setDataVector(data, cols);
        // Reaplica preferencias da tabela se necessário
        if (table != null) {
            table.revalidate();
            table.repaint();
        }
    }

    private String safeText(JTextField tf) {
        return tf == null || tf.getText() == null ? "" : tf.getText().trim();
    }

    /**
     * Normaliza "M"/"F" a partir de entradas como "M", "F", "Masculino", "Feminino".
     * Retorna "M" ou "F"; retorna null se nao reconhecido.
     */
    private String normalizeGenderChar(String s) {
        if (s == null) return null;
        s = s.trim();
        if (s.isEmpty()) return null;

        if (s.length() == 1) {
            char c = Character.toUpperCase(s.charAt(0));
            return (c == 'M' || c == 'F') ? String.valueOf(c) : null;
        }
        String lower = s.toLowerCase();
        if (lower.startsWith("m")) return "M";
        if (lower.startsWith("f")) return "F";
        return null;
        // Obs: Se preferir validar estritamente apenas 'M'/'F', remova os startsWith acima.
    }
}
