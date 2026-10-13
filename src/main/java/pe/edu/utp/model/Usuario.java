package pe.edu.utp.model;

import java.io.Serializable;

public class Usuario implements Serializable {
    private static final long serialVersionUID = 1L;
    private String nombre;
    private String correo;
    private String rol;

    public Usuario() { }
    public Usuario(String nombre, String correo, String rol) {
        this.nombre = nombre;
        this.correo = correo;
        this.rol = rol;
    }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }
}
