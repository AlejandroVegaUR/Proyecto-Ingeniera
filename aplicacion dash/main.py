
from colorama import Style
import dash
from dash import dcc
from dash import html
import plotly.express as px
import pandas as pd
from Connection_p import Connection
import plotly.graph_objects as go
import proyecto  as sql

app = dash.Dash(__name__)

con = Connection()
con.openConnection()
# queries
query_1 = pd.read_sql_query(sql.vuelo_tickets(), con.connection)
query_2 = pd.read_sql_query(sql.vuelo_hora(), con.connection)
query_3 = pd.read_sql_query(sql.num_aviones(), con.connection)
query_4 = pd.read_sql_query(sql.nacionalidad(), con.connection)
#query_5 = pd.read_sql_query(sql.destino(), con.connection)
query_6 = pd.read_sql_query(sql.modelos(), con.connection)
query_7 = pd.read_sql_query(sql.nacionalidad_asc(), con.connection)
query_8= pd.read_sql_query(sql.mapa(), con.connection)
con.closeConnection()
#Dataframes
aeropuertos = pd.DataFrame(query_1, columns=["id_vuelo","num_tickets"])
vuelos_hora= pd.DataFrame(query_2, columns=["hora_llegada", "total"])
num_aviones= pd.DataFrame(query_3, columns=["aerolinea", "num_aviones"])
nacionalidad= pd.DataFrame(query_4, columns=["nacionalidad", "total"])
nacionalidad_asc= pd.DataFrame(query_7, columns=["nacionalidad", "total"])
#destino= pd.DataFrame(query_5, columns=["ciudad", "total"])
modelos= pd.DataFrame(query_6, columns=["nombre", "total"])
mapa= pd.DataFrame(query_8, columns=["codigo_pais", "total"])
print(nacionalidad)

fondo   = "#161a28"
fondo_2 = "#1e2130"
letra   = "white"
f_family = "Sans-serif"
#Crear las gráficas
fig=px.bar(aeropuertos,x="id_vuelo",y="num_tickets",title="Número de tiquetes por vuelo")
fig_2=px.line(vuelos_hora,x="hora_llegada",y="total",title="Número de vuelos que llegan por hora")
fig_3=px.bar(num_aviones,x="aerolinea",y="num_aviones",title="Número de aviones por aerolinea")
fig_5=px.bar(nacionalidad, x='nacionalidad',y="total",title="Flujo de turistas por nacionalidad")
#fig_4 = px.scatter(nacionalidad, x="nacionalidad", y="total",size="total",title="Nacionalidad con mayor flujo de turistas")
#fig_4 = px.scatter_geo(destino, locations="ciudad", size="total",projection="natural earth",title="Mapa mundi")
fig_6=px.pie(modelos, values='total', names='nombre',title="Modelos de aviones")

fig_7=px.scatter_geo(mapa, locations="codigo_pais", size="total",projection="natural earth",title="Mapa mundi")

print( px.data.gapminder() )
#actualizar los estilos de las gráficas
fig.update_traces(marker_color='rgb(199, 0, 57)', marker_line_color='rgb(144, 12, 63)',
                  marker_line_width=1.5, opacity=0.6)
fig_3.update_traces(marker_color='rgb(199, 0, 57)', marker_line_color='rgb(144, 12, 63)',
                  marker_line_width=1.5, opacity=0.6)

fig.update_layout(paper_bgcolor = "#1e2130", font = {'color': letra, 'family': "Times New Roman",'size':15})
fig_2.update_layout(paper_bgcolor = "#161a28", font = {'color': letra, 'family': "Times New Roman",'size':15})
fig_3.update_layout(paper_bgcolor = "#1e2130", font = {'color': letra, 'family': "Times New Roman",'size':15})
#fig_4.update_layout(paper_bgcolor = "#D7EDFA", font = {'color': "black", 'family': "Times New Roman"})
fig_5.update_layout(paper_bgcolor = "#161a28", font = {'color': letra, 'family': "Times New Roman",'size':15})
fig_6.update_layout(paper_bgcolor ="#161a28", font = {'color': letra, 'family': "Times New Roman",'size':15})
fig_7.update_layout(paper_bgcolor = "#1e2130", font = {'color': letra, 'family': "Times New Roman",'size':15})

app.layout = html.Div(children=[ 
            html.Div('Base de datos aérea',style={ 'family': "Times New Roman", 'fontSize': 50,'text-align':"center",'color':letra}
            ),
              
            dcc.Graph(
            id='mapa',
            figure=fig_7,
            style={'text-align':"center"}
            ),
            
            dcc.Graph(
            id='modelos',
            figure=fig_6,
            style={'text-align':"center"}
            ),
            
            
            dcc.Graph(
            id='tiquetes',
            figure=fig,
            style={'text-align':"center"}
            ),
              
            dcc.Graph(
            id='llegadas',
            figure=fig_2,
            style={'text-align':"center"}
            ),
              
            dcc.Graph(
            id='aviones',
            figure=fig_3,
            ),dcc.Dropdown( id = 'menu',
            options = [
                {'label':'Top 10 nacionalidades ascendentemente', 'value':'asc' },
                {'label': 'Top 10 nacionalidades descendentemente', 'value':'desc'},
                
                ],
            style={'backgroundColor':"#161a28"}
            ),
            html.Button('Ver', id='b_ver', n_clicks=0, style={'backgroundColor':'#D7EDFA'}),
            dcc.Graph(
            id='nacionalidad',
            ),
                                ],
        style={'backgroundColor':"#161a28"})
@app.callback( 
        dash.dependencies.Output("nacionalidad","figure"),
        dash.dependencies.Input("menu","value"),
        dash.dependencies.Input('b_ver', 'n_clicks'),
       
    )
def update_graph(value,n_clicks):
    df=nacionalidad
    if n_clicks!=0:
        if value is not None:
            if value=="asc":
                df=nacionalidad_asc
                
            print(df)
      
    fig_5=px.bar(df, x='nacionalidad',y="total",title="Flujo de turistas por nacionalidad")
    fig_5.update_layout(paper_bgcolor = "#161a28", font = {'color': letra, 'family': "Times New Roman"})
    fig_5.update_traces(marker_color='rgb(199, 0, 57)', marker_line_color='rgb(144, 12, 63)',
                  marker_line_width=1.5, opacity=0.6)   
    return fig_5
    
if __name__ == "__main__":
    app.run_server(debug=True)
    


