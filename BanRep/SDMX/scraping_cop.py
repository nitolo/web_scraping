import time
import json
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options

# ==============================================================================
# 1. CONFIGURACIÓN INICIAL
# ==============================================================================

# URL objetivo: Cambia esta URL para diferentes indicadores/pares de divisas
URL = "https://www.investing.com/currencies/usd-cop-technical"
FILENAME = 'usd_cop_data.json'

# Configurar opciones de Chrome
options = Options()
options.add_argument('--headless')  # Ejecución sin interfaz gráfica
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

# Inicializar driver y estructura de resultados
driver = None
results = {
    'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
    'datos': {}
}

print("INICIO: Extracción de indicadores técnicos USD/COP.")

# ==============================================================================
# 2. EJECUCIÓN Y EXTRACCIÓN DE DATOS
# ==============================================================================

try:
    # 2.1. Iniciar Driver y cargar página
    driver = webdriver.Chrome(options=options)
    print("Iniciando driver y cargando página...")
    driver.get(URL)
    time.sleep(5)  # Espera para asegurar que todos los elementos carguen

    print("Página cargada, extrayendo datos...")

    # 2.2. Extracción de Tablas (Indicadores)
    tables = driver.find_elements(By.TAG_NAME, 'table')
    print(f"Encontradas {len(tables)} tablas")

    for i, table in enumerate(tables):
        table_data = []
        # Buscar filas (tr)
        for row in table.find_elements(By.TAG_NAME, 'tr'):
            # Buscar celdas de datos (td) o encabezado (th)
            cells = row.find_elements(By.TAG_NAME, 'td') or row.find_elements(By.TAG_NAME, 'th')
            
            if cells:
                # Extraer texto de las celdas y limpiar espacios
                row_data = [cell.text.strip() for cell in cells]
                table_data.append(row_data)
        
        # Almacenar datos si hay contenido
        if table_data:
            results['datos'][f'tabla_{i+1}'] = table_data
            
    # 2.3. Extracción de Precio Actual
    # Lista de selectores CSS comunes. Probar uno por uno hasta encontrar el precio.
    price_selectors = [
        '[data-test="instrument-price-last"]', # Selector más moderno
        '.text-2xl',
        '#last_last'
    ]
    
    for selector in price_selectors:
        try:
            price_element = driver.find_element(By.CSS_SELECTOR, selector)
            results['precio_actual'] = price_element.text.strip()
            print(f"Precio actual encontrado con selector '{selector}'.")
            break
        except:
            continue

except Exception as e:
    print(f"Error durante la extracción: {e}")

# ==============================================================================
# 3. FINALIZACIÓN Y CERRADO DEL DRIVER
# ==============================================================================

finally:
    if driver:
        driver.quit()
        print("Driver cerrado.")

# ==============================================================================
# 4. PROCESAMIENTO Y SALIDA (SECUENCIAL)
# ==============================================================================

if results.get('datos'):
    # 4.1. Mostrar resultados en consola
    print("\n" + "="*40)
    print(f"=== INDICADORES USD/COP - {results['timestamp']} ===")
    print("="*40)
    
    if 'precio_actual' in results:
        print(f"Precio actual: {results['precio_actual']}\n")
    
    print("--- TABLAS EXTRAÍDAS ---")
    for table_name, table_data in results.get('datos', {}).items():
        print(f"\n- {table_name.upper()} -")
        for row in table_data:
            if row:
                print(" | ".join(str(cell) for cell in row))

    # 4.2. Guardar en archivo JSON
    try:
        with open(FILENAME, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        print(f"\nDatos guardados correctamente en: {FILENAME}")
    except Exception as e:
        print(f"Error guardando archivo: {e}")
        
    print("\nFIN: Extracción y procesamiento completado.")
else:
    print("\nPROCESO TERMINADO: Fallo en la extracción de datos o no se encontraron datos.")


