package view;


import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;

public final class Toast {

    private Toast() {}

    public static void show(Component parent, String message, Color bg, int millis) {
        // Encontrar a janela (Frame/Dialog) que contém o parent
        Window win = SwingUtilities.getWindowAncestor(parent);
        if (win == null) {
            // fallback: tentar janela ativa
            win = KeyboardFocusManager.getCurrentKeyboardFocusManager().getActiveWindow();
            if (win == null) return;
        }

        // Criar JWindow "flutuante" acima da janela pai
        JWindow toast = new JWindow(win);
        toast.setBackground(new Color(0,0,0,0)); // transparente

        // Conteúdo visual do toast
        JLabel lbl = new JLabel(message, SwingConstants.CENTER);
        lbl.setOpaque(true);
        lbl.setBackground(bg);
        lbl.setForeground(Color.WHITE);
        lbl.setFont(lbl.getFont().deriveFont(Font.BOLD, 14f));
        lbl.setBorder(BorderFactory.createEmptyBorder(10, 16, 10, 16));

        // Container com cantos arredondados
        JPanel box = new JPanel() {
            @Override protected void paintComponent(Graphics g) {
                super.paintComponent(g);
                Graphics2D g2 = (Graphics2D) g.create();
                g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
                g2.setColor(bg);
                g2.fillRoundRect(0,0,getWidth(),getHeight(), 12,12);
                g2.dispose();
            }
        };
        box.setOpaque(false);
        box.setLayout(new BorderLayout());
        box.add(lbl, BorderLayout.CENTER);
        box.setBorder(BorderFactory.createEmptyBorder(2,2,2,2));

        toast.setContentPane(box);
        toast.pack();

        // Posicionar no topo-central da janela pai (10% da altura a partir do topo)
        Rectangle r = win.getBounds();
        int x = r.x + (r.width - toast.getWidth()) / 2;
        int y = r.y + (int)(r.height * 0.10); // 10% do topo
        toast.setLocation(x, y);

        // Mostrar
        toast.setOpacity(0f);
        toast.setVisible(true);

        // Fade-in
        Timer fadeIn = new Timer(15, null);
        fadeIn.addActionListener((ActionEvent e) -> {
            float op = toast.getOpacity();
            op = Math.min(1f, op + 0.08f);
            toast.setOpacity(op);
            if (op >= 1f) fadeIn.stop();
        });
        fadeIn.start();

        // Permanecer por 'millis' e fazer fade-out
        new Timer(millis, ev -> {
            Timer fadeOut = new Timer(15, null);
            fadeOut.addActionListener((ActionEvent e2) -> {
                float op = toast.getOpacity();
                op = Math.max(0f, op - 0.08f);
                toast.setOpacity(op);
                if (op <= 0f) {
                    fadeOut.stop();
                    toast.setVisible(false);
                    toast.dispose();
                }
            });
            fadeOut.start();
        }) {{ setRepeats(false); }}.start();
    }

    /** Atalhos de cor */
    public static Color success() { return new Color(0, 128, 0); }       // verde
    public static Color info()    { return new Color(0, 120, 212); }     // azul
    public static Color warning() { return new Color(225, 170, 0); }     // amarelo
    public static Color danger()  { return new Color(200, 45, 35); }     // vermelho
}

