# Semana 10 · Sesión 19 — JavaServer Faces

Taller implementado desde esta plataforma en `C:\WebIntegrado\TallerS10s19`, sin requerir un IDE. Aplicación Java real, compilada como WAR y ejecutada con Tomcat.

## Abrir y ejecutar

Dirección local: **http://localhost:8090/taller-jsf/**

Desde PowerShell, en la carpeta del proyecto:

```powershell
powershell -ExecutionPolicy Bypass -File .\iniciar.ps1
```

El script descarga Maven y Tomcat si faltan, compila el WAR y ejecuta el servidor en segundo plano. Utiliza el JDK 17 instalado en `C:\Program Files\Java\jdk-17`; ajustar esa ruta si se traslada a otro equipo. La primera compilación necesita Internet. Bootstrap está incluido localmente.

Para detenerlo:

```powershell
powershell -ExecutionPolicy Bypass -File .\detener.ps1
```

Para recompilar cambios, detener e iniciar nuevamente. El WAR para desplegar está en `target/taller-jsf.war`. Los archivos temporales y herramientas están en `.tools`.

## Estructura y rúbrica

| Criterio | Implementación |
| --- | --- |
| Modelo y encapsulamiento | `src/main/java/pe/edu/utp/model/Usuario.java`: constructor vacío y parametrizado, atributos privados, getters, setters y Serializable. |
| CDI y scope | `controller/UsuarioBean.java`: @Named("usuarioBean"), @ViewScoped, Serializable y @PostConstruct. `WEB-INF/beans.xml` habilita descubrimiento de clases anotadas. |
| Enlace EL | `registroUsuario.xhtml`: enlaces bidireccionales `#{usuarioBean.usuario.nombre}`, correo y rol. |
| Validación en servidor | required, mensajes por campo y validadores adicionales de nombre y correo. JSF valida que el rol pertenezca a las opciones. |
| Navegación y auditoría | `procesar()` imprime la fase 5 y los datos; devuelve `confirmacion?faces-redirect=true`. |

Las vistas emplean `h:head` y `h:body`, componentes Facelets y Bootstrap 5.3.3. La confirmación no consulta el bean anterior: @ViewScoped termina al abandonar la vista.

## Ciclo de vida

1. **Restore View:** recupera el árbol de componentes y su estado.
2. **Apply Request Values:** recoge los valores enviados.
3. **Process Validations:** valida campos requeridos, formato y opciones. Si falla, muestra mensajes en Render Response sin ejecutar la acción.
4. **Update Model Values:** actualiza el POJO mediante los enlaces EL.
5. **Invoke Application:** ejecuta `usuarioBean.procesar()` y emite la auditoría.
6. **Render Response:** genera la vista cuando corresponde; en el flujo válido se emite una redirección y una nueva solicitud GET muestra la confirmación (PRG).

## Verificación realizada

Con el servidor iniciado:

```powershell
python verificar.py
Get-Content .tools\servidor.log -Tail 20
```

El script usa cookies y el ViewState real de JSF. Verifica mensajes, destino de navegación y número de invocaciones de la acción en la consola. Resultados guardados en `evidencias/verificacion.json`:

| Prueba | Resultado | Invocaciones de fase 5 |
| --- | --- | --- |
| Todos los campos vacíos | Permanece en registro, tres mensajes obligatorios | 0 |
| Correo inválido | Mensaje de formato | 0 |
| Nombre solo con espacios | Mensaje de nombre inválido | 0 |
| Rol ajeno a las opciones | JSF rechaza la selección | 0 |
| Datos correctos | Redirige a confirmacion.xhtml y escribe los tres datos | 1 |

Compilación Maven: **BUILD SUCCESS**. Las cinco pruebas de integración HTTP pasaron. No se realizó inspección visual automatizada: esta sesión no dispone de navegador conectado.

## Alcance y entorno

No se necesita MySQL: el taller pide procesar los datos y auditarlos en consola, sin persistencia. No se guardaron credenciales. El selector de rol es parte del ejercicio, no un sistema de permisos o autenticación.

Java 17, Jakarta Faces (Mojarra) 4.0.11, Weld CDI 5.1.5.Final y Tomcat 10.1.61. Se usa CDI 4 con descubrimiento `annotated`, que reconoce el bean @ViewScoped. El servidor escucha solo en la máquina local, puerto 8090.

Referencias oficiales de compatibilidad: [Tomcat 10.1](https://tomcat.apache.org/migration-10.1.html) y [Weld 5.1.5 en contenedores Servlet](https://docs.jboss.org/weld/reference/5.1.5.Final/en-US/html/environments.html).
