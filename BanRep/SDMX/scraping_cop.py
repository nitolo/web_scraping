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


<table class="datatable_table__DE_1_ dynamic-table_dynamic-table__rxziu mdMax:border-separate datatable_table--mobile-basic__rzXxT undefined" style="--mobile-tablet-freeze-column-width: 155px;"><thead class="datatable_head__n1DHj"><tr class="datatable_row__Hk3IV"><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL dynamic-table_header-cell__PDsoK" colspan="2"><div class="datatable_cell__wrapper__4bnlr"><span>Name</span></div></th><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span>Simple</span></div></th><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span>Exponential</span></div></th></tr></thead><tbody class="datatable_body__tb4jX"><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C !h-auto w-full !border-t-[#e6e9eb] py-2" colspan="2"><span class="pt-2 font-bold">MA5</span></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3827.69</div><td class="datatable_cell__LJp3C datatable_cell--up__hIuZF datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Buy</td></div></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3832.26</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td></tr><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C !h-auto w-full !border-t-[#e6e9eb] py-2" colspan="2"><span class="pt-2 font-bold">MA10</span></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3840.91</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3842.07</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td></tr><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C !h-auto w-full !border-t-[#e6e9eb] py-2" colspan="2"><span class="pt-2 font-bold">MA20</span></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3865.13</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3860.66</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td></tr><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C !h-auto w-full !border-t-[#e6e9eb] py-2" colspan="2"><span class="pt-2 font-bold">MA50</span></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3895.47</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3879.47</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td></tr><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C !h-auto w-full !border-t-[#e6e9eb] py-2" colspan="2"><span class="pt-2 font-bold">MA100</span></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3885.79</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3885.85</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td></tr><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C !h-auto w-full !border-t-[#e6e9eb] py-2" colspan="2"><span class="pt-2 font-bold">MA200</span></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3886.91</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td><td class="datatable_cell__LJp3C !border-t-[#e6e9eb] py-2.5 mdMax:!p-3"><div class="flex items-center justify-between smMax:flex-col smMax:items-end mdMax:gap-x-4"><div class="flex-1">3897.19</div><td class="datatable_cell__LJp3C datatable_cell--down___c4Fq datatable_cell--bold__5MJH6 !h-full flex-1 !border-0 !p-0 smMax:mt-1">Sell</td></div></td></tr></tbody></table>
<table class="datatable_table__DE_1_ dynamic-table_dynamic-table__rxziu mdMax:border-separate datatable_table--mobile-basic__rzXxT datatable_table--freeze-column__XKTDf undefined" style="--mobile-tablet-freeze-column-width: 155px;"><thead class="datatable_head__n1DHj"><tr class="datatable_row__Hk3IV"><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span>Name</span></div></th><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL datatable_cell--align-end__qgxDQ dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span class="block w-full">S3</span></div></th><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL datatable_cell--align-end__qgxDQ dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span class="block w-full">S2</span></div></th><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL datatable_cell--align-end__qgxDQ dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span class="block w-full">S1</span></div></th><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL datatable_cell--align-end__qgxDQ dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span class="block w-full">Pivot Points</span></div></th><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL datatable_cell--align-end__qgxDQ dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span class="block w-full">R1</span></div></th><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL datatable_cell--align-end__qgxDQ dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span class="block w-full">R2</span></div></th><th class="datatable_cell__LJp3C datatable_cell--noborder__wajuL datatable_cell--align-end__qgxDQ dynamic-table_header-cell__PDsoK"><div class="datatable_cell__wrapper__4bnlr"><span class="block w-full">R3</span></div></th></tr></thead><tbody class="datatable_body__tb4jX"><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">Classic</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3824.06</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3826.65</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3829.07</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">3831.66</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3834.08</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3836.67</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3"><span class="text-xs">3839.09</span></td></tr><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">Fibonacci</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3826.65</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3828.56</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3829.75</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">3831.66</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3833.57</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3834.76</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3"><span class="text-xs">3836.67</span></td></tr><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">Camarilla</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3830.12</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3830.58</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3831.04</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">3831.66</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3831.96</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3832.42</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3"><span class="text-xs">3832.88</span></td></tr><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">Woodie's</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3823.98</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3826.61</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3828.99</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">3831.62</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3834</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3836.63</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3"><span class="text-xs">3839.01</span></td></tr><tr class="datatable_row__Hk3IV"><td class="datatable_cell__LJp3C w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">DeMark's</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">-</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">-</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3830.37</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs font-semibold">3832.31</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">3835.38</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3 text-xs"><span class="text-xs">-</span></td><td class="datatable_cell__LJp3C datatable_cell--align-end__qgxDQ w-full !border-t-[#e6e9eb] !py-3"><span class="text-xs">-</span></td></tr></tbody></table>