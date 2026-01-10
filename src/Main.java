import BDConnection.ConsultaRepositorio;
import control.FilmeGUI;

import javax.swing.*;
import control.FilmeGUI;
import view.Tarefas;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;


public class Main extends JFrame {

    Main() throws SQLException {
        FilmeGUI fgui = new FilmeGUI(true);

    }
    public static void main(String[] args) throws SQLException {
        new Main();

    }
    }
