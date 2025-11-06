class Trago {
  final int id;
  final String url;
  final String name;
  final String type;
  final String language;
  final List<String> genres;
  final String status;
  final int? runtime;
  final int? averageRuntime;
  final String? premiered;
  final String? ended;
  final String? officialSite;
  final Schedule? schedule;
  final Rating? rating;
  final int weight;
  final Network? network;
  final dynamic webChannel;
  final dynamic dvdCountry;
  final Externals? externals;
  final MediaImage? image;
  final String? summary;
  final int updated;
  final MediaLinks? links;

  Trago({
    required this.id,
    required this.url,
    required this.name,
    required this.type,
    required this.language,
    required this.genres,
    required this.status,
    this.runtime,
    this.averageRuntime,
    this.premiered,
    this.ended,
    this.officialSite,
    this.schedule,
    this.rating,
    required this.weight,
    this.network,
    this.webChannel,
    this.dvdCountry,
    this.externals,
    this.image,
    this.summary,
    required this.updated,
    this.links,
  });

  factory Trago.fromJson(Map<String, dynamic> json) {
    return Trago(
      id: json['id'],
      url: json['url'],
      name: json['name'],
      type: json['type'],
      language: json['language'],
      genres: List<String>.from(json['genres'] ?? []),
      status: json['status'],
      runtime: json['runtime'],
      averageRuntime: json['averageRuntime'],
      premiered: json['premiered'],
      ended: json['ended'],
      officialSite: json['officialSite'],
      schedule: json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
      weight: json['weight'],
      network: json['network'] != null ? Network.fromJson(json['network']) : null,
      webChannel: json['webChannel'],
      dvdCountry: json['dvdCountry'],
      externals: json['externals'] != null ? Externals.fromJson(json['externals']) : null,
      image: json['image'] != null ? MediaImage.fromJson(json['image']) : null,
      summary: json['summary'],
      updated: json['updated'],
      links: json['_links'] != null ? MediaLinks.fromJson(json['_links']) : null,
    );
  }
}

class Schedule {
  final String time;
  final List<String> days;

  Schedule({required this.time, required this.days});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      time: json['time'],
      days: List<String>.from(json['days'] ?? []),
    );
  }
}

class Rating {
  final double? average;

  Rating({this.average});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      average: (json['average'] != null) ? (json['average'] as num).toDouble() : null,
    );
  }
}

class Network {
  final int id;
  final String name;
  final Country? country;
  final String? officialSite;

  Network({required this.id, required this.name, this.country, this.officialSite});

  factory Network.fromJson(Map<String, dynamic> json) {
    return Network(
      id: json['id'],
      name: json['name'],
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      officialSite: json['officialSite'],
    );
  }
}

class Country {
  final String name;
  final String code;
  final String timezone;

  Country({required this.name, required this.code, required this.timezone});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      code: json['code'],
      timezone: json['timezone'],
    );
  }
}

class Externals {
  final int? tvrage;
  final int? thetvdb;
  final String? imdb;

  Externals({this.tvrage, this.thetvdb, this.imdb});

  factory Externals.fromJson(Map<String, dynamic> json) {
    return Externals(
      tvrage: json['tvrage'],
      thetvdb: json['thetvdb'],
      imdb: json['imdb'],
    );
  }
}

class MediaImage {
  final String? medium;
  final String? original;

  MediaImage({this.medium, this.original});

  factory MediaImage.fromJson(Map<String, dynamic> json) {
    return MediaImage(
      medium: json['medium'],
      original: json['original'],
    );
  }
}

class MediaLinks {
  final Link self;
  final Link? previousepisode;

  MediaLinks({required this.self, this.previousepisode});

  factory MediaLinks.fromJson(Map<String, dynamic> json) {
    return MediaLinks(
      self: Link.fromJson(json['self']),
      previousepisode: json['previousepisode'] != null ? Link.fromJson(json['previousepisode']) : null,
    );
  }
}

class Link {
  final String href;
  final String? name;

  Link({required this.href, this.name});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      href: json['href'],
      name: json['name'],
    );
  }
}
