FROM justb4/jmeter:5.5

# Sobrescribir el entrypoint por defecto para ejecutar JMeter directamente
ENTRYPOINT ["jmeter"]