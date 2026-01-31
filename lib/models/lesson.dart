import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_admin/models/question.dart';

/// Tipos de contenido soportados para lecciones
enum LessonContentType {
  video,
  article,
  quiz,
  document,
  youtube,
  mixed,
}

/// Tipos de archivos de documentos soportados
enum DocumentType {
  word,
  pdf,
  text,
  image,
  video,
}

/// Modelo para representar un material de lección
class LessonMaterial {
  final String id;
  final String name;
  final DocumentType type;
  final String url;
  final int? fileSize;
  final String? mimeType;
  final DateTime? uploadedAt;

  LessonMaterial({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.fileSize,
    this.mimeType,
    this.uploadedAt,
  });

  factory LessonMaterial.fromMap(Map<String, dynamic> map) {
    return LessonMaterial(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: _parseDocumentType(map['type']),
      url: map['url'] ?? '',
      fileSize: map['file_size'],
      mimeType: map['mime_type'],
      uploadedAt: map['uploaded_at'] != null 
          ? (map['uploaded_at'] as Timestamp).toDate() 
          : null,
    );
  }

  static DocumentType _parseDocumentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'word':
        return DocumentType.word;
      case 'pdf':
        return DocumentType.pdf;
      case 'text':
        return DocumentType.text;
      case 'image':
        return DocumentType.image;
      case 'video':
        return DocumentType.video;
      default:
        return DocumentType.text;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'url': url,
      'file_size': fileSize,
      'mime_type': mimeType,
      'uploaded_at': uploadedAt != null 
          ? Timestamp.fromDate(uploadedAt!) 
          : null,
    };
  }
}

/// Modelo para representar un video de YouTube
class YouTubeVideo {
  final String videoId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final int? duration;

  YouTubeVideo({
    required this.videoId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.duration,
  });

