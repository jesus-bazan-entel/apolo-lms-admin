import 'package:flutter/cupertino.dart';
import 'package:line_icons/line_icons.dart';

// --------- Don't edit these -----------

const String notificationTopicForAll = 'all';

const Map<int, List<dynamic>> menuList = {
  0: ['Panel de Control', LineIcons.pieChart],
  1: ['Estudiantes', LineIcons.userGraduate],
  2: ['Tutores', LineIcons.chalkboardTeacher],
  3: ['Cursos', LineIcons.book],
  4: ['Destacados', LineIcons.bomb],
  5: ['Categorías', CupertinoIcons.grid],
  6: ['Etiquetas', LineIcons.tags],
  7: ['Reseñas', LineIcons.starAlt],
  8: ['Configuración', CupertinoIcons.settings],
};

const Map<int, List<dynamic>> menuListAuthor = {
  0: ['Panel de Control', LineIcons.pieChart],
  1: ['Mis Cursos', LineIcons.book],
  2: ['Reseñas', LineIcons.starAlt],
};

const Map<String, String> courseStatus = {'draft': 'Borrador', 'pending': 'Pendiente', 'live': 'Publicado', 'archive': 'Archivado'};

const Map<String, String> lessonTypes = {'video': 'Video', 'article': 'Artículo', 'quiz': 'Cuestionario'};

const Map<String, String> priceStatus = {'free': 'Gratis', 'premium': 'Premium'};

const Map<String, String> sortByCourse = {
  'all': 'Todos',
  'live': 'Publicados',
  'draft': 'Borradores',
  'pending': 'Pendientes',
  'archive': 'Archivados',
  'featured': 'Cursos Destacados',
  'new': 'Más Recientes',
  'old': 'Más Antiguos',
  'free': 'Cursos Gratis',
  'premium': 'Cursos Premium',
  'high-rating': 'Alta Calificación',
  'low-rating': 'Baja Calificación',
  'category': 'Categoría',
  'author': 'Autor',
};

const Map<String, String> sortByUsers = {
  'all': 'Todos',
  'new': 'Más Recientes',
  'old': 'Más Antiguos',
  'admin': 'Administradores',
  'author': 'Autores',
  'disabled': "Usuarios Deshabilitados",
  'subscribed': "Usuarios Suscritos",
  'android': 'Usuarios Android',
  'ios': 'Usuarios iOS'
};

const Map<String, String> sortByReviews = {
  'all': 'Todas',
  'high-rating': 'Alta a Baja Calificación',
  'low-rating': 'Baja a Alta Calificación',
  'new': 'Más Recientes',
  'old': 'Más Antiguas',
  'course': 'Curso'
};

const Map<String, String> sortByPurchases = {
  'all': 'Todas',
  'new': 'Más Recientes',
  'old': 'Más Antiguas',
  'active': 'Activas',
  'expired': 'Expiradas',
  'android': 'Plataforma Android',
  'ios': 'Plataforma iOS',
};

const Map<String, String> userMenus = {
  'edit': 'Editar Perfil',
  'password': 'Cambiar Contraseña',
  'logout': 'Cerrar Sesión',
};

// Roles del Sistema
const Map<String, String> userRoles = {
  'admin': 'Administrador',
  'coordinator': 'Coordinador',
  'tutor': 'Tutor',
  'teacher': 'Profesor',
  'author': 'Autor',
  'student': 'Estudiante',
};

// Niveles de Estudiante
const Map<String, String> studentLevels = {
  'basic': 'Básico',
  'intermediate': 'Intermedio',
  'advanced': 'Avanzado',
};

// Estados de Pago
const Map<String, String> paymentStatuses = {
  'pending': 'Pendiente',
  'paid': 'Pagado',
  'overdue': 'Vencido',
  'free': 'Gratuito',
};

// Tipos de Material
const Map<String, String> materialTypes = {
  'pdf': 'Documento PDF',
  'video': 'Video',
  'link': 'Enlace Externo',
  'audio': 'Audio',
  'image': 'Imagen',
};

// Idiomas Disponibles
const Map<String, String> availableLanguages = {
  'portuguese': 'Portugués',
  'english': 'Inglés',
  'spanish': 'Español',
};

// Filtros de Estudiantes
const Map<String, String> sortByStudents = {
  'all': 'Todos',
  'new': 'Más Recientes',
  'old': 'Más Antiguos',
  'basic': 'Nivel Básico',
  'intermediate': 'Nivel Intermedio',
  'advanced': 'Nivel Avanzado',
  'paid': 'Pagados',
  'pending': 'Pago Pendiente',
  'overdue': 'Pago Vencido',
};
