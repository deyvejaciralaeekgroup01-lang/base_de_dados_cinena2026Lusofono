
package control;

import BDConnection.ConsultaRepositorio;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;


import static java.util.Arrays.copyOf;

public class FilmeGUI extends JFrame {

    // Painéis principais
    private JPanel directoresPainel;
    private JPanel actorPainel;
    private JPanel estatisticaBottom;
    private JPanel content;
    private String[] cols;
    private Object[][] dados;
    // Repositório de leitura
    private ConsultaRepositorio repositorio;

    // Referências às tabelas (para dar refresh sem recriar)
    private JTableFilmes tableActors;
    private JTableFilmes tableDirectors;

    // Controle de inicialização
    private boolean startWithActor;

    public FilmeGUI(boolean startWithActor) throws SQLException {
        this.startWithActor = startWithActor;
        directoresPainel = new JPanel(new BorderLayout());
        actorPainel = new JPanel(new BorderLayout());
        estatisticaBottom = new JPanel(new BorderLayout());
        content = new JPanel(null);
        repositorio = new ConsultaRepositorio();

        iniApp();
        manageViews();  // constroi telas e carrega dados
    }

    private void iniApp() {
        setTitle("CinemaMovies");
        setExtendedState(JFrame.MAXIMIZED_BOTH);
        setLayout(null);
        setLocationRelativeTo(null);
        setIconImage(new ImageIcon("").getImage());
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

    private JPanel botoesPanelMenu() {
        JPanel buttonsWrapper = new JPanel(new FlowLayout(FlowLayout.LEFT, 20, 10));
        buttonsWrapper.setOpaque(false);

        JButton btnActors = new JButton("Actores");
        JButton btnDirectors = new JButton("Directores");
        JButton btnStats = new JButton("Estatísticas");

        // colors
        Color colorBack = new Color(16, 110, 190, 50);
        Color colorClick = new Color(0, 120, 212);

        btnActors.setForeground(Color.white);
        btnDirectors.setForeground(Color.white);
        btnStats.setForeground(Color.white);

        btnActors.setBackground(colorClick);
        btnDirectors.setBackground(colorBack);
        btnStats.setBackground(colorBack);

        Dimension btnSize = new Dimension(350, 45);
        btnActors.setPreferredSize(btnSize);
        btnDirectors.setPreferredSize(btnSize);
        btnStats.setPreferredSize(btnSize);

        btnActors.setFocusable(false);
        btnDirectors.setFocusable(false);
        btnStats.setFocusable(false);

        buttonsWrapper.add(btnActors);
        buttonsWrapper.add(btnDirectors);
        buttonsWrapper.add(btnStats);

        // Ações de navegação
        btnStats.addActionListener(e -> {
            actorPainel.setVisible(false);
            directoresPainel.setVisible(false);
            estatisticaBottom.setVisible(true);
            content.revalidate();
            content.repaint();
            try {
                jpanelEstatisticas(); // monta estatisticas
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
            btnActors.setBackground(colorBack);
            btnDirectors.setBackground(colorBack);
            btnStats.setBackground(colorClick);
        });

        btnActors.addActionListener(e -> {
            estatisticaBottom.setVisible(false);
            actorPainel.setVisible(true);
            directoresPainel.setVisible(false);
            content.revalidate();
            content.repaint();
            try {
                jpanelDirector();
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
            btnActors.setBackground(colorClick);
            btnDirectors.setBackground(colorBack);
            btnStats.setBackground(colorBack);
        });

        btnDirectors.addActionListener(e -> {
            estatisticaBottom.setVisible(false);
            actorPainel.setVisible(false);
            directoresPainel.setVisible(true);
            content.revalidate();
            content.repaint();
            try {
                jpanelDirector();
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
            btnActors.setBackground(colorBack);
            btnDirectors.setBackground(colorClick);
            btnStats.setBackground(colorBack);
        });

        return buttonsWrapper;
    }

    private JPanel titlePage(String titleScreen) {
        JPanel title = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 6));
        JLabel lblTitle = new JLabel(titleScreen, SwingConstants.LEFT);
        lblTitle.setFont(lblTitle.getFont().deriveFont(Font.BOLD, 18f));
        lblTitle.setBorder(javax.swing.BorderFactory.createEmptyBorder(4, 4, 4, 4));
        lblTitle.setAlignmentX(Component.LEFT_ALIGNMENT);
        title.add(lblTitle);
        return title;
    }


    private JPanel fieldsDirAct(String field1text, String field2text) {
        JPanel inputs = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 6));
        inputs.setOpaque(false);
        inputs.add(new JLabel(field1text));
        JTextField tfName = new JTextField(25);
        inputs.add(tfName);
        inputs.add(new JLabel(field2text));
        JTextField tfGender = new JTextField(25);
        inputs.add(tfGender);
        return inputs;
    }

