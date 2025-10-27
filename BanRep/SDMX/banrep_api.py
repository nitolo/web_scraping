import requests
import pandas as pd
import xml.etree.ElementTree as ET
from datetime import datetime
import janitor

# --- CONFIGURACIÓN DE LA API Y NAMESPACES ---

URL_BASE = "https://totoro.banrep.gov.co/nsi-jax-ws/rest/data/ESTAT,"

NAMESPACES = {
    'generic': 'http://www.sdmx.org/resources/sdmxml/schemas/v2_1/data/generic'
}

SERIE_TRM = 'DF_TRM_DAILY_HIST,1.0/'
SERIE_IBR = 'DF_IBR_DAILY_HIST,1.0/'
SERIE_TPM = 'DF_DTF_DAILY_HIST,1.0/'
SERIE_TIB = 'DF_IR_DAILY_HIST,1.0/'

PARAMS = {
    'dimensionAtObservation': 'TIME_PERIOD',
    'detail': 'full'
}

def obtener_datos_sdmx(serie_id):
    """
    Consulta una serie SDMX del Banco de la República (BanRep) y 
    parsea el XML SDMX directamente para generar un DataFrame flexible,
    extrayendo todas las dimensiones relevantes como columnas.
    """
    url_completa = URL_BASE + serie_id
    print(f"Consultando URL: {url_completa}")

    try:
        response = requests.get(url_completa, params=PARAMS)
        response.raise_for_status()
        xml_content = response.content
    except requests.exceptions.RequestException as e:
        print(f"Error al realizar la petición HTTP para {serie_id}: {e}")
        return pd.DataFrame()

    data = []
    try:
        root = ET.fromstring(xml_content)
        for series in root.findall('.//generic:Series', NAMESPACES):
            # Extraer dimensiones de la serie (ejemplo: plazo, tipo de tasa, etc.)
            series_key = {}
            series_key_elem = series.find('generic:SeriesKey', NAMESPACES)
            if series_key_elem is not None:
                for dim in series_key_elem.findall('generic:Value', NAMESPACES):
                    series_key[dim.attrib['id']] = dim.attrib['value']

            for obs in series.findall('.//generic:Obs', NAMESPACES):
                # Fecha
                date_element = obs.find('./generic:ObsDimension', NAMESPACES)
                date = date_element.get('value') if date_element is not None else None

                # Valor
                value_element = obs.find('./generic:ObsValue', NAMESPACES)
                value = value_element.get('value') if value_element is not None else None

                # Unir dimensiones de la serie y observación
                registro = series_key.copy()
                registro['fecha'] = date
                registro['valor'] = value

                data.append(registro)
    except ET.ParseError as e:
        print(f"Error al parsear el XML para {serie_id}: {e}")
        return pd.DataFrame()
    except Exception as e:
        print(f"Ocurrió un error inesperado al procesar {serie_id}: {e}")
        return pd.DataFrame()

    # Crear DataFrame y convertir tipos
    df = pd.DataFrame(data)
    if 'fecha' in df.columns:
        # Convertir fecha a datetime si es posible
        def parse_fecha(date):
            try:
                if date and len(date) == 8 and date.isdigit():
                    return datetime.strptime(date, '%Y%m%d').date()
                elif date and '-' in date:
                    return datetime.strptime(date, '%Y-%m-%d').date()
            except Exception:
                return date
            return date
        df['fecha'] = df['fecha'].apply(parse_fecha)
        df = df.sort_values('fecha').reset_index(drop=True)
        #df = df.set_index('fecha')

    if 'valor' in df.columns:
        df['valor'] = pd.to_numeric(df['valor'], errors='coerce')

    return df


print("=== Consultando TRM ===")
df_trm = obtener_datos_sdmx(SERIE_TRM)
if not df_trm.empty:
    print(df_trm.tail())
    print(f"\nTotal de registros TRM: {len(df_trm)}")


print("=== Consultando IBR ===")
df_ibr = obtener_datos_sdmx(SERIE_IBR)
if not df_ibr.empty:
    print(df_ibr.tail())
    print(f"\nTotal de registros IBR: {len(df_ibr)}")
    print("\nColumnas disponibles:", df_ibr.columns.tolist())

print("=== Consultando DTF ===")
df_dtf = obtener_datos_sdmx(SERIE_DTF)
if not df_dtf.empty:
    print(df_dtf.tail())
    print(f"\nTotal de registros DTF: {len(df_dtf)}")
    print("\nColumnas disponibles:", df_dtf.columns.tolist())

print("=== Consultando TIB ===")
df_tib = obtener_datos_sdmx(SERIE_TIB)
if not df_tib.empty:
    print(df_tib.tail())
    print(f"\nTotal de registros TIB: {len(df_tib)}")
    print("\nColumnas disponibles:", df_tib.columns.tolist())

print("=== Consultando TPM ===")
df_tpm = obtener_datos_sdmx(SERIE_TPM)
if not df_tpm.empty:
    print(df_tpm.tail())
    print(f"\nTotal de registros TPM: {len(df_tpm)}")
    print("\nColumnas disponibles:", df_tpm.columns.tolist())


###################################################
################### LIMPIEZA  #####################
###################################################

# TRM
df_trm = df_trm[['fecha', 'valor']].clean_names()
print(df_trm.info())
print(df_trm.head())
print(df_trm.dtypes)
df_trm = df_trm.set_index('fecha')
df_trm = df_trm.rename(columns={'valor': 'TRM'})

# IBR
df_ibr = df_ibr[df_ibr['UNIT_MEASURE']=="NR"]
df_ibr = df_ibr[['fecha', 'valor', 'SUBJECT']].clean_names()
print(df_ibr.info())
print(df_ibr.head())
print(df_ibr.dtypes)
df_ibr['subject'].unique()

map_dict = {
    'IRIBRM00': 'IBR Overnight',
    'IRIBRM01': 'IBR 1 mes',
    'IRIBRM03': 'IBR 3 meses',
    'IRIBRM06': 'IBR 6 meses'
}

df_ibr['subject'] = df_ibr['subject'].map(map_dict)
print(df_ibr.head())

df_ibr = df_ibr.pivot(index='fecha', columns='subject', values='valor')

# TIB
df_tib = df_tib[['fecha', 'valor']].clean_names()
df_tib = df_tib.rename(columns={'valor': 'TIB - Tasa Interbancaria'})
df_tib = df_tib.set_index('fecha')

# TPM
df_tpm = df_tpm[['fecha', 'valor']].clean_names()
df_tpm = df_tpm.rename(columns={'valor': 'Tasa de Política Monetaria'})
df_tpm = df_tpm.set_index('fecha')
