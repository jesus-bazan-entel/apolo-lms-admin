# Checklist Rápido de Despliegue

## 📋 Checklist para Desplegar ApoloLMS en Firebase

### ✅ Prerrequisitos
- [ ] Flutter SDK instalado (`flutter doctor`)
- [ ] Node.js y npm instalados (`node --version`, `npm --version`)
- [ ] Firebase CLI instalado (`firebase --version`)
- [ ] FlutterFire CLI instalado (`flutterfire --version`)
- [ ] Cuenta de Google creada

### ✅ Configuración del Proyecto
- [ ] Repositorio clonado (`git clone`)
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Aplicación probada localmente (`flutter run -d chrome`)

### ✅ Configuración de Firebase
- [ ] Proyecto creado en Firebase Console
- [ ] Authentication habilitado (Email/Password + Google)
- [ ] Firestore Database creada y configurada
- [ ] Storage habilitado y configurado
- [ ] Cloud Messaging (FCM) configurado
- [ ] App conectada con Firebase (`flutterfire configure`)
- [ ] Hosting inicializado (`firebase init hosting`)

### ✅ Compilación
- [ ] Variables de entorno configuradas (API keys)
- [ ] Limpieza de caché (`flutter clean`)
- [ ] Dependencias actualizadas (`flutter pub get`)
- [ ] Compilación exitosa (`flutter build web --release`)
- [ ] Archivos generados en `build/web/`

### ✅ Despliegue
- [ ] Login en Firebase (`firebase login`)
- [ ] Proyecto seleccionado (`firebase use --project`)
- [ ] Despliegue ejecutado (`firebase deploy --only hosting`)
- [ ] URL de despliegue obtenida
- [ ] Aplicación verificada en navegador

### ✅ Post-Despliegue
- [ ] Funcionalidades probadas (login, dashboard, cursos)
- [ ] Errores de consola revisados (F12)
- [ ] Analytics configurado
- [ ] Dominio personalizado configurado (opcional)
- [ ] SSL verificado

---

## 🚀 Comandos Rápidos

### Primer Despliegue
```bash
# 1. Instalar herramientas
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# 2. Configurar Firebase
firebase login
flutterfire configure
firebase init hosting

# 3. Compilar
flutter clean
flutter pub get
flutter build web --release

# 4. Desplegar
firebase deploy --only hosting
```

### Actualización
```bash
# 1. Compilar cambios
flutter clean
flutter pub get
flutter build web --release

# 2. Desplegar
firebase deploy --only hosting --message "Descripción de cambios"
```

---

## 🔗 URLs Importantes

- **Firebase Console:** https://console.firebase.google.com/
- **Tu App (web.app):** https://apololms.web.app
- **Tu App (firebaseapp.com):** https://apololms.firebaseapp.com
- **Documentación Firebase:** https://firebase.google.com/docs
- **Documentación Flutter:** https://flutter.dev/docs

---

## ⚠️ Errores Comunes y Soluciones

| Error | Solución |
|-------|----------|
| `firebase: command not found` | `npm install -g firebase-tools` |
| `flutter: command not found` | Agregar Flutter al PATH |
| Pantalla blanca | `flutter build web --release --web-renderer html` |
| Error de autenticación | Verificar dominios autorizados en Firebase Console |
| Error al desplegar | `firebase login` y verificar proyecto |

---

## 📞 Soporte

Si tienes problemas:
1. Revisa la guía completa: [`GUIA_DESPLEGUE_COMPLETA.md`](GUIA_DESPLEGUE_COMPLETA.md)
2. Verifica logs en Firebase Console
3. Revisa consola del navegador (F12)
4. Consulta documentación oficial

---

**¡Listo para desplegar! 🎉**