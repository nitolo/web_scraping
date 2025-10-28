from selenium import webdriver

driver = webdriver.Chrome()

url_trm = "https://suameca.banrep.gov.co/estadisticas-economicas/informacionSerie/1/tasa_cambio_peso_colombiano_trm_dolar_usd"

driver.get(url_trm)

xpath = "/html/body/app-root/div/div/div/div/app-informacion-serie/div/div[3]/div[1]/div[2]/button"

from selenium.webdriver.common.by import By

vista_tabla = driver.find_element(By.XPATH, xpath)
vista_tabla.click()
