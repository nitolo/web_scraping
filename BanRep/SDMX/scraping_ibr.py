import requests
import pandas as pd
from datetime import datetime

url = "https://suameca.banrep.gov.co/estadisticas-economicas-back/rest/estadisticaEconomicaRestService/consultaInformacionSerie"
params = {
    "idSerie": "242"  # Puedes poner más IDs separados por coma
}

resp = requests.get(url, params=params)
data = resp.json()

dfs = []
for serie in data:
    nombre = serie['nombre']
    unidad = serie.get('unidadCorta', '')
    # Cada punto es [timestamp, valor]
    registros = [
        {
            'fecha': datetime.fromtimestamp(int(p[0]) / 1000).date(),
            'valor': p[1],
            'serie': nombre,
            'unidad': unidad
        }
        for p in serie['data']
    ]
    df = pd.DataFrame(registros)
    dfs.append(df)

df_final = pd.concat(dfs)
df_final = df_final.pivot(index='fecha', columns='serie', values='valor')
#df_final.to_csv('ibr_multi.csv')
print(df_final.tail())
