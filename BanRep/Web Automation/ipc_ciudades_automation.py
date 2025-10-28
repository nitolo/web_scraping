from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
import os
import time

# 1. --- CONFIGURACIÓN DE DESCARGA ---

download_directory = r"Z:\03_Investigaciones_Economicas\12. Automatizaciones\Web automation BanRep\Sucios"
download_directory
# Crear el directorio si no existe
if not os.path.exists(download_directory):
    os.makedirs(download_directory)

chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument('--disable-blink-features=AutomationControlled')
chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
chrome_options.add_experimental_option('useAutomationExtension', False)
# Configuraciones 
prefs = {
    "download.default_directory": download_directory,
    "download.prompt_for_download": False,
    "download.directory_upgrade": True,
    "safebrowsing.enabled": False,
    "profile.default_content_settings.popups": 0,
    "profile.default_content_setting_values.automatic_downloads": 1,
    "profile.content_settings.exceptions.automatic_downloads.*.setting": 1,
    "profile.managed_default_content_settings.images": 1,
    "profile.content_settings.pattern_pairs.*,*.filetype_download_permission": 1
}
chrome_options.add_experimental_option("prefs", prefs)
chrome_options.add_argument("--headless=new") 
chrome_options.add_argument("--no-sandbox")


driver = webdriver.Chrome(options=chrome_options)
wait = WebDriverWait(driver, 20) # Objeto de espera explícita

# 3. --- NAVEGACIÓN ---
url = "https://suameca.banrep.gov.co/estadisticas-economicas-back/reporte-oac.html?path=%2FEstadisticas_Banco_de_la_Republica%2F1_Precios_e_Inflacion%2F2_Indice_de_precios_al_consumidor%2F2_IPC_base_2018%2F1_IPC_2018_por_ciudad"
print(f"Navegando a: {url}")
driver.get(url)
time.sleep(20)
# 4. --- TÍTULO ---
# La clave del asunto con los archivos de BanRep es que le de click en el título principal 
# de la página para que no mame gallo (ya que pueden aparecer dos tablas)
titulo_xpath = "/html/body/div[2]/oracle-dv/div[1]/div/div[1]/div/div/div/div/div/div[2]/div/div/div/div/div/div/div[2]/div/div[1]/div[2]/div[9]/div/table/tbody/tr[1]/td/div/div[3]/div/div/label"
vista_titulo = wait.until(EC.presence_of_element_located((By.XPATH, titulo_xpath)))

actions = ActionChains(driver)
actions.context_click(vista_titulo).perform()
print("Clic derecho realizado.")

# 5. --- CLICS EN EL MENÚ CONTEXTUAL ---

# Botón de Exportar
exportar_xpath = "/html/body/div[1]/div/oj-menu/oj-option[5]/a"
vista_exportar = wait.until(EC.element_to_be_clickable((By.XPATH, exportar_xpath)))
vista_exportar.click()
print("Click en 'Exportar'")

# Botón de " A Archivo"
archivo_xpath = "/html/body/div[1]/div/oj-menu/oj-option[5]/oj-menu/oj-option[2]/a"
vista_archivo = wait.until(EC.element_to_be_clickable((By.XPATH, archivo_xpath)))
vista_archivo.click()
print("Click en 'A Archivo' ")

# Botón de "Guardar (Datos (CSV))"
tabla_xpath = "/html/body/div[1]/div[2]/oj-dialog/div/div[3]/div/oj-button[1]/button"
wait.until(EC.visibility_of_element_located((By.XPATH, "/html/body/div[1]/div[2]/oj-dialog")))
vista_tabla = wait.until(EC.element_to_be_clickable((By.XPATH, tabla_xpath)))
driver.execute_script("arguments[0].click();", vista_tabla)

print("Clic final de descarga. La descarga debería comenzar automáticamente.")

# 6. --- COMPROBACIÓN DE LA DESCARGA ---
# Hay que darle chance a que se cargue el csv
time.sleep(20) 
print(f"Carpeta de descarga: {download_directory}")
print(f"Archivos encontrados: {os.listdir(download_directory)}")

# 7. --- CIERRE ---
driver.quit()

