"""Pruebas HTTP contra JSF real. Ejecutar con el servidor encendido."""
from html.parser import HTMLParser
from http.cookiejar import CookieJar
from pathlib import Path
import json
import urllib.parse
import urllib.request

BASE = 'http://localhost:8090/taller-jsf/'
LOG = Path('.tools/servidor.log')

class Form(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.hidden = {}
        self.action = ''
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == 'form':
            self.action = urllib.parse.urljoin(BASE, a['action'])
        if tag == 'input' and a.get('type') == 'hidden':
            self.hidden[a['name']] = a.get('value', '')

def log_count():
    return LOG.read_text(encoding='utf-8', errors='replace').count('FASE 5 ALCANZADA')

results = []
for case, name, email, role, messages, success in [
    ('Campos vacíos', '', '', '', ['El nombre es obligatorio.', 'El correo es obligatorio.', 'Debe seleccionar un rol.'], False),
    ('Correo inválido', 'Usuario Prueba', 'correo-invalido', 'ADMIN', ['Ingresa un correo válido'], False),
    ('Nombre en blanco', '   ', 'prueba@example.com', 'ADMIN', ['Ingresa un nombre válido'], False),
    ('Rol manipulado', 'Usuario Prueba', 'prueba@example.com', 'ROOT', [], False),
    ('Registro correcto', 'Usuario Prueba', 'prueba@example.com', 'OPERADOR', ['¡Registro procesado con éxito!'], True),
]:
    client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(CookieJar()))
    form = Form(client.open(BASE).read().decode('utf-8'))
    before = log_count()
    data = dict(form.hidden)
    data.update({'frmUsuario': 'frmUsuario', 'frmUsuario:txtNombre': name, 'frmUsuario:txtCorreo': email,
                 'frmUsuario:cboRol': role, 'frmUsuario:btnRegistrar': 'Registrar Usuario'})
    response = client.open(form.action, urllib.parse.urlencode(data).encode())
    html = response.read().decode('utf-8')
    assert all(message in html for message in messages), case + ': mensaje ausente'
    assert ('confirmacion.xhtml' in response.url) == success, case + ': navegación incorrecta'
    assert log_count() - before == int(success), case + ': ejecución incorrecta de fase 5'
    results.append({'prueba': case, 'resultado': 'OK', 'url_final': response.url, 'invocaciones_fase_5': int(success)})

assert '>>> Nombre : Usuario Prueba' in LOG.read_text(encoding='utf-8')
assert '>>> Correo : prueba@example.com' in LOG.read_text(encoding='utf-8')
assert '>>> Rol    : OPERADOR' in LOG.read_text(encoding='utf-8')
Path('evidencias').mkdir(exist_ok=True)
Path('evidencias/verificacion.json').write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(results, ensure_ascii=False, indent=2))
