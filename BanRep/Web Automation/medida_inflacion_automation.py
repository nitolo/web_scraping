import os
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from plyer import notification

# ==============================================================================
# CONFIGURACIÓN DEL ENTORNO Y DRIVER
# ==============================================================================

def configurar_driver(download_directory: str) -> tuple[webdriver.Chrome, WebDriverWait]:
    """
    Configura las opciones de Chrome (incluyendo el modo headless y la carpeta de descarga)
    e inicializa el WebDriver y el objeto de espera (WebDriverWait).

    Args:
        download_directory (str): Ruta completa donde se guardarán los archivos descargados.

    Returns:
        tuple[webdriver.Chrome, WebDriverWait]: Una tupla que contiene el objeto
        WebDriver configurado y el objeto WebDriverWait para esperas explícitas.
    """
    # Crear el directorio si no existe
    if not os.path.exists(download_directory):
        print(f"Creando directorio de descarga: {download_directory}")
        os.makedirs(download_directory)

    chrome_options = webdriver.ChromeOptions()
    
    # Opciones para evitar la detección de automatización
    chrome_options.add_argument('--disable-blink-features=AutomationControlled')
    chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
    chrome_options.add_experimental_option('useAutomationExtension', False)
    
    # Configuraciones de preferencias de descarga
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
    
    # Ejecutar en modo Headless (sin interfaz gráfica)
    chrome_options.add_argument("--headless=new") 
    chrome_options.add_argument("--no-sandbox")

    # Inicializar el driver y el objeto de espera
    driver = webdriver.Chrome(options=chrome_options)
    wait = WebDriverWait(driver, 20) 
    
    print("WebDriver configurado exitosamente.")
    return driver, wait


# ==============================================================================
# NAVEGACIÓN Y ESPERA
# ==============================================================================

def navegar_a_pagina(driver: webdriver.Chrome, url: str, sleep_time: int = 20) -> None:
    """
    Navega a la URL especificada y espera un tiempo fijo para la carga completa
    de la página, dado que la página usa contenido dinámico (JavaScript).

    Args:
        driver (webdriver.Chrome): El objeto WebDriver.
        url (str): La URL de la página a la que se debe navegar.
        sleep_time (int): Tiempo de espera en segundos después de navegar. 
                          Valor por defecto: 20s.
    """
    print(f"Navegando a: {url}")
    driver.get(url)
    time.sleep(sleep_time)
    print("Página cargada y tiempo de espera completado.")


# ==============================================================================
# INTERACCIÓN PARA DESCARGA
# ==============================================================================

def ejecutar_descarga(driver: webdriver.Chrome, wait: WebDriverWait) -> None:
    """
    Realiza la secuencia de interacciones necesarias para activar la descarga
    del archivo CSV desde el menú contextual.

    Args:
        driver (webdriver.Chrome): El objeto WebDriver.
        wait (WebDriverWait): El objeto WebDriverWait para esperas explícitas.

    Raises:
        TimeoutException: Si un elemento no se encuentra o no es clickeable 
                          dentro del tiempo de espera.
    """
    print("\n--- Iniciando secuencia de descarga ---")
    
    # XPATHS (Podrían ser pasados como argumentos si fueran dinámicos, 
    # pero se mantienen aquí por simplicidad al ser constantes para esta web)
    #TITULO_XPATH = "/html/body/div[2]/oracle-dv/div[1]/div/div[1]/div/div/div/div/div/div[2]/div/div/div/div/div/div/div[2]/div/div[1]/div[2]/div[9]/div/table/tbody/tr[1]/td/div/div[3]/div/div/label"
    TITULO_XPATH = "/html/body/div[2]/oracle-dv/div[1]/div/div[1]/div/div/div/div/div/div[2]/div/div/div/div/div/div/div[2]/div/div[1]/div[2]/div[10]/div/table/tbody/tr[1]/td/div/div[3]/div/div/label"
    EXPORTAR_XPATH = "/html/body/div[1]/div/oj-menu/oj-option[5]/a"
    ARCHIVO_XPATH = "/html/body/div[1]/div/oj-menu/oj-option[5]/oj-menu/oj-option[2]/a"
    GUARDAR_XPATH = "/html/body/div[1]/div[2]/oj-dialog/div/div[3]/div/oj-button[1]/button"
    
    # 1. Clic derecho en el título para activar el menú contextual
    print("Paso 1/4: Clic derecho en el título principal.")
    vista_titulo = wait.until(EC.presence_of_element_located((By.XPATH, TITULO_XPATH)))
    ActionChains(driver).context_click(vista_titulo).perform()
    
    # 2. Clic en 'Exportar'
    print("Paso 2/4: Click en 'Exportar'.")
    vista_exportar = wait.until(EC.element_to_be_clickable((By.XPATH, EXPORTAR_XPATH)))
    vista_exportar.click()

    # 3. Clic en 'A Archivo'
    print("Paso 3/4: Click en 'A Archivo'.")
    vista_archivo = wait.until(EC.element_to_be_clickable((By.XPATH, ARCHIVO_XPATH)))
    vista_archivo.click()

    # 4. Clic en 'Guardar (Datos (CSV))'
    # Se debe esperar a que el diálogo de Guardar aparezca
    wait.until(EC.visibility_of_element_located((By.XPATH, "/html/body/div[1]/div[2]/oj-dialog")))
    vista_guardar = wait.until(EC.element_to_be_clickable((By.XPATH, GUARDAR_XPATH)))
    
    # Se usa JS click para asegurar la interacción en algunos navegadores
    driver.execute_script("arguments[0].click();", vista_guardar)
    print("Paso 4/4: Clic final de descarga. La descarga debería comenzar automáticamente.")