    // Montar da tela
    private void manageViews() throws SQLException {
        setContentPane(content);

        // Top (menu)
        JPanel topPanel = new JPanel(new BorderLayout());
        topPanel.add(botoesPanelMenu(), BorderLayout.CENTER);
        content.add(topPanel);

        // Paineis
             // constroi e carrega actores
        content.add(actorPainel);
        actorPainel.setVisible(startWithActor);
        if(startWithActor){

            jpanelActor();

        }

          // constroi e carrega directores
        content.add(directoresPainel);
        directoresPainel.setVisible(!startWithActor);
        if(!startWithActor)jpanelDirector();


        content.add(estatisticaBottom);
        estatisticaBottom.setVisible(false);

        // Proporcoes e posicionamento
        ComponentAdapter resizeHandler = new ComponentAdapter() {
            @Override public void componentResized(ComponentEvent e) {
                int w = content.getWidth();
                int h = content.getHeight();
                int topH = (int) Math.round(h * 0.10);
                int bottomH = h - topH;

                topPanel.setBounds(0, 0, w, topH);
                estatisticaBottom.setBounds(0, topH, w, bottomH);
                actorPainel.setBounds(0, topH, w, bottomH);
                directoresPainel.setBounds(0, topH, w, bottomH);
            }
        };
        addComponentListener(resizeHandler);
        content.addComponentListener(resizeHandler);

        setVisible(true);
        resizeHandler.componentResized(null);
    }

    //Painel de Directores
    private void jpanelDirector() throws SQLException {
        // Lê da BD
        List<Map<String, Object>> rows = repositorio.listarTodosDirectores(15);

        // Extrai colunas existentes
        cols = rows.get(0).keySet().toArray(new String[0]);
        // Converte para matriz
        dados = rows.stream()
                .map(row -> Arrays.stream(cols).map(row::get).toArray())
                .toArray(Object[][]::new);

        // Top: titulo
        JPanel top = new JPanel();
        top.setLayout(new BoxLayout(top, BoxLayout.Y_AXIS));
        top.setOpaque(false);
        top.add(titlePage("Tela de Directores"));
        directoresPainel.add(top, BorderLayout.NORTH);

        // Tabela
        tableDirectors = new JTableFilmes();

        directoresPainel.add(
                tableDirectors.jtableGeneral(
                        dados,
                        cols,
                        fieldsDirAct("Nome do Director", "Sexo"),
                        false,
                        "Nome do director",
                        // Callback de refresh: ler BD novamente e atualizar tabela
                        () -> {
                            try {
                                loadDirectorsIntoTable();
                            } catch (SQLException ex) {
                                JOptionPane.showMessageDialog(this,
                                        "Erro ao recarregar Directores: " + ex.getMessage(),
                                        "Erro", JOptionPane.ERROR_MESSAGE);
                            }
                        }
                )
        );
    }

    // ====== Painel de Actores ======
    private void jpanelActor() throws SQLException {
        // Lê da BD

        List<Map<String, Object>> rows = repositorio.listarTodosActores(15);

        // Extrai colunas
        cols = rows.get(0).keySet().toArray(new String[0]);

        // Garante coluna "Actions" (UI)
        cols = copyOf(cols, cols.length + 1);
        cols[cols.length - 1] = "Actions";

        // Converte para matriz
        dados= rows.stream()
                .map(row -> Arrays.stream(cols).map(row::get).toArray())
                .toArray(Object[][]::new);

        // Top: titulo
        JPanel top = new JPanel();
        top.setLayout(new BoxLayout(top, BoxLayout.Y_AXIS));
        top.setOpaque(false);
        top.add(titlePage("Tela de Actores"));
        actorPainel.add(top, BorderLayout.NORTH);

        // Tabela
        tableActors = new JTableFilmes();
        actorPainel.add(
                tableActors.jtableGeneral(
                        dados,
                        cols,
                        fieldsDirAct("Nome do Actor", "Sexo"),
                        true,
                        "Nome do Actor",
                        // Callback de refresh: ler BD novamente e atualizar tabela
                        () -> {
                            try {
                                loadActorsIntoTable();
                            } catch (SQLException ex) {
                                JOptionPane.showMessageDialog(this,
                                        "Erro ao recarregar Actores: " + ex.getMessage(),
                                        "Erro", JOptionPane.ERROR_MESSAGE);
                            }
                        }
                )
        );

    }

    // ====== Painel de Estatisticas ======
    private void jpanelEstatisticas() throws SQLException {
        Estatisticas est = new Estatisticas();
        estatisticaBottom.add(est.procViewTrigSelec());
    }

    // ====== Métodos centralizados de recarga a partir da BD ======

    /** Recarrega Actores da BD e reaplica no JTableFilmes (sem recriar a UI) */
    private void loadActorsIntoTable() throws SQLException {
        List<Map<String, Object>> rows = repositorio.listarTodosActores(20);

        cols = rows.get(0).keySet().toArray(new String[0]);
        cols = Arrays.copyOf(cols, cols.length + 1);
        cols[cols.length - 1] = "Actions";


                dados = rows.stream()
                .map(row -> Arrays.stream(cols).map(row::get).toArray())
                .toArray(Object[][]::new);

        if (tableActors != null) {
            tableActors.setData(dados, cols);
        }
    }

    /** Recarrega Directores da BD e reaplica no JTableFilmes (sem recriar a UI) */
    private void loadDirectorsIntoTable() throws SQLException {
        List<Map<String, Object>> rows = repositorio.listarTodosDirectores(20);

        String[] colsLocal = rows.get(0).keySet().toArray(new String[0]);

        Object[][] dadosLocal = rows.stream()
                .map(row -> Arrays.stream(colsLocal).map(row::get).toArray())
                .toArray(Object[][]::new);

        if (tableDirectors != null) {
            tableDirectors.setData(dadosLocal, colsLocal);
        }
    }
}