  factory YouTubeVideo.fromMap(Map<String, dynamic> map) {
    return YouTubeVideo(
      videoId: map['video_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      thumbnailUrl: map['thumbnail_url'],
      duration: map['duration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'video_id': videoId,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
    };
  }

  /// Obtiene la URL completa del video
  String get url => 'https://www.youtube.com/watch?v=$videoId';

  /// Obtiene la URL de embed para el reproductor
  String get embedUrl => 'https://www.youtube.com/embed/$videoId';

  /// Obtiene la URL de la miniatura (alta calidad)
  String get highThumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  /// Obtiene la URL de la miniatura (máxima calidad)
  String get maxThumbnailUrl => 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
}

/// Modelo para representar un video local
class LocalVideo {
  final String url;
  final String? title;
  final String? description;
  final int? duration;
  final String? thumbnailUrl;

  LocalVideo({
    required this.url,
    this.title,
    this.description,
    this.duration,
    this.thumbnailUrl,
  });

  factory LocalVideo.fromMap(Map<String, dynamic> map) {
    return LocalVideo(
      url: map['url'] ?? '',
      title: map['title'],
      description: map['description'],
      duration: map['duration'],
      thumbnailUrl: map['thumbnail_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
      'description': description,
      'duration': duration,
      'thumbnail_url': thumbnailUrl,
    };
  }
}

/// Modelo principal de Lección
class Lesson {
  final String id;
  final String name;
  final int order;
  final String contentType;
  final String? videoUrl;
  final String? description;
  final String? lessonBody;
  final List<Question>? questions;
  final List<String>? pdfLinks;
  final List<LessonMaterial>? materials;
  final YouTubeVideo? youtubeVideo;
  final LocalVideo? localVideo;
  final String? courseId;
  final String? levelId;
  final String? moduleId;
  final String? sectionId;
  final int duration;
  final bool isFree;
  final String? thumbnailUrl;
  final String? vimeoVideoId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lesson({
    required this.id,
    required this.name,
    required this.order,
    required this.contentType,
    this.videoUrl,
    this.description,
    this.lessonBody,
    this.questions,
    this.pdfLinks,
    this.materials,
    this.youtubeVideo,
    this.localVideo,
    this.courseId,
    this.levelId,
    this.moduleId,
    this.sectionId,
    this.duration = 0,
    this.isFree = false,
    this.thumbnailUrl,
    this.vimeoVideoId,
    this.createdAt,
    this.updatedAt,
  });

  factory Lesson.fromFiresore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<String, dynamic>;
    
    // Parsear materiales
    List<LessonMaterial>? materials;
    if (d['materials'] != null) {
      materials = (d['materials'] as List)
          .map((m) => LessonMaterial.fromMap(m as Map<String, dynamic>))
          .toList();
    }

    // Parsear video de YouTube
    YouTubeVideo? youtubeVideo;
    if (d['youtube_video'] != null) {
      youtubeVideo = YouTubeVideo.fromMap(d['youtube_video'] as Map<String, dynamic>);
    }

    // Parsear video local
    LocalVideo? localVideo;
    if (d['local_video'] != null) {
      localVideo = LocalVideo.fromMap(d['local_video'] as Map<String, dynamic>);
    }

    return Lesson(
      id: snap.id,
      name: d['name'],
      order: d['order'],
      videoUrl: d['video_url'],
      contentType: d['content_type'],
      description: d['description'],
      lessonBody: d['lesson_body'],
      questions: d['quiz'] == null ? [] : List<Question>.from(d['quiz'].map((x) => Question.fromMap(x))),
      pdfLinks: d['pdf_links'] == null ? [] : List<String>.from(d['pdf_links']),
      materials: materials,
      youtubeVideo: youtubeVideo,
      localVideo: localVideo,
      courseId: d['course_id'],
      levelId: d['level_id'],
      moduleId: d['module_id'],
      sectionId: d['section_id'],
      duration: d['duration'] ?? 0,
      isFree: d['is_free'] ?? false,
      thumbnailUrl: d['thumbnail_url'],
      vimeoVideoId: d['vimeo_video_id'],
      createdAt: d['created_at'] != null ? (d['created_at'] as Timestamp).toDate() : null,
      updatedAt: d['updated_at'] != null ? (d['updated_at'] as Timestamp).toDate() : null,
    );
  }

  static Map<String, dynamic> getMap(Lesson d) {
    return {
      'name': d.name,
      'order': d.order,
      'video_url': d.videoUrl,
      'content_type': d.contentType,
      'description': d.description,
      'lesson_body': d.lessonBody,
      'course_id': d.courseId,
      'level_id': d.levelId,
      'module_id': d.moduleId,
      'section_id': d.sectionId,
      'quiz': d.questions?.map((e) => Question.getMap(e)).toList(),
      'pdf_links': d.pdfLinks,
      'materials': d.materials?.map((m) => m.toMap()).toList(),
      'youtube_video': d.youtubeVideo?.toMap(),
      'local_video': d.localVideo?.toMap(),
      'duration': d.duration,
      'is_free': d.isFree,
      'thumbnail_url': d.thumbnailUrl,
      'vimeo_video_id': d.vimeoVideoId,
      'created_at': d.createdAt != null ? Timestamp.fromDate(d.createdAt!) : null,
      'updated_at': d.updatedAt != null ? Timestamp.fromDate(d.updatedAt!) : null,
    };
  }

  /// Obtiene el tipo de contenido como enum
  LessonContentType get contentTypeEnum {
    switch (contentType.toLowerCase()) {
      case 'video':
        return LessonContentType.video;
      case 'article':
        return LessonContentType.article;
      case 'quiz':
        return LessonContentType.quiz;
      case 'document':
        return LessonContentType.document;
      case 'youtube':
        return LessonContentType.youtube;
      case 'mixed':
        return LessonContentType.mixed;
      default:
        return LessonContentType.video;
    }
  }

  /// Verifica si la lección tiene materiales
  bool get hasMaterials => materials != null && materials!.isNotEmpty;

  /// Verifica si la lección tiene video de YouTube
  bool get hasYouTubeVideo => youtubeVideo != null;

  /// Verifica si la lección tiene video local
  bool get hasLocalVideo => localVideo != null;

  /// Verifica si la lección tiene cuestionario
  bool get hasQuiz => questions != null && questions!.isNotEmpty;

  /// Obtiene la URL del video principal
  String? get primaryVideoUrl {
    if (hasYouTubeVideo) {
      return youtubeVideo!.url;
    }
    if (hasLocalVideo) {
      return localVideo!.url;
    }
    return videoUrl;
  }

  /// Crea una copia de la lección con algunos campos actualizados
  Lesson copyWith({
    String? id,
    String? name,
    int? order,
    String? contentType,
    String? videoUrl,
    String? description,
    String? lessonBody,
    List<Question>? questions,
    List<String>? pdfLinks,
    List<LessonMaterial>? materials,
    YouTubeVideo? youtubeVideo,
    LocalVideo? localVideo,
    String? courseId,
    String? levelId,
    String? moduleId,
    String? sectionId,
    int? duration,
    bool? isFree,
    String? thumbnailUrl,
    String? vimeoVideoId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      contentType: contentType ?? this.contentType,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      lessonBody: lessonBody ?? this.lessonBody,
      questions: questions ?? this.questions,
      pdfLinks: pdfLinks ?? this.pdfLinks,
      materials: materials ?? this.materials,
      youtubeVideo: youtubeVideo ?? this.youtubeVideo,
      localVideo: localVideo ?? this.localVideo,
      courseId: courseId ?? this.courseId,
      levelId: levelId ?? this.levelId,
      moduleId: moduleId ?? this.moduleId,
      sectionId: sectionId ?? this.sectionId,
      duration: duration ?? this.duration,
      isFree: isFree ?? this.isFree,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      vimeoVideoId: vimeoVideoId ?? this.vimeoVideoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
