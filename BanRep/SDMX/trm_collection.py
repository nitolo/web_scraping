import requests
import pandas as pd
import xml.etree.ElementTree as ET
from datetime import datetime

# URL base y parámetros fijos
url = "https://totoro.banrep.gov.co/nsi-jax-ws/rest/data/ESTAT,DF_TRM_DAILY_HIST,1.0/"
params = {
    'dimensionAtObservation': 'TIME_PERIOD',
    'detail': 'full'
}

# Consulta al servicio
response = requests.get(url, params=params)
xml_content = response.content

# Namespaces para parsear XML
namespaces = {
    'generic': 'http://www.sdmx.org/resources/sdmxml/schemas/v2_1/data/generic'
}

# Parseo básico del XML
root = ET.fromstring(xml_content)
data = []


for series in root.findall('.//generic:Series', namespaces):
    for obs in series.findall('.//generic:Obs', namespaces):
        date = obs.find('.//generic:ObsDimension', namespaces).get('value')
        value = obs.find('.//generic:ObsValue', namespaces).get('value')
        if date and value:
            try:
                # Intentar ambos formatos
                if len(date) == 8 and date.isdigit():
                    date_obj = datetime.strptime(date, '%Y%m%d')
                else:
                    date_obj = datetime.strptime(date, '%Y-%m-%d')
                data.append({'fecha': date_obj, 'trm': float(value)})
            except Exception as e:
                print(f"Error con fecha {date}: {e}")


# Crear DataFrame
df_trm = pd.DataFrame(data).sort_values('fecha').reset_index(drop=True)

# Mostrar los primeros registros
print(df_trm.head())
