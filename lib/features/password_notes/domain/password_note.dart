import 'package:equatable/equatable.dart';

final class PasswordNote extends Equatable {
  const PasswordNote({
    required this.id,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    required this.notes,
    required this.category,
    required this.isFavourite,
  });

  final String id;
  final String name;
  final String url;
  final String username;
  final String password;
  final String notes;
  final String category;
  final bool isFavourite;

  @override
  List<Object?> get props => [
    id,
    name,
    url,
    username,
    password,
    notes,
    category,
    isFavourite,
  ];
}

final class PasswordNoteDraft extends Equatable {
  const PasswordNoteDraft({
    required this.name,
    this.id,
    this.url = '',
    this.username = '',
    this.password = '',
    this.notes = '',
    this.category = '',
    this.isFavourite = false,
  });

  final String? id;
  final String name;
  final String url;
  final String username;
  final String password;
  final String notes;
  final String category;
  final bool isFavourite;

  @override
  List<Object?> get props => [
    id,
    name,
    url,
    username,
    password,
    notes,
    category,
    isFavourite,
  ];
}

final class PasswordFilter extends Equatable {
  const PasswordFilter({
    this.query = '',
    this.category,
    this.favouritesOnly = false,
  });

  final String query;
  final String? category;
  final bool favouritesOnly;

  @override
  List<Object?> get props => [query, category, favouritesOnly];
}

/// Suggested categories (the design's chips); users can add their own.
const defaultPasswordCategories = [
  'Banking',
  'Bills',
  'Work',
  'Shopping',
  'Social',
];