# ==============================================================================
# VERIFICACIÓN Y FINALIZACIÓN
# ==============================================================================

def verificar_y_cerrar(driver: webdriver.Chrome, download_directory: str, wait_for_download: int = 20) -> None:
    """
    Espera un tiempo para que la descarga finalice y luego muestra los 
    archivos encontrados en la carpeta de descarga antes de cerrar el navegador.

    Args:
        driver (webdriver.Chrome): El objeto WebDriver.
        download_directory (str): La ruta donde se espera el archivo.
        wait_for_download (int): Tiempo de espera en segundos para que se complete la descarga.
                                 Valor por defecto: 20s.
    """
    print(f"\nEsperando {wait_for_download} segundos para que finalice la descarga...")
    time.sleep(wait_for_download) 
    
    print(f"\n====================== REPORTE DE DESCARGA =======================")
    print(f"Carpeta de descarga: {download_directory}")
    
    archivos_encontrados = os.listdir(download_directory)
    if archivos_encontrados:
        print(f"Archivos encontrados ({len(archivos_encontrados)}):")
        for archivo in archivos_encontrados:
            print(f" - {archivo}")
    else:
        print("¡ADVERTENCIA! No se encontraron archivos en la carpeta de descarga.")

    # Cierre del driver
    driver.quit()
    print("\nWebDriver cerrado. Automatización finalizada.")


# ==============================================================================
# FUNCIÓN PRINCIPAL DE ORQUESTACIÓN
# ==============================================================================

def main():
    """
    Función principal que orquesta todas las tareas de la automatización web.
    """
    
    # --- Parámetros de la Automatización ---
    URL = "https://suameca.banrep.gov.co/estadisticas-economicas-back/reporte-oac.html?path=%2FEstadisticas_Banco_de_la_Republica%2F1_Precios_e_Inflacion%2F9_Medidas_de_inflacion_Clasificacion_BANREP%2F1_Medidas_inflacion_clasificacion_BANREP_Metodologia2020_base2018_canasta_IPC"
    DOWNLOAD_DIR = r"Z:\03_Investigaciones_Economicas\12. Automatizaciones\Web automation BanRep\Sucios"
    
    # --- Archivo a sobrescribir ---
    ARCHIVO_A_SOBRESCRIBIR = "1_Medidas_inflacion_clasificacion_BANREP_Metodologia2020_base2018_canasta_IPC.csv"  
    RUTA_COMPLETA_ARCHIVO = os.path.join(DOWNLOAD_DIR, ARCHIVO_A_SOBRESCRIBIR)

    driver = None # Inicialización para el bloque finally

    try:
        if os.path.exists(RUTA_COMPLETA_ARCHIVO):
            os.remove(RUTA_COMPLETA_ARCHIVO)
            print(f"Archivo antiguo eliminado: {ARCHIVO_A_SOBRESCRIBIR}. Preparando sobrescritura.")
        else:
            print(f"El archivo {ARCHIVO_A_SOBRESCRIBIR} no existe. No se requiere limpieza previa.")
        
        # 1. Configurar e Inicializar el entorno
        driver, wait = configurar_driver(DOWNLOAD_DIR)

        # 2. Navegación
        navegar_a_pagina(driver, URL, sleep_time=20)

        # 3. Interacción para descarga
        ejecutar_descarga(driver, wait)

        # 4. Verificación y Cierre
        verificar_y_cerrar(driver, DOWNLOAD_DIR, wait_for_download=20)

        notification.notify(
            title="PROCESO FINALIZADO",
            message="La automatización web se completó con éxito. El archivo ha sido sobrescrito.",
            app_name='Automatización Python',
            timeout=10
        )
        time.sleep(1)

    except Exception as e:
        print(f"\n*** ERROR CRÍTICO EN LA AUTOMATIZACIÓN ***")
        print(f"Detalle del error: {e}")
        if driver:
             driver.quit()
             print("WebDriver cerrado tras el error.")

if __name__ == '__main__':
    main()

