
package control;
import BDConnection.CrudActorDirectorDAO;
import view.Tarefas;
import view.Toast;
import javax.swing.*;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableColumn;
import javax.swing.table.TableRowSorter;
import java.awt.*;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Objects;
import java.util.regex.Pattern;

public class JTableFilmes {
    // ===== Campos de classe =====
    private DefaultTableModel model;
    JPanel panel;
    private CrudActorDirectorDAO cruDirAc;
    private boolean isActorGlobal;
    Tarefas tar;
    //mudar o texto para Adicionar ou Adicionar
    private String btnText;
    // Filtro (no topo)
    private JTextField tfFilter;
    // Campos de formulario (rodape)
    private JTextField tfNomeInput;
    private JComboBox<String> cbSexo;
    private JButton btnAdd;
    //for updates
    private int idUpdate;
    // JTable (referencia) para reaplicar model/sorter/renderers
    private JTable table;

    // ===== Novos campos =====
    private Runnable onDataChangedRef;                    // preserva callback
    private TableRowSorter<DefaultTableModel> sorter;     // preserva sorter/filtro

    public JTableFilmes() throws SQLException {
        panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(8, 8, 8, 8));
        panel.setBackground(new Color(245, 245, 245));
        tfFilter = new JTextField("");
        cruDirAc = new CrudActorDirectorDAO();
        tar = new Tarefas();
        btnText = "Adicionar";
    }

    public JPanel jtableGeneral(Object[][] dados, String[] cols, JPanel inputs, boolean isActor, String labelText) {
        return jtableGeneral(dados, cols, inputs, isActor, labelText, null);
    }

    public JPanel jtableGeneral(Object[][] dados, String[] cols, JPanel inputs, boolean isActor, String labelText,
                                Runnable onDataChanged) {
        String[] colsFinal = ensureActionsColumn(cols);
        isActorGlobal = isActor;
        Object[][] dadosFinal = ensureActionsData(dados, colsFinal);

        JTable table = tabela(dadosFinal, colsFinal);
        this.table = table;
        this.model = (DefaultTableModel) table.getModel();

        ((DefaultTableCellRenderer) table.getDefaultRenderer(Object.class))
                .setHorizontalAlignment(SwingConstants.CENTER);

        this.sorter = new TableRowSorter<>(model);
        table.setRowSorter(this.sorter);

        JPanel header = new JPanel();
        header.setLayout(new BoxLayout(header, BoxLayout.Y_AXIS));
        header.setOpaque(false);

        JPanel filterPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 6, 6));
        filterPanel.setOpaque(false);
        filterPanel.add(new JLabel("Filtro:"));

        final JTextField tfFilterLocal = new JTextField(25);
        JButton btnClearFilter = new JButton("Limpar filtro");

        filterPanel.add(tfFilterLocal);
        filterPanel.add(btnClearFilter);

        this.tfFilter = tfFilterLocal;

        tfFilterLocal.getDocument().addDocumentListener(new javax.swing.event.DocumentListener() {
            private void apply() {
                String text = tfFilterLocal.getText();
                if (text == null || text.trim().isEmpty()) {
                    sorter.setRowFilter(null);
                } else {
                    sorter.setRowFilter(RowFilter.regexFilter("(?i)" + Pattern.quote(text)));
                }
            }
            public void insertUpdate(javax.swing.event.DocumentEvent e) { apply(); }
            public void removeUpdate(javax.swing.event.DocumentEvent e) { apply(); }
            public void changedUpdate(javax.swing.event.DocumentEvent e) { apply(); }
        });

        btnClearFilter.addActionListener(e -> {
            tfFilterLocal.setText("");
            sorter.setRowFilter(null);
        });

        header.add(filterPanel);
        panel.add(header, BorderLayout.NORTH);

        final int[] hoverRow = {-1};
        table.addMouseMotionListener(new java.awt.event.MouseMotionAdapter() {
            @Override public void mouseMoved(java.awt.event.MouseEvent e) {
                int row = table.rowAtPoint(e.getPoint());
                if (row != hoverRow[0]) {
                    hoverRow[0] = row;
                    table.repaint();
                }
            }
        });
        table.addMouseListener(new java.awt.event.MouseAdapter() {
            @Override public void mouseExited(java.awt.event.MouseEvent e) {
                hoverRow[0] = -1;
                table.repaint();
            }
            @Override public void mouseClicked(java.awt.event.MouseEvent e) {
                int row = table.rowAtPoint(e.getPoint());
                if (row >= 0) table.setRowSelectionInterval(row, row);
            }
        });

        DefaultTableCellRenderer hoverRenderer = new DefaultTableCellRenderer() {
            @Override
            public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected,
                                                           boolean hasFocus, int row, int column) {
                Component c = super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
                if (!isSelected) {
                    c.setBackground(row == hoverRow[0] ? new Color(235, 245, 255) : Color.WHITE);
                }
                return c;
            }
        };
        for (int i = 0; i < table.getColumnCount(); i++) {
            if (!"Actions".equals(table.getColumnName(i))) {
                table.getColumnModel().getColumn(i).setCellRenderer(hoverRenderer);
            }
        }

        this.onDataChangedRef = onDataChanged;

        setupActionsColumn(table, model, "Actions", onDataChanged);

        if (Arrays.asList(colsFinal).contains("created_at")) {
            tar.hideColumnByName(table, "created_at");
        }

        JPanel bottomControls = new JPanel();
        bottomControls.setLayout(new BoxLayout(bottomControls, BoxLayout.Y_AXIS));
        bottomControls.setOpaque(false);

        JPanel inputsLine = new JPanel(new FlowLayout(FlowLayout.LEFT, 6, 6));
        inputsLine.setOpaque(false);

        JLabel lblNome = new JLabel(labelText);
        tfNomeInput = new JTextField(20);
        JLabel lblSexo = new JLabel("Sexo:");
        cbSexo = new JComboBox<>(new String[]{"Masculino", "Feminino"});

        lblSexo.setVisible(isActor);
        cbSexo.setVisible(isActor);

        btnAdd = new JButton(btnText);

        inputsLine.add(lblNome);
        inputsLine.add(tfNomeInput);
        inputsLine.add(lblSexo);
        inputsLine.add(cbSexo);
        inputsLine.add(btnAdd);

        btnAdd.addActionListener(e -> {
            if (!tfNomeInput.getText().trim().isEmpty()) {
                // Executar operação de BD fora da EDT
                if ("Adicionar".equals(btnText)) {
                    // CREATE
                    new SwingWorker<Void, Void>() {
                        @Override
                        protected Void doInBackground() throws Exception {
                            if (isActorGlobal) {
                                String nome = tfNomeInput.getText().trim();
                                String generoUI = (String) cbSexo.getSelectedItem();
                                String generoDB = normalizeGenderToChar(generoUI);
                                cruDirAc.createActor(nome, generoDB);
                            } else {
                                cruDirAc.createDirector(tfNomeInput.getText().trim());
                            }
                            return null;
                        }
                        @Override
                        protected void done() {
                            try {
                                get();
                                if (isActorGlobal) {
                                    Toast.show(panel, "Actor criado com sucesso!", Toast.success(), 3000);
                                } else {
                                    JOptionPane.showMessageDialog(panel,"Director criado com sucesso!");
                                    //Toast.show(panel, "Director criado com sucesso!", Toast.success(), 1000);
                                }
                                // Limpar campos e voltar a modo "Adicionar"
                                tfNomeInput.setText("");
                                btnText = "Adicionar";
                                btnAdd.setText(btnText);
                                if (isActorGlobal) cbSexo.setSelectedIndex(0);

                                // Recarregar da BD, se callback fornecido
                                if (onDataChangedRef != null) onDataChangedRef.run();

                            } catch (Exception exAdd) {
                                JOptionPane.showMessageDialog(panel, "Erro ao adicionar: " + exAdd.getMessage(),
                                        "Erro", JOptionPane.ERROR_MESSAGE);
                            }
                        }
                    }.execute();
                } else {
                    // UPDATE
                    final String novoNome = tfNomeInput.getText().trim();
                    final String generoUI = (String) cbSexo.getSelectedItem();
                    final String generoDB = isActorGlobal ? normalizeGenderToChar(generoUI) : null;

                    new SwingWorker<Void, Void>() {
                        @Override
                        protected Void doInBackground() throws Exception {
                            if (isActorGlobal) {
                                cruDirAc.updateActor(idUpdate, novoNome, generoDB);
                            } else {
                                cruDirAc.updateDirector(idUpdate, novoNome);
                            }
                            return null;
                        }
                        @Override
                        protected void done() {
                            try {
                                get();
                                if (isActorGlobal) {
                                    Toast.show(panel, "Actor editado com sucesso!", Toast.success(), 3000);
                                } else {
                                    JOptionPane.showMessageDialog(panel,"Director Editado com sucesso!");
                                    //Toast.show(panel, "Director editado com sucesso!", Toast.success(), 1000);
                                }

                                // Atualizar imediatamente o modelo (linha atualmente selecionada)
                                int viewRow = table.getSelectedRow();
                                if (viewRow >= 0) {
                                    int modelRow = table.convertRowIndexToModel(viewRow);
                                    // 0 = ID, 1 = Nome, 2 = Sexo (se existir)
                                    if (model.getColumnCount() > 1) model.setValueAt(novoNome, modelRow, 1);
                                    if (isActorGlobal && model.getColumnCount() > 2) {
                                        model.setValueAt(generoDB != null ? generoDB : "", modelRow, 2);
                                    }
                                }

                                // Limpar campos e restaurar modo
                                tfNomeInput.setText("");
                                btnText = "Adicionar";
                                btnAdd.setText(btnText);
                                if (isActorGlobal) cbSexo.setSelectedIndex(0);

                                // Recarregar da BD, se callback fornecido
                                if (onDataChangedRef != null) onDataChangedRef.run();

                            } catch (Exception exUpd) {
                                JOptionPane.showMessageDialog(panel, "Erro ao actualizar: " + exUpd.getMessage(),
                                        "Erro", JOptionPane.ERROR_MESSAGE);
                            }
                        }
                    }.execute();
                }
            } else {
                tfNomeInput.setBorder(BorderFactory.createLineBorder(Color.RED));
                Timer t = new Timer(1200, ev -> tfNomeInput.setBorder(UIManager.getBorder("TextField.border")));
                t.setRepeats(false);
                t.start();
            }
        });

        bottomControls.add(inputsLine);
        panel.add(bottomControls, BorderLayout.SOUTH);

        panel.revalidate();
        panel.repaint();

        return panel;
    }

    /** Cria a JTable com modelo que so permite edicao na coluna "Actions". */
    public JTable tabela(Object[][] dados, String[] cols) {
        model = new DefaultTableModel(dados, cols) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return "Actions".equals(getColumnName(column));
            }
        };

        final JTable table = new JTable(model);
        table.setFillsViewportHeight(true);
        table.setRowHeight(36);
        table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        table.getTableHeader().setFont(table.getTableHeader().getFont().deriveFont(Font.BOLD));

        JScrollPane scroll = new JScrollPane(table);
        scroll.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);

        JPanel center = new JPanel(new BorderLayout(6, 6));
        center.setOpaque(false);
        center.add(scroll, BorderLayout.CENTER);

        panel.add(center, BorderLayout.CENTER);
        return table;
    }

    private String[] ensureActionsColumn(String[] cols) {
        if (cols == null) {
            return new String[]{"Actions"};
        }
        boolean hasActions = Arrays.asList(cols).contains("Actions");
        if (hasActions) return cols;
        String[] out = Arrays.copyOf(cols, cols.length + 1);
        out[out.length - 1] = "Actions";
        return out;
    }

    private Object[][] ensureActionsData(Object[][] dados, String[] colsFinal) {
        if (dados == null || dados.length == 0) {
            return new Object[0][colsFinal.length];
        }
        int expectedCols = colsFinal.length;
        boolean needsExpand = dados[0].length < expectedCols;
        if (!needsExpand) return dados;

        Object[][] expanded = new Object[dados.length][expectedCols];
        for (int i = 0; i < dados.length; i++) {
            Object[] src = dados[i];
            Object[] dst = Arrays.copyOf(src, expectedCols);
            dst[expectedCols - 1] = null;
            expanded[i] = dst;
        }
        return expanded;
    }

    private void setupActionsColumn(JTable table, DefaultTableModel model, String actionsColName,
                                    Runnable onDataChanged) {
        int actionsColIndex = -1;
        for (int i = 0; i < table.getColumnModel().getColumnCount(); i++) {
            if (Objects.equals(actionsColName, table.getColumnName(i))) {
                actionsColIndex = i;
                break;
            }
        }
        if (actionsColIndex < 0) return;

        final Runnable refreshCb = (onDataChanged != null) ? onDataChanged : this.onDataChangedRef;

        class ActionsRenderer extends JPanel implements javax.swing.table.TableCellRenderer {
            private final JButton editBtn = new JButton("\u270E"); // ✎
            private final JButton delBtn = new JButton("\u2716"); // ✖
            ActionsRenderer() {
                setLayout(new FlowLayout(FlowLayout.CENTER, 6, 0));
                setOpaque(true);
                for (JButton b : new JButton[]{editBtn, delBtn}) {
                    b.setFocusable(false);
                    b.setBorderPainted(false);
                    b.setContentAreaFilled(false);
                    b.setOpaque(false);
                    b.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
                }
                editBtn.setToolTipText("Editar");
                delBtn.setToolTipText("Eliminar");
                add(editBtn);
                add(delBtn);
            }
            @Override
            public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected,
                                                           boolean hasFocus, int row, int column) {
                setBackground(isSelected ? table.getSelectionBackground() : table.getBackground());
                return this;
            }
        }

        class ActionsEditor extends javax.swing.AbstractCellEditor implements javax.swing.table.TableCellEditor {
            private final JPanel editorPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 6, 0));
            private final JButton editBtn = new JButton("\u270E");
            private final JButton delBtn = new JButton("\u2716");
            private int editingRow = -1;

            ActionsEditor() {
                editorPanel.setOpaque(true);
                for (JButton b : new JButton[]{editBtn, delBtn}) {
                    b.setFocusable(false);
                    b.setBorderPainted(false);
                    b.setContentAreaFilled(false);
                    b.setOpaque(false);
                    b.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
                }
                editBtn.setToolTipText("Editar");
                delBtn.setToolTipText("Eliminar");
                editorPanel.add(editBtn);
                editorPanel.add(delBtn);

                // EDITAR
                editBtn.addActionListener(e -> {
                    btnText = "Actualizar";
                    btnAdd.setText(btnText);

                    int modelRow = table.convertRowIndexToModel(editingRow);
                    Object idVal = model.getValueAt(modelRow, 0);
                    idUpdate = Integer.parseInt(idVal.toString());

                    Object nomeVal = (model.getColumnCount() > 1) ? model.getValueAt(modelRow, 1) : null;
                    Object sexoVal = (model.getColumnCount() > 2) ? model.getValueAt(modelRow, 2) : null;

                    if (isActorGlobal) {
                        tfNomeInput.setText(nomeVal != null ? nomeVal.toString() : "");
                        if (sexoVal != null) {
                            String s = sexoVal.toString().trim();
                            String sexoUI = s.equalsIgnoreCase("M") ? "Masculino" :
                                    s.equalsIgnoreCase("F") ? "Feminino" : s;
                            cbSexo.setSelectedItem(sexoUI);
                        } else {
                            cbSexo.setSelectedIndex(-1);
                        }
                    } else {
                        tfNomeInput.setText(nomeVal != null ? nomeVal.toString() : "");
                    }

                    fireEditingStopped();
                });

                // ELIMINAR
                delBtn.addActionListener(e -> {
                    // encerrar editor imediatamente para evitar loops na EDT
                    fireEditingStopped();

                    int modelRow = table.convertRowIndexToModel(editingRow);
                    Object val = model.getValueAt(modelRow, 0);
                    int id = (val instanceof Number) ? ((Number) val).intValue()
                            : (val != null ? Integer.parseInt(val.toString()) : -1);

                        int confirm = JOptionPane.showConfirmDialog(SwingUtilities.getWindowAncestor(panel),
                                "Eliminar registro ID " + id + "?", "Confirmar eliminação", JOptionPane.YES_NO_OPTION);
                        if (confirm == JOptionPane.YES_OPTION) {
                            // Operação de BD fora da EDT
                            new SwingWorker<Void, Void>() {
                                @Override
                                protected Void doInBackground() throws Exception {

                                    if (isActorGlobal){
                                        cruDirAc.deleteActor(id);
                                    }else{
                                        cruDirAc.deleteDirector(id);
                                    }

                                    return null;
                                }
                                @Override
                                protected void done() {
                                    try {
                                        get();
                                        // Atualizar UI na EDT
                                        //Toast.show(panel, "Director eliminado com sucesso!", Toast.success(), 1000);

                                        if (isActorGlobal){
                                            JOptionPane.showMessageDialog(panel,"Actor eliminado com sucesso!");
                                        }else{
                                            JOptionPane.showMessageDialog(panel,"Director eliminado com sucesso!");
                                        }

                                        // Remover imediatamente a linha do modelo
                                        if (modelRow >= 0 && modelRow < model.getRowCount()) {
                                            model.removeRow(modelRow);
                                        }

                                        // Se houver callback, recarrega da BD (opcional)
                                        if (refreshCb != null) refreshCb.run();

                                    } catch (Exception exDel) {
                                        JOptionPane.showMessageDialog(panel, "Erro ao eliminar: " + exDel.getMessage(),
                                                "Erro", JOptionPane.ERROR_MESSAGE);
                                    }
                                }
                            }.execute();
                        }

                });
            }

            @Override
            public Component getTableCellEditorComponent(JTable table, Object value, boolean isSelected,
                                                         int row, int column) {
                this.editingRow = row;
                editorPanel.setBackground(table.getSelectionBackground());
                return editorPanel;
            }
            @Override public Object getCellEditorValue() { return null; }
        }

        TableColumn col = table.getColumnModel().getColumn(actionsColIndex(table, actionsColName));
        col.setCellRenderer(new ActionsRenderer());
        col.setCellEditor(new ActionsEditor());
        col.setPreferredWidth(140);
        col.setMinWidth(120);
        col.setMaxWidth(180);
    }

    private int actionsColIndex(JTable table, String actionsColName) {
        for (int i = 0; i < table.getColumnModel().getColumnCount(); i++) {
            if (Objects.equals(actionsColName, table.getColumnName(i))) {
                return i;
            }
        }
        return -1;
    }

    public void setData(Object[][] dados, String[] cols) {
        String[] colsFinal = ensureActionsColumn(cols);
        Object[][] dadosFinal = ensureActionsData(dados, colsFinal);

        DefaultTableModel newModel = new DefaultTableModel(dadosFinal, colsFinal) {
            @Override public boolean isCellEditable(int row, int column) {
                return "Actions".equals(getColumnName(column));
            }
        };

        this.model = newModel;
        this.table.setModel(newModel);

        this.sorter = new TableRowSorter<>(newModel);
        this.table.setRowSorter(this.sorter);

        if (this.tfFilter != null) {
            String text = this.tfFilter.getText();
            if (text != null && !text.trim().isEmpty()) {
                this.sorter.setRowFilter(RowFilter.regexFilter("(?i)" + Pattern.quote(text)));
            } else {
                this.sorter.setRowFilter(null);
            }
        }

        setupActionsColumn(this.table, newModel, "Actions", this.onDataChangedRef);

        this.table.revalidate();
        this.table.repaint();

        if (Arrays.asList(colsFinal).contains("created_at")) {
            tar.hideColumnByName(table, "created_at");
        }
    }

    private String normalizeGenderToChar(String gender) {
        if (gender == null) return null;
        String s = gender.trim();
        if (s.isEmpty()) return null;
        if (s.length() == 1) {
            char c = Character.toUpperCase(s.charAt(0));
            return (c == 'M' || c == 'F') ? String.valueOf(c) : null;
        }
        String lower = s.toLowerCase();
        if (lower.startsWith("m")) return "M";
        if (lower.startsWith("f")) return "F";
        return null;
    }
}
