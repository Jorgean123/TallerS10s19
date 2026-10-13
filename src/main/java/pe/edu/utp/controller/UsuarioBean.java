package pe.edu.utp.controller;

import jakarta.annotation.PostConstruct;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import pe.edu.utp.model.Usuario;

@Named("usuarioBean")
@ViewScoped
public class UsuarioBean implements Serializable {
    private static final long serialVersionUID = 1L;
    private Usuario usuario;

    @PostConstruct
    public void init() { usuario = new Usuario(); }

    public String procesar() {
        // JSF solo invoca esta acción si las validaciones del formulario pasan.
        System.out.println("==================================================");
        System.out.println(">>> FASE 5 ALCANZADA: Invoke Application");
        System.out.println(">>> Nombre : " + usuario.getNombre());
        System.out.println(">>> Correo : " + usuario.getCorreo());
        System.out.println(">>> Rol    : " + usuario.getRol());
        System.out.println("==================================================");
        return "confirmacion?faces-redirect=true";
    }
    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }
}
