# Script simple para extraer indicadores técnicos USD/COP
import requests
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import time
import json

def scrape_usd_cop_indicators():
    """Función simple para extraer indicadores técnicos"""
    
    # Configurar Chrome
    options = Options()
    options.add_argument('--headless')  # Quitar para ver el navegador
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    
    # URL objetivo
    url = "https://www.investing.com/currencies/usd-cop-technical"
    
    try:
        # Inicializar driver
        driver = webdriver.Chrome(options=options)
        driver.get(url)
        time.sleep(5)  # Esperar carga
        
        print("Página cargada, extrayendo datos...")
        
        # Diccionario para almacenar resultados
        results = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'datos': {}
        }
        
        # Buscar todas las tablas
        tables = driver.find_elements(By.TAG_NAME, 'table')
        print(f"Encontradas {len(tables)} tablas")
        
        for i, table in enumerate(tables):
            try:
                table_data = []
                rows = table.find_elements(By.TAG_NAME, 'tr')
                
                for row in rows:
                    row_data = []
                    cells = row.find_elements(By.TAG_NAME, 'td')
                    if not cells:  # Si no hay td, buscar th
                        cells = row.find_elements(By.TAG_NAME, 'th')
                    
                    for cell in cells:
                        row_data.append(cell.text.strip())
                    
                    if row_data:
                        table_data.append(row_data)
                
                if table_data:
                    results['datos'][f'tabla_{i+1}'] = table_data
                    
            except Exception as e:
                print(f"Error procesando tabla {i+1}: {e}")
        
        # Buscar precio actual
        try:
            price_selectors = [
                '[data-test="instrument-price-last"]',
                '.text-2xl',
                '#last_last'
            ]
            
            for selector in price_selectors:
                try:
                    price_element = driver.find_element(By.CSS_SELECTOR, selector)
                    results['precio_actual'] = price_element.text.strip()
                    break
                except:
                    continue
                    
        except Exception as e:
            print(f"Error obteniendo precio: {e}")
        
        # Cerrar navegador
        driver.quit()
        
        return results
        
    except Exception as e:
        print(f"Error general: {e}")
        if 'driver' in locals():
            driver.quit()
        return None

def print_results(data):
    """Función para mostrar resultados de forma legible"""
    if not data:
        print("No hay datos para mostrar")
        return
    
    print(f"\n=== INDICADORES USD/COP - {data['timestamp']} ===")
    
    if 'precio_actual' in data:
        print(f"Precio actual: {data['precio_actual']}")
    
    print("\n=== TABLAS EXTRAÍDAS ===")
    for table_name, table_data in data.get('datos', {}).items():
        print(f"\n--- {table_name.upper()} ---")
        for row in table_data:
            if row:  # Solo mostrar filas con contenido
                print(" | ".join(str(cell) for cell in row))

def save_to_file(data, filename='usd_cop_data.json'):
    """Guardar datos en archivo JSON"""
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"\nDatos guardados en: {filename}")
    except Exception as e:
        print(f"Error guardando archivo: {e}")

# Ejecutar script
if __name__ == "__main__":
    print("Iniciando extracción de datos USD/COP...")
    
    # Extraer datos
    data = scrape_usd_cop_indicators()
    
    if data:
        # Mostrar resultados
        print_results(data)
        
        # Guardar en archivo
        save_to_file(data)
        
        print("\n✓ Extracción completada!")
    else:
        print("No se pudieron extraer datos")