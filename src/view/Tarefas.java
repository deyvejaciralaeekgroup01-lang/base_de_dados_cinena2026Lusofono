package view;

import BDConnection.ConsultaRepositorio;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableColumn;
import javax.swing.table.TableModel;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

public class Tarefas extends  JFrame{

    private ConsultaRepositorio repositorio;
    private Object dados[][];

    public Tarefas(){}

    //retorna colunas
    public String [] cols(List<Map<String, Object>> rows){

        return rows.get(0).keySet().toArray(new String[0]);
    }

    ////retorna dados
    public Object [] [] dados(List<Map<String, Object>> rows, String cols []){

        dados= rows.stream().map(
                        row -> Arrays.stream(cols).map(row::get).toArray()
                )
                .toArray(Object[][]::new);

        return  dados;
    }


    public void hideColumnByName(JTable table, String columnName) {
        int viewIndex = table.getColumnModel().getColumnIndex(columnName);
        TableColumn col = table.getColumnModel().getColumn(viewIndex);
        // Remove a coluna da View; os dados continuam no TableModel
        table.getColumnModel().removeColumn(col);
    }

}


